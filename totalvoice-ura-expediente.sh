#!/bin/bash
source totalvoice.cfg
LOG=/var/log/totalvoice-ura.log

echo -e "\n" $DATETIME "- Trocada URA para hora-expediente \c" >> $LOG
curl --silent -X PUT --header 'Content-Type: application/json' \
           --header 'Accept: application/json' \
           --header 'Access-Token: '$TOKEN'' \
           -d '{"ura_id":"30323"}' \
           'https://api2.totalvoice.com.br/did/85973579'  >> $LOG
