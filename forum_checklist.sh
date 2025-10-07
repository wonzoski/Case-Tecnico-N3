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

unset USER

# DEFINE CORES
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Função de ajuda
show_help() {
	echo ""
	echo "Uso: <usuario> [OPÇÃO]"
	echo ""
	echo "Usuário: Usuário cPanel"
	echo ""
	echo "Opções:"
	echo "  --comp, --compartilhados  Checklist para domínio Compartilhados"
	echo "  --const, --construtores   Checklist para domínio Construtores"
	echo "  --mail, --email           Checklist para domínio E-mail"
	echo "  --esp, --especializado    Checklist para domínio Especializado"
	echo "  --dom, --dominios         Checklist para domínio Domínios"
	echo "  -h, --help                Mostra esta ajuda"
	echo ""
}

# Verifica se não há argumentos
if [ $# -eq 0 ]; then
	echo ""
	echo "Erro: É necessário especificar um usuário e domínio"
	echo ""
	show_help
	exit 1
fi

USER="$1"
shift

# Verifica se ainda há argumentos após a fila
if [ $# -eq 0 ]; then
	echo ""
	show_help
	echo "Erro: É necessário especificar um domínio após o usuário"
	echo ""
	exit 1
fi

# Processa os parâmetros por setor
case $1 in
	--comp|--compartilhados)
	   domain="compartilhados"
	   ;;
	--const|--construtores)
	   domain="construtores"
	   ;;
	--mail|--email)
	   domain="email"
	   ;;
	--esp|--especializado)
	   domain="especializado"
	   ;;
	--dom|--dominios)
	   domain="dominios"
	   ;;
	-h|--help)
	   show_help
	   exit 0
	   ;;
 *)
	echo "Erro: Parâmetro '$1' inválido"
	show_help
	exit 1
	;;
esac

echo ""
echo "${YELLOW}=== Verificações iniciais ==="
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
			status="Inativo - Comunique imediatemente um analista N2!"
		fi
		echo "Serviço: $service - Status: $status"
done
echo ""

