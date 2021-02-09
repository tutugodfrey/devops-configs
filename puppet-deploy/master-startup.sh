#! /bin/bash

rpm -Uvh https://yum.puppet.com/puppet/puppet-release-el-7.noarch.rpm;
yum install puppetserver -y;
yum install bind-utils -y;
systemctl enable --now puppet;
systemctl enable --now puppetserver;
echo "export PATH=/opt/puppetlabs/bin:$PATH" >> .bash_profile;
source .bash_profile

echo "10.20.0.3 puppet-host-ubuntu" >> /etc/hosts;
echo "10.20.0.4 puppet-host-centos" >> /etc/hosts;
puppet config set dns_alt_names "puppet" --section main;
puppet config set server 'puppet' --section main

yum install nginx -y;
systemctl enable --now nginx;

until curl puppet-host-centos; do echo waiting for myservice; sleep 3; done
until curl puppet-host-ubuntu; do echo waiting for myservice; sleep 3; done
puppetserver ca list >> /certs.txt

# /opt/puppetlabs/bin/puppetserver ca setup;

puppetserver ca sign --certname puppet-host-ubuntu.c.todo-er.internal,puppet-host-centos.c.todo-er.internal

cd /etc/puppetlabs/code/environments/production/manifests;
cat >> testconfig.pp <<EOF
class nginxconfig {
  package {"vsftpd":
    ensure => installed,
  }
  service {"vsftpd":
    enable => true,
    #start => true
  }
}

include nginxconfig
EOF

puppet apply testconfig.pp

