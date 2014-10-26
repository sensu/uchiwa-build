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

case node['platform_family']
when 'rhel'
  if node['kernel']['machine'] == 'i686'
    arch = '.i386'
  else
    arch = ".#{node['kernel']['machine']}"
  end
  ext = '.rpm'

  pkg = "uchiwa-#{node['uchiwa-build']['uchiwa_version']}-#{node['uchiwa-build']['build_number']}#{arch}#{ext}"

  package pkg do
    options '--nogpgcheck'
    source "#{node['uchiwa-build']['workdir']}/#{pkg}"
  end

when 'debian'
  if node['kernel']['machine'] == 'x86_64'
    arch = '_amd64'
  else
    arch = '_i386'
  end
  ext = '.deb'

  pkg = "uchiwa_#{node['uchiwa-build']['uchiwa_version']}-#{node['uchiwa-build']['build_number']}#{arch}#{ext}"

  dpkg_package pkg do
    source "#{node['uchiwa-build']['workdir']}/#{pkg}"
  end

else
  raise "Unsupported Linux platform family #{platform_family}"
end

service 'uchiwa' do
  action :nothing
  supports :start => true, :stop => true, :restart => true
end

cookbook_file '/etc/sensu/uchiwa.json' do
  notifies :restart, 'service[uchiwa]', :immediately
end
