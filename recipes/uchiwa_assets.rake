Bunchr::Software.new do |t|
  t.name = 'uchiwa_assets'

  t.work_dir = File.join(Dir.pwd, 'assets')

  t.install_commands << 'cp -f etc/init.d/uchiwa /etc/init.d/'
  t.install_commands << 'cp -f etc/default/uchiwa /etc/default/'
  t.install_commands << 'mkdir -p /etc/sensu'
  t.install_commands << 'cp -f etc/sensu/uchiwa.js /etc/sensu/'

  CLEAN << "/etc/init.d/uchiwa"
  CLEAN << "/etc/default/uchiwa"
  CLEAN << "/etc/sensu"
end
