Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # Use Vagrant's default synced folder to share files with /vagrant in all VMs
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  # Common provisioning for all nodes: update DNS settings and hosts file
  config.vm.provision "shell", inline: <<-SHELL
    # Update systemd-resolved configuration for DNS
    echo "[Resolve]
    DNS=8.8.8.8 1.1.1.1
    FallbackDNS=8.8.4.4 1.0.0.1" | sudo tee /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved

    # Update /etc/hosts idempotently
    grep -qF '192.168.56.101' /etc/hosts || echo '192.168.56.101 controlplane' | sudo tee -a /etc/hosts
    grep -qF '192.168.56.102' /etc/hosts || echo '192.168.56.102 node01' | sudo tee -a /etc/hosts
    grep -qF '192.168.56.103' /etc/hosts || echo '192.168.56.103 node02' | sudo tee -a /etc/hosts
  SHELL

  # Master node definition
  config.vm.define "controlplane" do |master|
    master.vm.hostname = "controlplane"
    master.vm.network "private_network", ip: "192.168.56.101"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    master.vm.provision "shell", path: "scripts/bootstrap_master.sh"
  end

  # Worker node definitions
  ["node01", "node02"].each do |name|
    config.vm.define name do |node|
      node.vm.hostname = name
      ip = (name == "node01") ? "192.168.56.102" : "192.168.56.103"
      node.vm.network "private_network", ip: ip
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 1024
        vb.cpus = 2
      end
      # Pass the master IP to workers via environment variables
      node.vm.provision "shell", path: "scripts/bootstrap_worker.sh", env: { "K3S_MASTER_IP" => "192.168.56.101" }
    end
  end
end
