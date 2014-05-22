case $1 in
	help|h|H|-help|-h|-H|--help|--h)
	echo "Uso: $0 [ usuario ] ou [ all ]"
	exit 1
	;;
esac

if [ -z $1 ] ; then
	echo "Uso: $0 [ usuario ] ou [ all ]"
	exit 1
elif [ $1 = "all" ] ; then
	usuario="$1"
	lock
	
	echo "Executando backup das caixas de todos os usuarios" >> ${LOG}
	$CMD -a -o $DIR -v 1>>${LOG} 2>>${LOG}

	compactaenvia

	exit 0

else

	usuario="$1"
	lock

	echo "Executando backup da caixa do usuario ${usuario}" >> ${LOG}
	$CMD -u $1 -o $DIR -v 1>>${LOG} 2>>${LOG}

	compactaenvia

	exit 0

fi
