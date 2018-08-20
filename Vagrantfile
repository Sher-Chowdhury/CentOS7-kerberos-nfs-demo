# -*- mode: ruby -*-
# vi: set ft=ruby :


# https://github.com/hashicorp/vagrant/issues/1874#issuecomment-165904024
# not using 'vagrant-vbguest' vagrant plugin because now using bento images which has vbguestadditions preinstalled.
def ensure_plugins(plugins)
  logger = Vagrant::UI::Colored.new
  result = false
  plugins.each do |p|
    pm = Vagrant::Plugin::Manager.new(
      Vagrant::Plugin::Manager.user_plugins_file
    )
    plugin_hash = pm.installed_plugins
    next if plugin_hash.has_key?(p)
    result = true
    logger.warn("Installing plugin #{p}")
    pm.install_plugin(p)
  end
  if result
    logger.warn('Re-run vagrant up now that plugins are installed')
    exit
  end
end

required_plugins = ['vagrant-hosts', 'vagrant-share', 'vagrant-vbox-snapshot', 'vagrant-host-shell', 'vagrant-reload']
ensure_plugins required_plugins



Vagrant.configure(2) do |config|

  config.vm.define "kerberos_server" do |kerberos_server_config|
    kerberos_server_config.vm.box = "bento/centos-7.5"
    kerberos_server_config.vm.hostname = "kdc.cb.net"
    # https://www.vagrantup.com/docs/virtualbox/networking.html
    kerberos_server_config.vm.network "private_network", ip: "10.0.9.11", :netmask => "255.255.255.0", virtualbox__intnet: "intnet1"

    kerberos_server_config.vm.provider "virtualbox" do |vb|
      vb.gui = true
      vb.memory = "1024"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.name = "centos7_kerberos_server"
    end

    kerberos_server_config.vm.provision "shell", path: "scripts/install-rpms.sh", privileged: true
    kerberos_server_config.vm.provision "shell", path: "scripts/setup-kdc-authentication-system.sh", privileged: true
  end

  config.vm.define "nfs_storage" do |nfs_storage_config|
    nfs_storage_config.vm.box = "bento/centos-7.5"
    nfs_storage_config.vm.hostname = "nfs-storage.cb.net"
    # https://www.vagrantup.com/docs/virtualbox/networking.html
    nfs_storage_config.vm.network "private_network", ip: "10.0.9.12", :netmask => "255.255.255.0", virtualbox__intnet: "intnet1"

    nfs_storage_config.vm.provider "virtualbox" do |vb|
      vb.gui = true
      vb.memory = "1024"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.name = "centos7_kerberos_nfs_storage"
    end

    nfs_storage_config.vm.provision "shell", path: "scripts/install-rpms.sh", privileged: true
    nfs_storage_config.vm.provision "shell", path: "scripts/setup-kerberos-client.sh", privileged: true
    nfs_storage_config.vm.provision "shell", path: "scripts/nfs_server_setup.sh", privileged: true
#    nfs_storage_config.vm.provision "shell", path: "scripts/nfs_server_kerberos_integration.sh", privileged: true
  end


  config.vm.define "nfs_client" do |nfs_client_config|
    nfs_client_config.vm.box = "bento/centos-7.5"
    nfs_client_config.vm.hostname = "nfs-client.cb.net"
    nfs_client_config.vm.network "private_network", ip: "10.0.9.13", :netmask => "255.255.255.0", virtualbox__intnet: "intnet1"

    nfs_client_config.vm.provider "virtualbox" do |vb|
      vb.gui = true
      vb.memory = "1024"
      vb.cpus = 2
      vb.name = "centos7_kerberos_nfs_client"
    end

    nfs_client_config.vm.provision "shell", path: "scripts/install-rpms.sh", privileged: true
    nfs_client_config.vm.provision "shell", path: "scripts/setup-kerberos-client.sh", privileged: true
    nfs_client_config.vm.provision "shell", path: "scripts/nfs_client_setup.sh", privileged: true
#    nfs_client_config.vm.provision "shell", path: "scripts/nfs_client_kerberos_integration.sh", privileged: true
  end

    # this line relates to the vagrant-hosts plugin, https://github.com/oscar-stack/vagrant-hosts
  # it adds entry to the /etc/hosts file.
  # this block is placed outside the define blocks so that it gts applied to all VMs that are defined in this vagrantfile.
  config.vm.provision :hosts do |provisioner|
    provisioner.add_host '10.0.9.11', ['kdc.cb.net']
    provisioner.add_host '10.0.9.12', ['nfs-storage.cb.net']
    provisioner.add_host '10.0.9.13', ['nfs-client.cb.net']
  end
end