#
# Cookbook Name:: uchiwa-build
# Recipe:: default
#
# Copyright 2014, Simon Plourde
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

go_bin = '/usr/local/go/bin'
go_path = '/root/gopath'
uchiwa_src = "#{node['uchiwa-build']['workdir']}/assets/opt/uchiwa/src"
uchiwa_bin = "#{node['uchiwa-build']['workdir']}/assets/opt/uchiwa/bin"

%w(git ruby ruby-devel rubygems gcc rpm-build).each do |pkg|
  package pkg
end

gem_package 'fpm'

# Install Go
remote_file "#{Chef::Config[:file_cache_path]}/go.tar.gz" do
  source node['uchiwa-build']['golang']
  not_if { ::File.exists?("#{go_bin}/go") }
end

execute 'extract_go' do
  command "tar -C /usr/local -xzf #{Chef::Config[:file_cache_path]}/go.tar.gz"
  not_if { ::File.exists?("#{go_bin}/go") }
end

execute 'cross_compile_go' do
  command './make.bash'
  environment ({ 'GOOS' => 'linux', 'GOARCH' => '386' })
  cwd '/usr/local/go/src'
  not_if { ::File.exists?("#{go_bin}/linux_386") }
end

remote_file "#{Chef::Config[:file_cache_path]}/setup" do
  source 'https://rpm.nodesource.com/setup'
end

execute 'install_npm' do
  command "bash - #{Chef::Config[:file_cache_path]}/setup && yum install -y nodejs"
end

execute 'cleanup' do
  command 'rm -rf assets/opt/uchiwa/src && rm -f go_backend.tar.gz && rm -rf assets/opt/uchiwa/bin/uchiwa'
  cwd node['uchiwa-build']['workdir']
end

[ uchiwa_src, "#{go_path}/bin", "#{go_path}/src/github.com/sensu/uchiwa" ].each do |dir|
  directory dir do
    recursive true
  end
end

git "#{go_path}/src/github.com/sensu/uchiwa" do
  repository 'https://github.com/sensu/uchiwa.git'
  revision node['uchiwa-build']['uchiwa_version']
end

execute 'go_get' do
  command "#{go_bin}/go get -t -v ./..."
  cwd "#{go_path}/src/github.com/sensu/uchiwa"
  environment ({ 'GOPATH' => "/root/gopath:#{go_path}/src/github.com/sensu/uchiwa/Godeps/_workspace", 'PATH' => "#{ENV['PATH']}:#{go_path}/bin:#{go_path}/src/github.com/sensu/uchiwa/Godeps/_workspace/bin" })
end

execute 'install_bower' do
  command 'npm install --production && npm run postinstall'
  cwd "#{go_path}/src/github.com/sensu/uchiwa"
end

bash 'copy_public_folder' do
  code "cp -R #{go_path}/src/github.com/sensu/uchiwa/public #{uchiwa_src}/"
end

%w(i386 x86_64).each do |platform|
  if platform == 'i386'
    arch = '386'
  else
    arch = 'amd64'
  end

  execute "build_bin_#{platform}" do
    command "#{go_bin}/go build -o #{uchiwa_bin}/uchiwa"
    environment ({ 'GOOS' => 'linux', 'GOARCH' => arch, 'GOPATH' => "/root/gopath:#{go_path}/src/github.com/sensu/uchiwa/Godeps/_workspace" })
    cwd "#{go_path}/src/github.com/sensu/uchiwa"
  end

  execute "build_#{platform}_rpm" do
    command "fpm -s dir -t rpm -n 'uchiwa' -C assets --rpm-os linux --rpm-user uchiwa --rpm-group sensu -v #{node['uchiwa-build']['uchiwa_version']} --iteration #{node['uchiwa-build']['build_number']} --epoch 1 --license MIT --vendor 'Simon Plourde' --category 'Monitoring' --url 'https://github.com/sensu/uchiwa' --description 'Uchiwa, a Sensu dashboard, created by Simon Plourde.' -a #{platform} --before-install pkg_scripts/rpm/pre --after-install pkg_scripts/rpm/post --before-remove pkg_scripts/rpm/preun --after-remove pkg_scripts/rpm/postun --config-files /etc/sensu/uchiwa.json opt etc"
    cwd node['uchiwa-build']['workdir']
  end

  execute "build_#{platform}_deb" do
    command "fpm -s dir -t deb -n 'uchiwa' -C assets --rpm-os linux --rpm-user uchiwa --rpm-group sensu -v #{node['uchiwa-build']['uchiwa_version']} --iteration #{node['uchiwa-build']['build_number']} --license MIT --vendor 'Simon Plourde' --category 'Monitoring' --url 'https://github.com/sensu/uchiwa' --description 'Uchiwa, a Sensu dashboard, created by Simon Plourde.' -a #{platform} --after-install pkg_scripts/deb/postinst --before-remove pkg_scripts/deb/prerm --after-remove pkg_scripts/deb/postrm --config-files /etc/sensu/uchiwa.json opt etc"
    cwd node['uchiwa-build']['workdir']
  end
end

log 'Build completed!' do
  notifies :run, 'execute[cleanup]', :immediately
end
