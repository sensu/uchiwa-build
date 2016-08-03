require "fileutils"
require "systemu"

ASSET_DIR = ENV.fetch("ASSET_DIR", "/tmp/assets")
PKG_DIR = File.join(ASSET_DIR, "pkg")

FileUtils.mkdir_p(PKG_DIR) unless File.exists?(PKG_DIR)

operating_systems = [
  "linux"
]

platforms = {
  "i386" => "386",
  "amd64" => "amd64"
}

name = "uchiwa"
license = "https://github.com/sensu/uchiwa/blob/master/LICENSE"
version = ENV["PACKAGE_VERSION"]
iteration = 1
vendor = "Simon Plourde"
maintainer = "Simon Plourde simon.plourde@gmail.com"
category = "Monitoring"
url = "https://uchiwa.io"
description = "Uchiwa is a simple dashboard for the Sensu monitoring framework."
user = "uchiwa"
group = "uchiwa"

install_dir = "/tmp/install"
dashboard_dir = File.join(install_dir, "opt", name)

def run_command(cmd)
  status, stdout, stderr = systemu(cmd)
  puts stdout unless stdout.empty?
  puts stderr unless stderr.empty?
  unless status.exitstatus == 0
    abort "The command '#{cmd}' failed'"
  end
  return true
end

task :install_deps do
  run_command("go version")
  run_command("go get github.com/sensu/uchiwa")
  run_command("cd $GOPATH/src/github.com/sensu/uchiwa && " +
    "git checkout #{version} && cd -")
  run_command("cp -r $GOPATH/src/github.com/sensu/uchiwa/. .")
  run_command("npm install --production && npm run postinstall && " +
    "rm -rf node_modules")
  run_command("go get github.com/stretchr/testify")
end

task :run_tests do
  run_command("go test -v ./...")
  run_command("npm install -g grunt-cli")
  run_command("npm test")
end

task :build do
  operating_systems.each do |go_os|
    platforms.each do |platform, go_arch|
      puts "Building Uchiwa binary for #{platform} ..."
      output_path = "#{ASSET_DIR}/#{name}-#{go_os}-#{go_arch}"
      run_command("GOOS=#{go_os} GOARCH=#{go_arch} go build -v -o #{output_path}")
    end
  end
end

task :package do
  puts "Creating Uchiwa packages with FPM ..."

  run_command("cp -rf assets #{install_dir}")
  run_command("cp -rf public #{dashboard_dir}/src/")

  deb_scripts = "-t deb --after-install pkg_scripts/deb/postinst " +
    "--before-remove pkg_scripts/deb/prerm " +
    "--after-remove pkg_scripts/deb/postrm"

  rpm_scripts = "-t rpm --rpm-os linux --rpm-user #{user} " +
    "--rpm-group #{group} --before-install pkg_scripts/rpm/pre " +
    "--after-install pkg_scripts/rpm/post " +
    "--before-remove pkg_scripts/rpm/preun " +
    "--after-remove pkg_scripts/rpm/postun --epoch 1"

  operating_systems.each do |os|
    platforms.each do |platform, go_arch|
      puts "Building packages for #{platform} ..."
      puts "Copying Uchiwa binary to omnibus bin directory ..."
      run_command("cp -f #{ASSET_DIR}/#{name}-#{os}-#{go_arch} #{dashboard_dir}/bin/uchiwa")

      [deb_scripts, rpm_scripts].each do |package_scripts|
        fpm_cmd = "fpm -s dir #{package_scripts} -n '#{name}' -C #{install_dir} " +
          "-v #{version} --iteration #{iteration} " +
          "--license '#{license}' --vendor '#{vendor}' " +
          "--maintainer '#{maintainer}' " +
          "--category '#{category}' --url #{url} " +
          "--description '#{description}' -a #{platform} " +
          "--config-files /etc/sensu/uchiwa.json opt etc"

        puts "Running FPM command: #{fpm_cmd} ..."
        run_command(fpm_cmd)
      end
    end
  end

  puts "Moving packages to the package directory ..."
  FileUtils.mv(Dir.glob("*.{deb,rpm}"), PKG_DIR)

  puts "*****************************************************"
  puts "DING!"
  puts "*****************************************************"
end

task :install do
  pkg_name = "#{name}-#{version}-#{iteration}.x86_64.rpm"
  pkg_path = File.join(PKG_DIR, pkg_name)
  puts "Installing Uchiwa package: #{pkg_path} ..."
  run_command("rpm -i #{pkg_path}")
end

task :smoke do
  puts "Listing expected install directories ..."
  run_command("ls -l /opt/#{name}")
  run_command("ls -l /etc/sensu/uchiwa.json")
  run_command("ls -l /etc/init.d/#{name}")

  puts "Starting Uchiwa ..."
  run_command("/etc/init.d/#{name} start")
  run_command("sleep 10")
  run_command("cat /var/log/#{name}.log")
  run_command("cat /var/log/#{name}.err")
end

task :cleanup do
  puts "Removing the #{ASSET_DIR} directory..."
  run_command("rm -rf #{ASSET_DIR}")
end

task :default => [:install_deps, :build, :package, :install, :smoke, :cleanup]
