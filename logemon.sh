#!/bin/bash

. ./loguemon.conf

logfile=$1
if [ -ne "${logfile}" ]; then
	echo "監視対象ファイルが指定されていません"
	exit 1
fi

mail_alert() {
	while read i
	do
		# 日時
		_date=`date "+%Y.%m.%d %H:%M:%S"`
		echo $i | grep -q ${_error_conditions}
		if [ $? = "0" ]; then
			echo $i | sendmail -t << EOF
Content-Type: text/plain; charset=${_charset}
From: ${_from}
To: ${_to}
Subject: ${_title}
1. ホスト名
${_hostname}
2. 検知概要
監視アラート ： [${_error_conditions}]
3.検知内容
　・監視対象ファイル　=>　$logfile
　・検知キーワード　：　$_error_conditions
・検知ログメッセージ
$i
4. 検知日時
${_date}
EOF
		fi
	done
}

tail -n 0 --follow=name --retry $1 | mail_alert