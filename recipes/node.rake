Bunchr::Software.new do |t|
  t.name = 'node'
  t.version = 'v0.10.28'

  install_prefix = "#{Bunchr.install_dir}/embedded"

  os   = t.ohai['os']
  arch = t.ohai['kernel']['machine']

  t.download_commands << "curl -O http://nodejs.org/dist/#{t.version}/node-#{t.version}.tar.gz"
  t.download_commands << "tar xfvz node-#{t.version}.tar.gz"

  # Ensure we run with Python 2.6 on Redhats < 6
  if t.ohai['platform_family'] == 'rhel' && t.ohai['platform_version'].to_f < 6
    python = 'python26'
  else
    python = 'python'
  end

  t.build_commands << "#{python} ./configure --prefix=#{install_prefix}"
  t.build_commands << 'make -j 1'

  t.install_commands << 'make install'

  CLEAN << install_prefix
end
