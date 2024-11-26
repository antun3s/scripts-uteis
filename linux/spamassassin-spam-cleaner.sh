#!/bin/bash
#Bruno Antunes
#Limpa SPAMs cadastrados no aquivo /root/clear-spam.conf

QTD=0
CONF=/root/clear-spam.conf

for SEC in `seq 1 2`; do
	LINHAS=`wc -l /root/clear-spam.conf | awk '{print $1}'`
	for I in `seq 1 $LINHAS`; do
		EMAIL=`sed $I!d $CONF`
		mailq |grep Dec| grep $EMAIL | sed -e 's/\*//g' | awk '{print "postsuper -d "$1}' | sh
	done
	
	DATA=`date`
	echo -e $DATA"\t - Emails apagados "$QTD >> /var/log/clear-spam.log
	
	echo $SEC
	echo $QTD
	sleep 5;
done
