#! /bin/bash

sudo rpm -Uvh https://yum.puppet.com/puppet/puppet-release-el-7.noarch.rpm;
sudo yum install puppetserver;
# sudo systemctl enable --now puppet
echo "export PATH=/opt/puppetlabs/bin:$PATH" >> .bash_profile;
source .bash_profile
sudo puppet config set dns_alt_names "puppet-master" --section main;
sudo systemctl enable --now puppetserver
