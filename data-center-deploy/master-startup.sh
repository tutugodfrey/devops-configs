#! /bin/bash


yum install epel-release -y;
yum install ansible -y;
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

useradd -G wheel ansible -m;
echo ansible | passwd --stdin ansible;
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config;

mkdir /home/ansible/.ssh;
chmod 700 /home/ansible/.ssh;
ssh-keygen -t rsa -b 2048 -f /home/ansible/.ssh/id_ansible -C ansible;
cp home/ansible/.ssh/id_ansible* /etc/;
cat 'eval $(ssh-agent)' >> /home/ansible/.bashrc;
cat 'ssh-add /home/ansible/.ssh/id_ansible' >> /home/ansible/.bashrc;
source /home/ansible/.bashrc;


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

cat >> copysshkey.pp <<EOF
class copy_ssh {
  file {'/home/ansible/.ssh/authorized_keys':
    content => 'ANSIBLE_SSH_KEY'
  }
}

include copy_ssh
EOF

sed -i "s|ANSIBLE_SSH_KEY|$(cat /home/ansible/.ssh/id_ansible.pub)|" copysshkey.pp;

puppet apply testconfig.pp
puppet apply copysshkey.pp
# set server as ansible controller
# until ssh-copy-id -i ansible.pub ansible@puppet-host-centos; do echo waiting for centos host to be ready; sleep 3; done;
# until ssh-copy-id -i ansible.pub ansible@puppet-host-ubuntu; do echo waiting for ubuntu host to be ready; sleep 3; done;

cat >> /home/ansible/inventory <<EOF
puppet-host-ubuntu
puppet-host-centos

EOF

cat >> /home/ansible/ansible.cfg <<EOF
[default]
root_user = ansible
host_key_checking = false
inventory = inventory

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

EOF

ansible all -i inventory -m shell -a 'whoami' &2> /etc/ansible_answer.txt

# Automatically accept ssh fingerprint
# ssh -o "StrictHostKeyChecking no" 192.168.1.5
