Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  k3s_token = "your_secure_token_here" # Predefined cluster token

  # Common provisioning for all nodes
  config.vm.provision "shell", inline: <<-SHELL
    # Update systemd-resolved
    echo "[Resolve]
    DNS=8.8.8.8 1.1.1.1
    FallbackDNS=8.8.4.4 1.0.0.1" | sudo tee /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved

    # Update hosts file
    grep -qF '192.168.56.101' /etc/hosts || echo '192.168.56.101 controlplane' | sudo tee -a /etc/hosts
    grep -qF '192.168.56.102' /etc/hosts || echo '192.168.56.102 node01' | sudo tee -a /etc/hosts
    grep -qF '192.168.56.103' /etc/hosts || echo '192.168.56.103 node02' | sudo tee -a /etc/hosts
  SHELL

  # Master node
  config.vm.define "controlplane" do |master|
    master.vm.hostname = "controlplane"
    master.vm.network "private_network", ip: "192.168.56.101"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    master.vm.provision "shell", path: "scripts/bootstrap_master.sh", env: { "K3S_TOKEN" => k3s_token }
  end

  # Worker nodes
  ["node01", "node02"].each do |name|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: "192.168.56.#{name == 'node01' ? '102' : '103'}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 1024
        vb.cpus = 2
      end
      node.vm.provision "shell", path: "scripts/bootstrap_worker.sh", env: { 
        "K3S_TOKEN" => k3s_token,
        "K3S_URL" => "https://192.168.56.101:6443"
      }
    end
  end
end