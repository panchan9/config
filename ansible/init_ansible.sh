#!/bin/bash
ANS_DIR="${HOME}/ansible-common/inv"
ANS_HOSTS="${ANS_DIR}/prod-hosts"

# check if there is a git repository
if ! [ -f ${HOME}/git/pampers/ansible/prod-hosts ]; then
	echo 'Please set "~/git/pampers/ansible/prod-hosts".'
	echo 'You can execute the following command to do that'
	echo 'mkdir ~/git && cd ~/git'
	echo '### make sure to exist SSH keys and register it to Bitbucket ###'
	echo 'git clone ssh://git@git.rakuten-it.com:7999/devnull/pampers.git'
	exit
fi

# make a directory for ansible
if ! [ -d ${ANS_DIR} ]; then
	echo '# make a directory for ansible'
	mkdir -pv ${ANS_DIR}
fi

# create a symbolic link
if ! [ -e ${ANS_HOSTS} ]; then
	echo '# create a symbolic link'
	ln -s ~/git/pampers/ansible/prod-hosts ${ANS_HOSTS}
fi

# set a variable for ANSIBLE_HOSTS
if ! grep 'ANSIBLE_HOSTS' ~/.bashrc > /dev/null ; then
	echo '# set a variable for ANSIBLE_HOSTS'
	echo 'export ANSIBLE_HOSTS=~/ansible-common/inv/prod-hosts' >> ~/.bashrc
	source ~/.bashrc
fi


# register SSH public keys in each server
SERVER_LIST=`sed -E 's/.*=(.*)$/\1/' ${ANSIBLE_HOSTS} | grep -E '^[a-z].*\.prod\.jp\.local$'`

echo '# start to set up SSH publick-key'
for server in ${SERVER_LIST}; do
	cat ~/.ssh/id_rsa.pub | ssh ${server} 'umask 077; mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys'
	echo "complete [${server}]"
done
