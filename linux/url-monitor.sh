#!/bin/bash

# Valores padrão
PATH_DEFAULT="/gateway-admin/enabled"
INTERVAL_DEFAULT=1000

# Variáveis
IP=""
PATH_URL="$PATH_DEFAULT"
INTERVAL="$INTERVAL_DEFAULT"

# Função de ajuda
show_help() {
  echo "Uso: $0 <IP> [OPCOES]"
  echo ""
  echo "Opcoes:"
  echo "  -p <path>        Path da URL (padrao: /gateway-admin/enabled)"
  echo "  -i <intervalo>   Intervalo entre requisicoes em ms (padrao: 1000)"
  echo "  -h               Exibe esta ajuda"
  echo ""
  echo "Exemplo:"
  echo "  $0 192.168.1.100"
  echo "  $0 192.168.1.100 -p /api/status -i 500"
  exit 1
}

# Verifica se foi passado pelo menos o IP
if [ $# -lt 1 ]; then
  show_help
fi

# Primeiro argumento é o IP
IP="$1"
shift

# Parse dos argumentos
while getopts "p:i:h" opt; do
  case $opt in
  p)
    PATH_URL="$OPTARG"
    ;;
  i)
    INTERVAL="$OPTARG"
    ;;
  h)
    show_help
    ;;
  \?)
    echo "Opcao invalida: -$OPTARG" >&2
    show_help
    ;;
  esac
done

# Prepara o nome do arquivo de log
START_TIME=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${IP}_${START_TIME}.log"

# URL completa
URL="http://${IP}${PATH_URL}"

# Converte intervalo de ms para segundos
SLEEP_TIME=$(echo "scale=3; $INTERVAL/1000" | bc)

# Cabeçalho do log
echo "=== Iniciando monitoramento ===" | tee -a "$LOG_FILE"
echo "URL: $URL" | tee -a "$LOG_FILE"
echo "Intervalo: ${INTERVAL}ms" | tee -a "$LOG_FILE"
echo "Log: $LOG_FILE" | tee -a "$LOG_FILE"
echo "Inicio: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"
echo "===============================" | tee -a "$LOG_FILE"
echo ""

# Função para tratar Ctrl+C
cleanup() {
  echo "" | tee -a "$LOG_FILE"
  echo "Monitoramento encerrado em $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"
  exit 0
}

trap cleanup INT TERM

# Loop principal
while true; do
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  # Faz a requisição
  HTTP_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$URL" 2>&1)

  # Extrai o código HTTP
  HTTP_STATUS=$(echo "$HTTP_RESPONSE" | grep "HTTP_STATUS:" | cut -d: -f2)

  # Extrai o corpo da resposta
  RESPONSE_BODY=$(echo "$HTTP_RESPONSE" | sed '$d')

  # Registra no log
  echo "[$TIMESTAMP] Status: $HTTP_STATUS" >>"$LOG_FILE"
  echo "$RESPONSE_BODY" >>"$LOG_FILE"
  echo "---" >>"$LOG_FILE"

  # Exibe no console apenas se não for 2XX
  if [[ ! $HTTP_STATUS =~ ^2[0-9]{2}$ ]]; then
    echo "[$TIMESTAMP] Status: $HTTP_STATUS"
    echo "Response: $RESPONSE_BODY"
    echo "---"
  fi

  # Aguarda o intervalo
  sleep "$SLEEP_TIME"
done
