# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_URI = ENV['BOX_URI'] || "https://cloud-images.ubuntu.com/vagrant/saucy/20140126/saucy-server-cloudimg-amd64-vagrant-disk1.box"
SSH_PRIVKEY_PATH = ENV['SSH_PRIVKEY_PATH']

Vagrant.configure("2") do |config|
  # Setup virtual machine box. This VM configuration code is always executed.
  config.vm.box = "ubuntu_1310_daily"
  config.vm.box_url = BOX_URI

  # Use the specified private key path if it is specified and not empty.
  if SSH_PRIVKEY_PATH
      config.ssh.private_key_path = SSH_PRIVKEY_PATH
  end

  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |vb, override|
    vb.memory = 512
  end

  hosts = [1,2,3]

  hosts.each do |host_id|
    config.vm.define "host#{host_id}" do |host|
      host.vm.network "private_network", ip: "192.168.50.#{100+host_id}"
      host.vm.network :forwarded_port, guest: 22, host: (2250+host_id), id: 'ssh'
    end
  end
end
