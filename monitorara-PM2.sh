#!/bin/bash
# Criado para ajudar a equipe Piuma Soluções 
# Verica se existe algum serviço do PM2 parado, se estiver ele reinicia o serviço
# Bruno Antunes 14/12/2018

#Instalação:
# Coloque este script em: "/usr/local/bin/checa-servicos.sh"
# Dê permissão de execução: chmod +x /usr/local/bin/checa-servicos.sh"
# Comando: "crontab -e"
# Insira:  "* * * * *  /usr/local/bin/checa-servicos.sh >/dev/null 2>&1"
# Verifique o local dos binarios "pm2" e "node" estão condizentes com a variavel PM2:
## find / -type f -name pm2
## find / -type f -name node | grep -v "/proc"

#Arquivo para receber log
LOG=/var/log/checa-servicos.log
#Comando de execução do PM2 para o sistema, será urilizado varias vezes
PM2='/root/.nvm/versions/node/v11.3.0/bin/node /root/.nvm/versions/node/v11.3.0/lib/node_modules/pm2/bin/pm2 '

#Busca por serviço parado e atribui o nome do servico parado para variavel
SERVICO_PARADO=`$PM2 status | grep stopped | awk '{print $2}'`

#Se variavel está vazia, indicida que tudo está rodando
if [ -z "$SERVICO_PARADO" ]; then
  echo `date` " - servicos rodando" >> $LOG
else
#Se a variavel conter o nome do serviço, é gerado o log e execurado o resurrect
  echo `date` " - servico "$SERVICO_PARADO" parado. Será reiniciado." >> $LOG
  $PM2 resurrect
  $PM2 restart all
fi
