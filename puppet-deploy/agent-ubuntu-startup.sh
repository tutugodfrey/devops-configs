#! /bin/bash

wget https://apt.puppetlabs.com/puppet-release-bionic.deb;
sudo dpkg -i puppet-release-bionic.deb;
sudo apt update;
sudo apt install puppet-agent;
echo "export PATH=/opt/puppetlabs/bin:$PATH" >> .profile
source .profile;
sudo $(which puppet) config set server 'puppet-master' --section main;
sudo $(which puppet) resource service puppet ensure=running enable=true;
