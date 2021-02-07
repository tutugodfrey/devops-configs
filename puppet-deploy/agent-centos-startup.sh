#! /bin/bash

sudo rpm -Uvh https://yum.puppet.com/puppet/puppet-release-el-7.noarch.rpm;
sudo yum install puppet-agent -y
echo "export PATH=/opt/puppetlabs/bin:$PATH" >> .bash_profile;
source .bash_profile;
sudo $(which puppet) config set server 'puppet-master' --section main;
sudo $(which puppet) resource service puppet ensure=running enable=true;
