#!/bin/bash

. /www/oraenv.sh

BASE_DIR=${HOME}
SCHEMA=$1
TABLE=$2
TMP_DESC="${BASE_DIR}/tmp_desc_${TABLE}.sql"
TMP_INDEX="${BASE_DIR}/tmp_index_${TABLE}.sql"
TMP_ORA="${BASE_DIR}/tmp_ora_${TABLE}.sql"
TMP_CP="${BASE_DIR}/tmp_cp_${TABLE}.sql"
OUT_FILE="${BASE_DIR}/${TABLE}.sql"
DB_NAME="SBX_TRVL"
LINE_CNT=0
INDEX_CNT=0

SQLPLUS="sqlplus -s readonly/`cat /web/etc/readonly_pass`r0@travel"


# get TABLE definition information
${SQLPLUS} << EOF > ${TMP_DESC}
DESC ${SCHEMA}.${TABLE}
EOF

sed -i -e '1,2d' -e '/^$/d' ${TMP_DESC} 
cat ${TMP_DESC} > ${TMP_ORA}

# get INDEX information
${SQLPLUS} << EOF > ${TMP_INDEX}
set pages 0
set feedback off

SELECT  INDEX_NAME
||','|| COLUMN_POSITION
||','|| COLUMN_NAME
  FROM ALL_IND_COLUMNS
 WHERE TABLE_NAME = '${TABLE}'
;
EOF

sed -i -e '/^$/d' ${TMP_INDEX}


echo -n "
CREATE MULTISET TABLE ${DB_NAME}.ORA_${TABLE}
     , NO FALLBACK
     , NO BEFORE JOURNAL
     , NO AFTER JOURNAL
     , CHECKSUM = DEFAULT
     , DEFAULT MERGEBLOCKRATIO
     (
" > ${TMP_ORA}

echo -n "
CREATE MULTISET TABLE ${DB_NAME}.CP_${TABLE}_WK_EX
     , NO FALLBACK
     , NO BEFORE JOURNAL
     , NO AFTER JOURNAL
     , CHECKSUM = DEFAULT
     , DEFAULT MERGEBLOCKRATIO
     (
" > ${TMP_CP}

while read line; do
	LINE=""
	COLUMN=""
	DATA_TYPE=""
	SIZE=""
	NULLABLE=""
	COMMA=""
	DATA_TYPE_BUF=""
	DOUBLE_SIZE=""

	LINE_CNT=$((LINE_CNT + 1))
	if [ ${LINE_CNT} -eq 1 ]; then
		COMMA=" "
	else
		COMMA=","
	fi
	
	LINE=`echo ${line} | sed -e 's/NOT NULL //' -r -e 's/^(\w+) +(\w+)(\(.*\))*$/\1#\2#\3/'`
	COLUMN=`echo ${LINE}	| awk -F'#' '{print $1}'`
	DATA_TYPE=`echo ${LINE} | awk -F'#' '{print $2}' | sed -E 's/^(.+)2$/\1/'`
	SIZE=`echo ${LINE}		| awk -F'#' '{print $3}'`
	if echo ${line} | grep 'NOT NULL' > /dev/null ; then
		NULLABLE=" NOT NULL"
	fi

	# generate "CREATE [ORA_] TABLE" statemente
	case ${DATA_TYPE} in
		"CHAR" | "VARCHAR" ) DATA_TYPE_BUF="${DATA_TYPE}`echo ${SIZE} | sed -r -e 's/^\(([0-9]+) .*\)$/(\1)/'`"
						     DATA_TYPE_BUF="${DATA_TYPE_BUF} CHARACTER SET UNICODE CASESPECIFIC" ;;
		"DATE"			   ) DATA_TYPE_BUF="${DATA_TYPE} FORMAT 'YYYY-MM-DD'" ;;
		"NUMBER"		   ) DATA_TYPE_BUF="${DATA_TYPE}${SIZE}" ;;
		*				   ) : ;;
	esac

	printf "%6s %-30s %s%s\n" "${COMMA}" "${COLUMN}" "${DATA_TYPE_BUF}" "${NULLABLE}" >> ${TMP_ORA}

	# generate "CREATE [CP_] TABLE" statement
	case ${DATA_TYPE} in
		"DATE"	 ) DATA_TYPE_BUF="TIMESTAMP(0)" ;;
		"NUMBER" ) DATA_TYPE_BUF="DECIMAL${SIZE}" ;;
		* ) : ;;
	esac

	printf "%6s %-30s %s%s\n" "${COMMA}" "${COLUMN}" "${DATA_TYPE_BUF}" "${NULLABLE}" >> ${TMP_CP}

done < ${TMP_DESC}

echo "     )" >> ${TMP_ORA}
echo "     )" >> ${TMP_CP}

if [ -s ${TMP_INDEX} ]; then
	while read line; do
		if [ "PK_" != `echo ${line} | cut -c 1-3` ]; then
			continue
		fi
		INDEX_CNT=$((INDEX_CNT + 1))
		if [ ${INDEX_CNT} -gt 1 ]; then
			INDEX_LIST="${INDEX_LIST}, "
		fi
		INDEX_LIST="${INDEX_LIST}`echo ${line} | awk -F',' '{print $3}'`" 
	done < ${TMP_INDEX}
	echo "PRIMARY INDEX ( ${INDEX_LIST} )" >> ${TMP_CP}
fi

echo ";" >> ${TMP_ORA}
echo ";" >> ${TMP_CP}

