#!/bin/bash
# Esse script é utilizado para instalar pacote o zabbix-agent2
# Ele copia as configurações relevantes do zabbix-agent e replica no arquivo zabbix-agent2
# Feito para utilizar no Proxmox PVE nas versões 7 e 8

# Verifica a versão do Proxmox
pve_version=$(pveversion | cut -d'/' -f2 | cut -d'.' -f1)

if [ "$pve_version" == "pve-manager" ]; then
  pve_version=$(pveversion | cut -d'/' -f2)
fi
echo "# Utilizando o PVE na versão " $pve_version

if [ "$pve_version" == "7" ]; then
  # Baixa e instala o pacote Zabbix para Proxmox 7.0
  zabbix_package_url="https://repo.zabbix.com/zabbix/5.0/debian/pool/main/z/zabbix-release/zabbix-release_5.0-2+debian11_all.deb"
elif [ "$pve_version" == "8" ]; then
  # Baixa e instala o pacote Zabbix para Proxmox 8.0
  zabbix_package_url="https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-5+debian12_all.deb"
else
  echo "# A versão do Proxmox não é suportada. Abortando a configuração."
  exit 1
fi

# Baixa o pacote Zabbix Release
echo "# Baixando o zabbix-release"
wget "$zabbix_package_url"
dpkg -i "$(basename $zabbix_package_url)"
apt update

# Instala o sudo e o Zabbix Agent 2
echo "# Instalando sudo e zabbix-agent2"
apt-get install sudo zabbix-agent2 -y

# Obtém as configurações do zabbix_agentd.conf
echo "# Usando as configurações do zabbix-agent para replicar no zabbix-agent2"
Server=$(grep '^Server=' /etc/zabbix/zabbix_agentd.conf)
ServerActive=$(grep '^ServerActive=' /etc/zabbix/zabbix_agentd.conf)
Hostname=$(grep '^Hostname=' /etc/zabbix/zabbix_agentd.conf)

# Sobrepor as configurações no zabbix_agent2.conf
sed -i "s/^Server=.*$/Server=${Server#Server=}/" /etc/zabbix/zabbix_agent2.conf
sed -i "s/^ServerActive=.*$/ServerActive=${ServerActive#ServerActive=}/" /etc/zabbix/zabbix_agent2.conf
sed -i "s/^Hostname=.*$/Hostname=${Hostname#Hostname=}/" /etc/zabbix/zabbix_agent2.conf

# Desabilita a inicialização do zabbix-agentd
echo "# Desativando e parando o zabbix-agent"
systemctl disable zabbix-agent
systemctl stop zabbix-agent

# Habilita a inicialização automática do zabbix-agent2
echo "# Ativando e reiniciando o zabbix-agent2"
systemctl enable zabbix-agent2
systemctl restart zabbix-agent2

# Cria o arquivo sudoers.d para o usuário zabbix
echo "# Dando permissoes para o usuario zabbix executar o smard sem senha"
echo "zabbix ALL=(ALL) NOPASSWD:/usr/sbin/smartctl" > /etc/sudoers.d/smartd
