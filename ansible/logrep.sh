#!/bin/bash

#=======================
# functions
#=======================
function echo_message() {
	echo
	echo "################################################"
	echo "# ${1}"
	echo "################################################"
	echo
}

function error_text() {
	echo "Error Has Occurred !!"
	echo_message "${1}"
	echo
	echo "${USAGE}"
	exit
}


function chk_reporter() {
	case "${REPORTER}" in
		"h" )	N_REPORTER="Pampers"
				TO_ADDR="yoshimasa.hamada@***" ;;
		* )		error_text "Make sure to add the reporter's initial as a parameter." ;;
	esac
	}

function send_mail() {
	# init variables
	f_out=`basename ${OUT}`
	f_attc="${WORK_DIR}/attachment.part"
	f_head="${WORK_DIR}/header.part"
	f_body="${WORK_DIR}/body.part"
	f_mailtext="${WORK_DIR}/mail_text.txt"

	# compose email header
	cat <<- EOF > ${f_head}
	From: ${FROM_ADDR}
	To: ${TO_ADDR}
	Cc: ${CC_ADDR}
	Subject: [***] Command Execution Result
	Content-Type: multipart/mixed; boundary="SEPARATOR"

	EOF

	# compose message body
	cat <<- EOF > ${f_body}
	Content-Transfer-Encoding: UTF-8
	Content-Type: text/plain; charset="UTF-8"

	Hi, ${N_REPORTER}-san
	I've sent you the result of the following command.

	===========================
	${CMD}
	===========================

	Please check an attached file.

	EOF

	# conpose attachment file
	cat <<- EOF > ${f_attc}
	Content-Transfer-Encoding: base64
	Content-Type: text/plain; filename="${OUT}"
	Content-Disposition: attachment; filename="${f_out}"

	EOF
	cat ${OUT} | base64 	>> ${f_attc}

	cat ${f_head}			>  ${f_mailtext}
	echo '--SEPARATOR'		>> ${f_mailtext}
	cat ${f_body}			>> ${f_mailtext}
	echo '--SEPARATOR'		>> ${f_mailtext}
	cat ${f_attc}			>> ${f_mailtext}
	echo '--SEPARATOR--'	>> ${f_mailtext}

	cat ${f_mailtext} | sendmail -i -t

	res=$?
	if [ $res -eq 0 ]; then
		echo_message "Mail has been sent successfully !!"
	else
		error_text "Sending Email"
	fi
}


#=======================
# init variables
#=======================
SCR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
WORK_DIR="/var/tmp/***"
OUT="${WORK_DIR}/logrep_`date +"%Y%m%d-%H%M%S-%3N"`.txt"
ERR="${WORK_DIR}/logrep_err.txt"
MAIL_FLG=0
SORT_FLG=0
TO_ADDR=""
CMD=""
RSL_FLG=0
CC_ADDR="***@**"
SENDER=`whoami`
if [ "${SENDER}" = "hamadayoshim01" ]; then
	FROM_ADDR="yoshimasa.hamada@***"
else
	error_text "You are an unknown sender !!"
fi


umask 002

if ! [ -d ${WORK_DIR} ]; then
	mkdir -p ${WORK_DIR}
fi


#=======================
# options
#=======================
USAGE="Usage: ${0} [<options>] initial_of_reporter

	-a SERVER_ALIAS
		use Ansible Shell module
		e.g.
		-a rdp101		# for wtrrdp101z.prod.jp.local
		-a rdp1			# for wtrrdp10?z.prod.jp.local
		-a rdp2			# for wtrrdp20?z.prod.jp.local

		for more details, see the hosts file like this
			less ${ANSIBLE_HOSTS}
	-c COMMAND
		command to be executed
	-m	send an email the result whenever
	-h	show you usage of this script
	-s	sort by timestamp
"

while getopts "a:c:mhs" OPT_ITEM; do
	case ${OPT_ITEM} in
		a)	HOSTS=${OPTARG}
		;;
		c)	CMD=${OPTARG}
		;;
		m)	MAIL_FLG=1
		;;
		h)	echo "${USAGE}"
		;;
		s)	SORT_FLG=1
		;;
		\?)	error_text "Invalid Option Is Supplied"
		;;
	esac
done

shift $((OPTIND - 1))


#=======================
# main
#=======================
REPORTER=$1
chk_reporter

if [ -z "${CMD}" ]; then
	echo "Enter a command to be executed."
	read -r -p "$ " CMD
	echo
fi

# remove "$" at the beginning of line and "nkf" command at the end of line
CMD=`echo "${CMD}" | sed -E 's/^[^a-z]*//' | sed -E 's/ *\| *nkf +-w8 *$//'`
# sort by timestamp
if [ ${SORT_FLG} -eq 1 ]; then
	CMD=$(echo "${CMD} | $(cat ${SCR_DIR}/sort_by_timestamp.sh)")
fi

if [ -e ${ERR} ]; then
	rm -f ${ERR}
fi

# execute command and then convert strings to UTF-8
if [ "${HOSTS}" = "" ]; then
	eval "${CMD}" > ${OUT} 2> ${ERR}
	res=$?
	nkf --overwrite -w8 ${OUT}
else
	echo "hosts: ${HOSTS}" > ${WORK_DIR}/conf.yml
	# change charset to utf-8 and prepend BOM
	CMD="${CMD} | nkf -w8"
	echo "cmd: \"${CMD}\"" >> ${WORK_DIR}/conf.yml
	ansible-playbook --extra-vars="@${WORK_DIR}/conf.yml" ${SCR_DIR}/command_execution.yml |
		while read line; do
			if echo "${line}" | grep -E '^TASK: \[Show the result\]' > /dev/null ; then
				RSL_FLG=1
			fi

			if [ ${RSL_FLG} -eq 1 ]; then
				echo "${line}" >> ${OUT}
			else
				echo "${line}"
			fi
		done

	grep 'error' ${OUT} > ${ERR}

	sed -i -e '/result\.stdout_lines/d' \
		   -e '/^]/d' \
		   -r -e 's/^"(.*) *",?$/\1/' \
		   -e '/^PLAY RECAP/,$d' ${OUT}
	res=$?
fi

# check the size of the result file
char_cnt=`wc -c ${OUT} | cut -d' ' -f1`

#if [ ${char_cnt} -gt 3 ]; then
if  grep ^$'\xef'$'\xbb\xbf'. ${OUT} > /dev/null ; then
	echo_message "Search Text Is Found !!"
elif [ -s ${ERR} ]; then
	echo "An Error Has Occurred."
	echo "Make sure that the command is correct."
	echo "#################################"
	cat ${ERR}
	echo "#################################"
	exit
else
	echo_message "Search Text Is NOT Found !!"
	exit
fi


# mask personal information
if grep -E -l "^user_info\.getKaiinNo:.+" ${OUT} ; then
	echo_message "Personal Information is found"

	sed -i.bk -r -e '/^user_info\.getKaiinNo:.+/,+6d' -e 's/[^@ ]+@[^. ]+\.[^. ]+/XXX@XXX/g' ${OUT}
	if ! diff ${OUT} ${OUT}.bk ; then
		echo_message "Personal Infromation is masked !!"
		rm -v ${OUT}.bk
	else
		error_text "Masking Personal Information"
	fi
fi



if [ ${char_cnt} -gt 4000 -o ${MAIL_FLG} -eq 1 ]; then
	if [ ${char_cnt} -gt 10000000 ]; then		# greater than 10 MB
		gzip ${OUT}
		OUT=${OUT}.gz
		echo_message "GZIP compression is successful !!"
	fi
	ls -lh ${OUT}
	echo
	send_mail
else
	echo "#################################"
	cat ${OUT}
	echo "#################################"
fi

# remove old files
find "${WORK_DIR}" -name "logrep_*-*.*" -mmin +60 -exec rm -v {} \;
