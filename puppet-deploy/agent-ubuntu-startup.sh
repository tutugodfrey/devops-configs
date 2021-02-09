#! /bin/bash

wget https://apt.puppetlabs.com/puppet-release-bionic.deb;
dpkg -i puppet-release-bionic.deb;
apt update;
apt install puppet-agent -y;
echo "export PATH=/opt/puppetlabs/bin:$PATH" >> ~/.profile
source ~/.profile;
echo '10.20.0.2   puppet' >> /etc/hosts
puppet config set server 'puppet' --section main;
puppet resource service puppet ensure=running enable=true;


until curl http://10.20.0.2; do echo waiting for master to be ready; sleep 3; done
# until nslookup puppet; do echo waiting for myservice; sleep 3; done
puppet agent -t;

apt install nginx -y;
systemctl enable --now nginx;
sleep 60s;
puppet agent -t;
systemctl status vsftpdd;
