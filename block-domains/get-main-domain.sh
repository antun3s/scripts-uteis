#!/bin/bash 
#Parte do script block-domains
#Bruno Antun3s

sqlite3 /tmp/bpant.sdb << EOF
select value from config where ns='mta' and name like 'domain%' ;
EOF
