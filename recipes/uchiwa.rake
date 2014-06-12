Bunchr::Software.new do |t|
  t.name = 'uchiwa'

  if ENV['UCHIWA_VERSION'].nil?
    raise "Must set env var 'UCHIWA_VERSION'"
  end
  t.version = ENV['UCHIWA_VERSION']

  install_prefix = "#{Bunchr.install_dir}/usr/src/uchiwa"

  t.download_commands << "curl -L -O https://github.com/palourde/uchiwa/archive/#{t.version}.tar.gz"
  t.download_commands << "tar xfvz #{t.version}.tar.gz"

  t.build_commands << "mkdir -p #{install_prefix}"
  t.build_commands << "cp -r . #{install_prefix}/"

  CLEAN << install_prefix
end
