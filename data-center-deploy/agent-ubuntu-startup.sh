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

apt install ansible -y;
useradd -G admin ansible -m;
echo "ansible:ansible" | chpasswd;
# echo ansible | passwd --stdin ansible; # works on centos
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config;

mkdir /home/ansible/.ssh;
touch /home/ansible/.ssh/authorized_keys;
chmod 600 /home/ansible/.ssh/authorized_keys;
chmod 700 /home/ansible/.ssh;
chown ansible /home/ansible/.ssh;
chown ansible /home/ansible/.ssh/authorized_keys;


if [ $(hostname) == jenkins-server ]; then
#   apt install java-1.8.0 -y;
#  wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
#  deb https://pkg.jenkins.io/debian-stable binary/
#  apt-get update
#  apt-get install jenkins
#  apt install postgresql -y # needed to connect to db during test
#  systemctl enable jenkins;
#  systemctl start jenkins;
  apt install default-jdk -y
  apt install wget -y
  wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
  sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
  cat /etc/apt/sources.list.d/jenkins.list
  apt-get update;
  apt install jenkins -y;
  echo "Initial admin password is $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"
fi
