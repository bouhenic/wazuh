#!/usr/bin/bash


curl -sO https://packages.wazuh.com/4.9/wazuh-install.sh
curl -sO https://packages.wazuh.com/4.9/config.yml

echo '
nodes:
  # Wazuh indexer nodes
  indexer:
    - name: wazidx1
      ip: "192.168.56.81"

  server:
    - name: wazidx1
      ip: "192.168.56.81"

  # Wazuh dashboard nodes
  dashboard:
    - name: wazidx1
      ip: "192.168.56.81"
'> config.yml 

bash wazuh-install.sh --generate-config-files

curl -sO https://packages.wazuh.com/4.9/wazuh-install.sh

bash wazuh-install.sh --wazuh-indexer wazidx1

bash wazuh-install.sh --start-cluster

tar -axf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt -O | grep -P "\'admin\'" -A 1

bash wazuh-install.sh --wazuh-server wazidx1

bash wazuh-install.sh --wazuh-dashboard wazidx1

systemctl restart wazuh-dashboard

