#!/bin/bash
# check-auth.sh
# Script para verificar autenticação de todos os profiles AWS

CONFIG_FILE="$HOME/.aws/config"

# Verificar se o arquivo de configuração existe
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ Arquivo $CONFIG_FILE não encontrado"
  exit 1
fi

# Extrair profiles do arquivo ~/.aws/config
echo "🔍 Lendo profiles do arquivo $CONFIG_FILE..."
echo

# Buscar por linhas que contêm [profile nome] ou [default]
PROFILES=($(grep -E '^\[profile ' "$CONFIG_FILE" | sed 's/^\[profile \(.*\)\]/\1/'))

# Adicionar o profile default se existir
if grep -q '^\[default\]' "$CONFIG_FILE"; then
  PROFILES=("default" "${PROFILES[@]}")
fi

# Verificar se encontrou algum profile
if [[ ${#PROFILES[@]} -eq 0 ]]; then
  echo "❌ Nenhum profile encontrado no arquivo $CONFIG_FILE"
  exit 1
fi

echo "📋 Profiles encontrados: ${#PROFILES[@]}"
echo "----------------------------------------"

# Verificar autenticação de cada profile
for profile in "${PROFILES[@]}"; do
  echo -n "Verificando $profile... "

  if aws sts get-caller-identity --profile "$profile" &>/dev/null; then
    # Obter informações do usuário/role autenticado
    IDENTITY=$(aws sts get-caller-identity --profile "$profile" --output text --query '[Arn,Account]' 2>/dev/null)
    ARN=$(echo "$IDENTITY" | cut -f1)
    ACCOUNT=$(echo "$IDENTITY" | cut -f2)

    echo "✅ Autenticada"
    echo "   └─ ARN: $ARN"
    echo "   └─ Account: $ACCOUNT"
  else
    echo "❌ Não autenticada"
  fi
  echo
done

echo "----------------------------------------"
echo "✨ Verificação concluída!"
