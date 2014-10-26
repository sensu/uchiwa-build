require 'spec_helper'

describe 'Uchiwa package' do
  it 'installed' do
    expect(package 'uchiwa').to be_installed
  end
  it 'added uchiwa user' do
    expect(user 'uchiwa').to exist
  end
  it 'added sensu group' do
    expect(group 'uchiwa').to exist
  end
  it 'added init script' do
    expect(file '/etc/init.d/uchiwa').to be_file
  end
end

describe 'Uchiwa service' do
  if os[:family] != 'redhat' && !os[:release].start_with?('5')
    it 'running' do
      expect(service 'uchiwa').to be_running
    end
  end
  it 'listen on port 3000' do
    expect(port 3000).to be_listening
  end
  it 'not have errors' do
    expect((command 'cat /var/log/uchiwa.err|wc -l').stdout).to eq "0\n"
  end
end
