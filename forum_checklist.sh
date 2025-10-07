#!/bin/bash
###################################################
# HostGator Brasil LTDA - 2025
#
# Script version:
# 1.0
#
# Last update:
# 06/10/2025
#
###################################################
# Author:
#
# Fabrício Wonzoski <fabricio.wonzoski@newfold.com>
# Jr Advanced Support Analyst (N2)
#
###################################################
#
# Script to do a checklist
#
###################################################

# DEFINE CORES
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# VARIÁVEIS LOCAIS
echo "=== Verificações iniciais ==="
echo "Sistema operacional $(cat /etc/redhat-release)"
echo "A partição atual do usuário é ... numero atual de inodes em ... com limite ..."
echo "Ip atual deste usuário é ..."
echo ""
echo "=== VERIFICAÇÃO DE SERVIÇOS COMUNS ==="
		    
COMMON_SERVICES="httpd mysqld cpanel pure-ftpd sshd exim dovecot"
for service in $COMMON_SERVICES ; do
		if systemctl is-active "$service" >/dev/null 2>&1;  then
			status="Ativo"
		else
			status="Inativo"
		fi
		echo "Serviço: $service - Status: $status"
done
echo ""

