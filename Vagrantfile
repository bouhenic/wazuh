Vagrant.configure(2) do |config|

	# before you must install these plugins to speed up vagrant provisionning
  # vagrant plugin install vagrant-faster
  # vagrant plugin install vagrant-cachier

  config.cache.auto_detect = true
	# Set some variables
  etcHosts = ""
  clickhouse = ""
  monitoring = ""
  superset = ""
  logs = ""

  case ARGV[0]
    when "provision", "up"


  end

	# some settings for common server (not for haproxy)
  common = <<-SHELL
  sudo apt update -qq 2>&1 >/dev/null
  sudo apt install -y -qq iftop curl software-properties-common git vim tree net-tools telnet git 2>&1 >/dev/null
  #sudo apt install -y -qq iftop curl openjdk-11-jre-headless software-properties-common git vim tree net-tools telnet git 2>&1 >/dev/null
  sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
  sudo systemctl restart sshd
  SHELL

  docker = <<-SHELL
  curl -fsSL https://get.docker.com -o get-docker.sh 2>&1 >/dev/null
  sudo sh get-docker.sh 2>&1 >/dev/null
  sudo usermod -aG docker vagrant
  sudo service docker start
  sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod 755 /usr/local/bin/docker-compose
  SHELL

  config.vm.box = "ubuntu/jammy64"
  config.vm.box_url = "ubuntu/jammy64"

	# set servers list and their parameters
	NODES = [
  	{ :hostname => "wazidx1", :ip => "192.168.56.81", :cpus => 4, :mem => 6000, :type => "server" },
  	{ :hostname => "wazagent1", :ip => "192.168.56.82", :cpus => 2, :mem => 2048, :type => "agent" },
  	{ :hostname => "wazagent2", :ip => "192.168.56.83", :cpus => 2, :mem => 2048, :type => "agent" }
	]

	# define /etc/hosts for all servers
  NODES.each do |node|
			etcHosts += "echo '" + node[:ip] + "   " + node[:hostname] + "'>> /etc/hosts" + "\n"
  end #end NODES

	# run installation
  NODES.each do |node|
    config.vm.define node[:hostname] do |cfg|
      cfg.vm.hostname = node[:hostname]
      cfg.vm.network "private_network", ip: node[:ip]
      #if node[:type] == "clickhouse"
      #  cfg.disksize.size = '110GB'
      #end
      cfg.vm.provider "virtualbox" do |v|
	v.customize [ "modifyvm", :id, "--cpus", node[:cpus] ]
        v.customize [ "modifyvm", :id, "--memory", node[:mem] ]
        v.customize [ "modifyvm", :id, "--natdnshostresolver1", "on" ]
        #v.customize [ "modifyvm", :id, "--natdnsproxy1", "on" ]
        v.customize [ "modifyvm", :id, "--name", node[:hostname] ]
	v.customize [ "modifyvm", :id, "--ioapic", "on" ]
        v.customize [ "modifyvm", :id, "--nictype1", "virtio" ]
      end #end provider
			
			#for all
      cfg.vm.provision :shell, :path => "install_newton.sh"
      cfg.vm.provision :shell, :inline => etcHosts
			cfg.vm.provision :shell, :inline => common
      cfg.vm.provision :shell, :path => "install_node_exporter.sh"


      if node[:type] == "server"
        cfg.vm.provision :shell, :path => "install_wazuh_server.sh"
      end

      if node[:type] == "agent"
        cfg.vm.provision :shell, :path => "install_wazuh_agent.sh"
      end


    end # end config
  end # end nodes

end 



