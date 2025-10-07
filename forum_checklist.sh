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
BOLD='\033[1m'
RED='\033[1;31m'  
GREEN='\033[0;92m'
CYAN='\033[1;36m'
YELLOW='\033[38;5;11m'
BLUE='\033[0;94m'
ORANGE='\033[1;33m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

##CONSTANTS
MESERRO="${RED}[X]${NC}${BOLD}"
MESINFO="${GREEN}[✓]${NC}${BOLD}" 
MESINST="${YELLOW}[!]${NC}${BOLD}" 
MESWARN="${PURPLE}[?]${NC}${BOLD}"
SUBITEM="${BLUE} ► ${NC}${BOLD}"

# Função de ajuda
show_help() {
	echo ""
	echo "Uso: <usuario> [OPÇÃO]"
	echo ""
	echo "Opções:"
	echo "  --comp|--compartilhados  Checklist para domínio Compartilhados"
	echo "  --const|--construtores   Checklist para domínio Construtores"
	echo "  --mail|--email           Checklist para domínio E-mail"
	echo "  --esp|--especializado    Checklist para domínio Especializado"
	echo "  --dom|--dominios         Checklist para domínio Domínios"
	echo "  -h|--help                Mostra esta ajuda"
	echo ""
}

# Verifica se não há argumentos
if [ $# -eq 0 ]; then
	echo ""
	echo "Erro: É necessário especificar um usuário e opção"
	show_help
	exit 1
fi

USER="$1"
shift

# Verifica se ainda há argumentos após a fila
if [ $# -eq 0 ]; then
	echo ""
	echo "Erro: É necessário especificar uma opção após o usuário"
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
# Verifica se o parâmetro não está vazio
if [[ -z "$USER" ]]; then
	echo "❌ Erro: Nome de usuário não pode estar vazio"
	exit 1
fi

# Verifica se o usuário existe no userdomains
if awk '{print $2}' /etc/trueuserdomains | grep -qw "$USER"; then
	echo ""
	echo "✅ Usuário '$USER' válido"
	echo ""
	return 0
else
	echo ""
	echo "❌ Erro: Usuário '$USER' não encontrado no sistema"
	echo "   Verifique se o nome de usuário está correto"
	echo ""
	exit 1
fi

INFO=$(quota -u "$USER" | awk '/^[[:space:]]*\/dev\// {print $1, $2, $3, $4, $6, $7, $8}')

read PART USED QUOTA LIMIT FILES FQUOTA FLIMIT <<< "$INFO"

USED_GB=$(awk "BEGIN {printf \"%.2f\", $USED/1048576}")
LIMIT_GB=$(awk "BEGIN {printf \"%.2f\", $LIMIT/1048576}")

echo "A partição atual do usuário ${USER} é ${PART}, com uso de disco de ${USED_GB} GB (consumo atual) e limite de ${LIMIT_GB} GB (limite de disco atual), utilizando ${FILES} inodes (consumo atual de inodes) com limite de ${FLIMIT} inodes."

}

# Validação do usuário
validate_user "$USER"

echo ""
echo "=== Verificações iniciais ==="
echo "Sistema operacional $(cat /etc/redhat-release)"
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

