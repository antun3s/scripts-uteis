REM //////////////////////////////////////////////////////////////////////////////
REM // Este script faz duas coisas
REM //		apaga arquivos *.sci mais antigos que 2 dias
REM //		apaga arquivo old independente de quando foi criado
REM //////////////////////////////////////////////////////////////////////////////


REM // Define as variaveis de data para a geracao de logs em: C:\Logs
@Rem make var nowDay
FOR /F "TOKENS=1* DELIMS=/" %%A IN ('date/t') DO SET nowDay=%%A

echo "Inicio %date% %time% " >> C:\Logs\%nowDay%.log

REM // Lista arquivos *.sci mais antigos que 2 dias
echo "Arquivos .sci mais antigos que 2 dias:" >> C:\Logs\%nowDay%.log
FORFILES /S /p C:\SCI\pasta-backups\ /d -2 /M *.sci /C "CMD /C echo @FILE @FDATE" >> C:\Logs\%nowDay%.log

REM // Apaga arquivos *.sci mais antigos que 2 dias
echo "Arquivos ja deletados" >> C:\Logs\%nowDay%.log
FORFILES /S /p C:\SCI\pasta-backups\ /d -2 /M *.sci /C "CMD /C DEL @FILE /Q"


REM // Lista arquivo old independente de quando foi criado
echo "Arquivos .old encontrados:" >> C:\Logs\%nowDay%.log
FORFILES /S /p C:\SCI\pasta-backups\ /M *.old /C "CMD /C echo @FILE @FDATE" >> C:\Logs\%nowDay%.log

REM // Apaga arquivo old independente de quando foi criado
echo "Arquivos ja deletados" >> C:\Logs\%nowDay%.log
FORFILES /S /p C:\SCI\pasta-backups\ /M *.old /C "CMD /C DEL @FILE /Q"

echo "Fim %date% %time% " >> C:\Logs\%nowDay%.log
echo "------------" >> C:\Logs\%nowDay%.log
