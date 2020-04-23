#!/bin/bash
#Bruno Antunes


#if [ "$#" -eq 0 ];then
#echo "Error invalid args;"
#echo "Use 'list' or 'edit'"
#fi


case "$1" in
	'list')
		awk '{print $1}' /etc/postfix/sender-restricted | sed 's/\@.*//g'
	;;

	'edit')
		`zarafa-admin -l | awk '{print $1}' | sed '/^User$\|^username$\|---------------------------------------------\|SYSTEM\|^$/d' | sort > /tmp/users-list.txt`

		USERS='/tmp/users-list.txt'
		NUM_USERS=`wc -l $USERS | awk '{print $1}'`
		USERS_RESTRICTED='/tmp/users-restricted.txt'
		MAIN_DOMAINS='/tmp/main-domains.txt'
		SENDER_RESTRICTED='/tmp/sender-restricted.txt'
		INTERNAL_DOMAINS='/tmp/internal-domains.txt'
		POSTFIX='/tmp/main.cf'

		#Limpa arquivo antigos
		rm -f $USERS_RESTRICTED
		rm -f $MAIN_DOMAINS
		rm -f $SENDER_RESTRICTED
		rm -f $INTERNAL_DOMAINS
		rm -f /tmp/bpant.sdb

		`cp /var/db/bpant.sdb /tmp/bpant.sdb`
		./get-main-domain.sh > $MAIN_DOMAINS

		for i in `seq 1 $NUM_USERS`; do
			LINHA=$i
			LINHA+='!d'
			echo -ne 'Bloquear envio externo para:  '`sed $LINHA $USERS` '(S/N): '
			read BLOQUEIA
			if [ "$BLOQUEIA" = "s" -o "$BLOQUEIA" = "S" ]; then
				echo `sed $LINHA $USERS` 'Bloquado'
				echo -e `sed $LINHA $USERS` >> $USERS_RESTRICTED
			else
				echo `sed $LINHA $USERS` 'Liberado'

			fi
			echo ""
		done

		#Gera arqivo dos domínios internos
		for DOMAIN in `cat $MAIN_DOMAINS`; do
			echo $DOMAIN" OK" >> $INTERNAL_DOMAINS
		done

		#Gera arquivos dos usuários restritos dos domínios internos
		for USER in `cat $USERS_RESTRICTED`; do
			for DOMAIN in `cat $MAIN_DOMAINS`; do
				echo $USER@$DOMAIN" restricted-group" >> $SENDER_RESTRICTED
			done
		done

		sed '/^\#\{24\}$/,/reject$/d' /etc/postfix/main.cf > $POSTFIX

		echo "########################" >> $POSTFIX
		echo "# Custom Block Domains #" >> $POSTFIX
		echo "########################" >> $POSTFIX
		echo "smtpd_recipient_restrictions = check_sender_access hash:/etc/postfix/sender-restricted, permit_mynetworks, check_relay_domains" >> $POSTFIX
		echo "smtpd_restriction_classes = restricted-group" >> $POSTFIX
		echo "restricted-group = check_recipient_access hash:/etc/postfix/restricted-group, reject" >> $POSTFIX

		#Move todos os arquivos mantendo as permissões
		echo "Movendo arquivos ..."
		cat $POSTFIX >> /etc/postfix/main.cf
		cat $SENDER_RESTRICTED > /etc/postfix/sender-restricted
		cat $INTERNAL_DOMAINS > /etc/postfix/restricted-group

		#Carrega arquivos das restricoes
		echo "Aplicando modificacoes ..."
		postmap /etc/postfix/sender-restricted
		postmap /etc/postfix/restricted-group

		#Recarrega o Postfix
		/etc/init.d/postfix reload

		echo "Configuracoes aplicadas com sucesso."
	;;
	*)
		echo "Error invalid args;"
		echo "Use 'list' or 'edit'"
	;;
esac
