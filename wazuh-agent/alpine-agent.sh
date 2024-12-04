wget -O /etc/apk/keys/alpine-devel@wazuh.com-633d7457.rsa.pub https://packages-dev.wazuh.com/key/alpine-devel%40wazuh.com-633d7457.rsa.pub 
echo 'https://packages.wazuh.com/4.x/alpine/v3.12/main' >> /etc/apk/repositories
apk update && apk add wazuh-agent
export WAZUH_MANAGER="192.168.100.2" && sed -i "s|MANAGER_IP|$WAZUH_MANAGER|g" /var/ossec/etc/ossec.conf
/var/ossec/bin/wazuh-control start