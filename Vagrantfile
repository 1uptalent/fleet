# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_URI = ENV['BOX_URI'] || "http://cloud-images.ubuntu.com/vagrant/raring/current/raring-server-cloudimg-amd64-vagrant-disk1.box"
SSH_PRIVKEY_PATH = ENV['SSH_PRIVKEY_PATH']

# A script to upgrade from the 12.04 kernel to the raring backport kernel (3.8)
# and install docker.
$script = <<SCRIPT
# The username to add to the docker group will be passed as the first argument
# to the script.  If nothing is passed, default to "vagrant".
user="$1"
if [ -z "$user" ]; then
    user=vagrant
fi

# Adding an apt gpg key is idempotent.
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9

# Creating the docker.list file is idempotent, but it may overwrite desired
# settings if it already exists.  This could be solved with md5sum but it
# doesn't seem worth it.
echo 'deb http://get.docker.io/ubuntu docker main' > \
    /etc/apt/sources.list.d/docker.list

# Update remote package metadata.  'apt-get update' is idempotent.
apt-get update -q

# Dependencies for aufs
apt-get install linux-image-extra-`uname -r`

# Install docker.  'apt-get install' is idempotent.
apt-get install -q -y lxc-docker

usermod -a -G docker "$user"

# Make the kernel support memory and swap accounting
sed -i -e 's/GRUB_CMDLINE_LINUX=.*$/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' /etc/default/grub
update-grub 

# Make docker listen on a tcp socket
sed -i -e 's/DOCKER_OPTS=.*$/DOCKER_OPTS="-b docker0 -dns _DOCKER0_IP_ -H tcp:\\/\\/0.0.0.0:4243 -H unix:\\/\\/\\/var\\/run\\/docker.sock"/' /etc/init/docker.conf

# Map the current directory with the same path on the VM
mkdir -p `dirname _HOST_DIR_`
ln -sfn /vagrant _HOST_DIR_

wget http://openvswitch.org/releases/openvswitch-2.0.0.tar.gz
apt-get install -y build-essential fakeroot libssl-dev
tar xzvf openvswitch-2.0.0.tar.gz
cd openvswitch-2.0.0/
apt-get install -y debhelper autoconf automake python-all python-qt4 python-zopeinterface python-twisted-conch
DEB_BUILD_OPTIONS='parallel=2 nocheck' fakeroot debian/rules binary
cd ..
dpkg -i openvswitch-datapath-dkms_*.deb openvswitch-switch_*.deb openvswitch-common_*.deb

_CONFIGURE_GRE_TUNNELS_

SCRIPT

# We need to install the virtualbox guest additions *before* we do the normal
# docker installation.  As such this script is prepended to the common docker
# install script above.  This allows the install of the backport kernel to
# trigger dkms to build the virtualbox guest module install.
$vbox_script = <<VBOX_SCRIPT + $script
# Install the VirtualBox guest additions if they aren't already installed.
if [ ! -d /opt/VBoxGuestAdditions-4.3.6/ ]; then
    # Update remote package metadata.  'apt-get update' is idempotent.
    apt-get update -q

    # Kernel Headers and dkms are required to build the vbox guest kernel
    # modules.
    #apt-get install -q -y linux-headers-generic-lts-raring dkms

    echo 'Downloading VBox Guest Additions...'
    wget -cq http://dlc.sun.com.edgesuite.net/virtualbox/4.3.6/VBoxGuestAdditions_4.3.6.iso
    echo "95648fcdb5d028e64145a2fe2f2f28c946d219da366389295a61fed296ca79f0  VBoxGuestAdditions_4.3.6.iso" | sha256sum --check || exit 1

    mount -o loop,ro /home/vagrant/VBoxGuestAdditions_4.3.6.iso /mnt
    /mnt/VBoxLinuxAdditions.run --nox11
    umount /mnt
fi
VBOX_SCRIPT

$vbox_script.gsub! /_HOST_DIR_/, `pwd`

Vagrant.configure("2") do |config|

  # Setup virtual machine box. This VM configuration code is always executed.
  config.vm.box_url = BOX_URI

  # Use the specified private key path if it is specified and not empty.
  if SSH_PRIVKEY_PATH
      config.ssh.private_key_path = SSH_PRIVKEY_PATH
  end

  config.ssh.forward_agent = true

  config.vm.network :forwarded_port, guest: 22, host: 2222, auto_correct: true, id: 'ssh'

  config.vm.provider :virtualbox do |vb, override|
    vb.memory = 512
  end

  config.vm.define "host1" do |host|
    docker0_ip = "172.16.42.1"
    script = $vbox_script.gsub(/_CONFIGURE_GRE_TUNNELS_/, File.read('bridge_host_1.sh'))
                         .gsub(/_DOCKER0_IP_/, docker0_ip)
    host.vm.box = "host1"
    host.vm.network "private_network", ip: "192.168.50.101"
    host.vm.provision :shell, :inline => script
  end
  config.vm.define "host2" do |host|
    docker0_ip = "172.16.42.2"
    script = $vbox_script.gsub(/_CONFIGURE_GRE_TUNNELS_/, File.read('bridge_host_2.sh'))
                         .gsub(/_DOCKER0_IP_/, docker0_ip)
    host.vm.box = "host2"
    host.vm.network "private_network", ip: "192.168.50.102"
    host.vm.provision :shell, :inline => script
  end
  config.vm.define "host3" do |host|
    docker0_ip = "172.16.42.3"
    script = $vbox_script.gsub(/_CONFIGURE_GRE_TUNNELS_/, File.read('bridge_host_3.sh'))
                         .gsub(/_DOCKER0_IP_/, docker0_ip)
    host.vm.box = "host3"
    host.vm.network "private_network", ip: "192.168.50.103"
    host.vm.provision :shell, :inline => script
  end

  # Vagrant::VERSION >= "1.1.0" and Vagrant.configure("2") do |config|
  #   (9000..9020).each do |port|
  #     config.vm.network :forwarded_port, :host => port, :guest => port
  #   end
  #   config.vm.network :forwarded_port, :host => 4243, :guest => 4243
  # end

  
end
