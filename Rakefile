gem 'systemu', '2.5.2'
gem 'ohai', '6.22.0'
gem 'bunchr', '0.1.5'

require 'bunchr'
require 'fileutils'

if ENV['VAGRANT_BOX'].nil?
  raise "You do not want to run this on your local machine!"
end

if ENV['UCHIWA_VERSION'].nil?
  raise "Please set ENV['UCHIWA_VERSION'] and re-run."
end

## iteration will come from the jenkins $BUILD_NUMBER
if ENV['BUILD_NUMBER'].nil?
  raise "Please set ENV['BUILD_NUMBER'] and re-run."
end

Bunchr.load_recipes Dir['recipes/**/*.rake']

# put together all the Software objects from the *.rake recipes and bunch
# them together into whatever packages this platform supports (tar, rpm, deb)!
Bunchr::Packages.new do |t|
  t.name = 'uchiwa'
  t.version = ENV['UCHIWA_VERSION']
  t.iteration = ENV['BUILD_NUMBER']

  t.category = 'Monitoring'
  t.license  = 'Apache 2'
  t.vendor   = 'Heavy Water Operations, LLC.'
  t.url      = 'https://github.com/palourde/uchiwa'
  t.description = 'Uchiwa, a Sensu dashboard, created by Simon Plourde.'

  platform_family = t.ohai.platform_family

  case platform_family
  when 'windows'
    # nope
  else
    Bunchr.build_dir = '/tmp/build'
    Bunchr.install_dir = '/opt/uchiwa'

    case platform_family
    when 'debian'
      t.scripts[:after_install]  = 'pkg_scripts/deb/postinst'
      t.scripts[:before_remove]  = 'pkg_scripts/deb/prerm'
      t.scripts[:after_remove]   = 'pkg_scripts/deb/postrm'
    when 'rhel', 'fedora', 'suse'
      t.scripts[:before_install] = 'pkg_scripts/rpm/pre'
      t.scripts[:after_install]  = 'pkg_scripts/rpm/post'
      t.scripts[:before_remove]  = 'pkg_scripts/rpm/preun'
      t.scripts[:after_remove]   = 'pkg_scripts/rpm/postun'
    end

    t.include_software('node')
    t.include_software('uchiwa')
    t.include_software('uchiwa_assets')

    t.files << Bunchr.install_dir
    t.files << '/etc/init.d/uchiwa'
    t.files << '/etc/default/uchiwa'

    t.config_files << '/etc/sensu/uchiwa.json'
  end
end

task :default => ['packages:uchiwa']
