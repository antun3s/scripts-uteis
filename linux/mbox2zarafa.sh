#!/bin/bash

# Script para exportat os emails de mbox para a base do zarafa

#Indica que BASE_IE_AD e' o arquivo que possui a relacao dos usuarios que serao importados
BASE_IE_AD=./user_ie_bpmx_dup.txt

#Pesquisa o caminho dos arquivos subscriptions pois indica um usuário com Email
for BUSCA in `find ./ -type f -name \.subscriptions`; do
        #Captura o trecho do caminho que mostra o nome do usuário
        USER_IE=`echo -e $BUSCA | awk -F/ '{print $2}'`
        #Faz uma checagem para ver o usuario consta na base de usuarios que serao importados
        if (grep --quiet -P "^$USER_IE\t" $BASE_IE_AD); then
                #Busca na Base qual o USUARIO _AD que correspondente
                USER_AD=`grep -P "^$USER_IE\t" $BASE_IE_AD | awk '{print $2}'`
		#Cria a Inbox do usuário
		echo -e "formail -s zarafa-dagent -C -F \"Inbox\" -r "$USER_AD" < "$USER_IE"/mbox"
		#Cria SentItens do usuario	
		echo -e "formail -s zarafa-dagent -C -F \"Sent Items\" -r "$USER_AD" < "$USER_IE"/Mail/Sent"
                #Checa a quantidade de Pastas que o usuário possui
                PASTAS=`wc -l $BUSCA | awk '{print $1}'`
                #Prepara um contador que percorrerá as PASTAS 
                for i in `seq 1 $PASTAS`; do
                        #Faz LINHA ser um auxiliar do contador
                        LINHA=$i
                        LINHA+='!d'
                        #Traz o nome da Pasta contida no arquivo subscriptions
                        PASTA=`sed $LINHA $BUSCA`
                	SENT="Sent"
			if [ "$PASTA" == "$SENT" ]; then
				echo " "> /dev/null
			else
				echo -e "formail -s zarafa-dagent -C -F \""$PASTA"\" -r "$USER_AD" < "$USER_IE"/Mail/\""$PASTA"\""	
			fi
		done
        fi
done
