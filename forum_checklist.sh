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

# VARIÁVEIS LOCAIS
echo "## Verificações iniciais ##"
echo "Sistema operacional $(cat /etc/redhat-release}"
echo "A partição atual do usuário é ... numero atual de inodes em ... com limite ..."
echo "Ip atual deste usuário é ..."

COMMON_SERVICES=(httpd mysqld cpanel pure-ftp sshd exim dovecot)
for s in "${COMMON_SERVICES[@]}"; do
	if command_exists systemctl; then
		echo "Status do serviço: $s" "systemctl is-active $s && systemctl status $s --no-pager --lines=5 || systemctl status $s --no-pager --lines=5 || true"
	else
		echo "Status do serviço (sysv): $s" "service $s status 2>&1 || true"
	fi
done
