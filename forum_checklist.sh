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

##CONSTANTS
MESERRO="${RED}[X]${NC}${BOLD}"
MESINFO="${GREEN}[✓]${NC}${BOLD}" 
MESINST="${YELLOW}[!]${NC}${BOLD}" 
MESWARN="${PURPLE}[?]${NC}${BOLD}"

# Função de ajuda
show_help() {
	echo ""
	echo "Uso: <usuario> [OPÇÃO]"
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
	echo "Erro: É necessário especificar um usuário e opção"
	echo ""
	show_help
	exit 1
fi

USER="$1"
shift

# Verifica se ainda há argumentos após a fila
if [ $# -eq 0 ]; then
	echo ""
	echo "Erro: É necessário especificar um domínio após o usuário"
	echo ""
	show_help
	exit 1
fi

# Processa os parâmetros por setor
case $1 in
	--comp|--compartilhados)
	   fila="compartilhados"
	   ;;
	--const|--construtores)
	   fila="construtores"
	   ;;
	--mail|--email)
	   fila="email"
	   ;;
	--esp|--especializado)
	   fila="especializado"
	   ;;
	--dom|--dominios)
	   fila="dominios"
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

validate_user() {
local user=$1
	
# Verifica se o parâmetro não está vazio
if [[ -z "$user" ]]; then
	echo "❌ Erro: Nome de usuário não pode estar vazio"
	exit 1
fi
											
# Verifica se o usuário existe no trueuserdomains
if grep -q "^[^:]*:$user$" "/etc/trueuserdomains"; then
	echo "✅ Usuário '$user' validado com sucesso"
	return 0
else
	echo "❌ Erro: Usuário '$user' não encontrado no sistema"
	exit 1
fi
}



























echo ""
echo "=== Verificações iniciais ==="
echo "Sistema operacional $(cat /etc/redhat-release)"
echo "A partição atual do usuário é ... numero atual de inodes em ... com limite ..."
echo "Ip atual deste usuário é ..."
echo ""
echo "=== VERIFICAÇÃO DE SERVIÇOS COMUNS ==="
		    
COMMON_SERVICES="httpd mysqld cpanel pure-ftpd sshd exim dovecot"
for SERVICE in $COMMON_SERVICES ; do
		if systemctl is-active "$SERVICE" >/dev/null 2>&1;  then
			status="Ativo"
		else
			status="Inativo - Comunique imediatemente um analista N2!"
		fi
		echo "Serviço: $SERVICE - Status: $status"
done
echo ""

