#!/bin/bash

readonly SRV_PTN='[a-z]+[0-9]{3}z'
readonly SCR_DIR=$(cd $(dirname $0); pwd)
readonly ANS_HOSTS="${SCR_DIR}/../ansible/prod-hosts"
readonly TMP="${ANS_HOSTS}.tmp"
readonly ROOT_DIR='/R_SVRLOG'

# backup the ansible hosts file
cp $ANS_HOSTS $TMP


servers=( $(sed -n -E "/${SRV_PTN}/s/.*=(${SRV_PTN}).*/\1/p" ${ANS_HOSTS}) )
server_types=( $(echo ${servers[@]} | tr ' ' '\n' | sed -E 's/[0-9].*//' | sort | uniq) )


function output_message() {
	local _message="$1"
	echo
	echo '###################################################'
	echo " ${_message}"
	echo '###################################################'
	echo
}

function yes_or_no() {
	echo '(Please enter "yes" or "no")'
	while true; do
		read ANSWER
		case ${ANSWER} in
			yes )
				break
				;;
			no )
				echo "Exit."
				exit 1
				;;
			* )
				echo '(Please enter "yes" or "no")'
				;;
		esac
	done
}

function generate_server_list() {
	local _st=$1
	shift
	local _servers=($@)
	server_list=()

	for _server in ${_servers[@]}; do
		if [[ $_server = ${_st}[0-9]* ]]; then
			server_list+=($_server)
		fi
	done
}

function insert_new_servers() {
	local _idx=$1
	local _buffer=''

	output_message "set up SSH keys"
	for (( i=${_idx}; i < ${_cur_length}; i++ )); do
		local _new_server="${_current[${i}]}.prod.jp.local"
		_buffer+="$( echo $_new_server | sed -E 's/^[a-z]{3}(.*)z.*$/\1/' ) ansible_ssh_host=${_new_server}\n"
		cat ~/.ssh/id_rsa.pub | ssh ${_new_server} 'umask 077; mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys'
	done

	_buffer="$(echo ${_buffer} | sed -e 's/\\n$//')"
	local _last_defined_server=${_defined[$(( $_idx - 1 ))]}
	sed -i -e "/${_last_defined_server}/a ${_buffer}" ${TMP}
}


for _st in ${server_types[@]}; do
	# generate associative array of servers defined in $ANS_HOSTS
	_defined=()
	generate_server_list ${_st} ${servers[@]}
	_defined=( ${server_list[@]} )

	# generate associative array of existing servers
	_current=()
	for _server in ${ROOT_DIR}/${_st}[0-9]*; do
		_current+=( $(echo $_server | sed -e 's!.*/!!') )
	done
	#generate_server_list ${_st} ${_current[@]}
	#current_servers[$_st]=${server_list[@]}

	# compare the number of each servers
	_def_length=${#_defined[@]}
	_cur_length=${#_current[@]}
	if [ $_def_length -eq $_cur_length ]; then
		continue
	fi

	output_message "A new server of ${_st} has been detected"
	echo "- A list of servers which are already defined in \$ANSIBLE_HOSTS"
	echo ${_defined[@]}
	echo "=="
	echo "- A list of servers which exist under /R_SVRLOG directory"
	echo ${_current[@]}
	echo

	for (( i=0; i < ${_cur_length}; i++ )); do
		if [ -z ${_defined[$i]} ]; then
			insert_new_servers ${i}
			continue 2
		fi
	done
done

diff $ANS_HOSTS $TMP
_rc=$?
if [ $_rc -eq 0 ]; then
	output_message "No any new servers"
	exit 0
fi

output_message "A difference of \$ANSIBLE_HOSTS is like above"

output_message "Are you sure to update \$ANSIBLE_HOSTS ?"
yes_or_no

mv -iv $TMP $ANS_HOSTS 
