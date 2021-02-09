#! /bin/bash

rpm -Uvh https://yum.puppet.com/puppet/puppet-release-el-7.noarch.rpm;
yum install puppet-agent -y
yum install bind-utils -y;
echo "export PATH=/opt/puppetlabs/bin:$PATH" >> .bash_profile;
source .bash_profile;
echo '10.20.0.2   puppet' >> /etc/hosts
puppet config set server 'puppet' --section main;
puppet resource service puppet ensure=running enable=true;

until curl http://10.20.0.2; do echo waiting for master to be ready; sleep 3; done
puppet agent -t;

yum install nginx -y;
systemctl enable --now nginx

# until nslookup puppet; do echo waiting for myservice; sleep 3; done

sleep 60s;
puppet agent -t;
systemctl status vsftpd;

