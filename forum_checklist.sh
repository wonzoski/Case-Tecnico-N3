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

##DEFINE CORES
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
PONTUACAO="${BLUE} • ${NC}${BOLD}"
SUBITEM="${BLUE} ► ${NC}${BOLD}"

#VERIFICA O SERVIDOR
if [[ $(hostname) =~ .*hostgator* ]] || [[ $(hostname) =~ .*prodns*  ]] && [[ -e /opt/hgctrl/.zengator ]]; then
        : # Ambiente HostGator - continua execução normal
else
	echo ""
	echo -e "${RED} Este script deve ser executado apenas em ambientes HostGator${NC}"
	echo ""
exit 1
fi

##VARIÁVEIS GLOBAIS
declare -A DOMS
declare -A SUBDOMS

# Função de ajuda
show_help() {
	echo ""
	echo "Uso: <usuario> [OPÇÃO]"
	echo ""
	echo "Opções:"
	echo "  --comp|--compartilhados  Checklist para domínio Compartilhados"
	echo "  --const|--construtores   Checklist para domínio Construtores"
	echo "  --mail|--email           Checklist para domínio E-mail"
#	echo "  --esp|--especializado    Checklist para domínio Especializado"
	echo "  --dom|--dominios         Checklist para domínio Domínios"
	echo "  -h|--help                Mostra esta ajuda"
	echo ""
}

# Verifica se não há argumentos
if [ $# -eq 0 ]; then
	echo ""
	echo -e "${MESINST}" "É necessário especificar um usuário e opção"
	show_help
	exit 1
fi

USER="$1"
shift

# Verifica se ainda há argumentos após a fila
if [ $# -eq 0 ]; then
	echo ""
	echo -e "${MESINST} É necessário especificar uma opção após o usuário"
	show_help
	exit 1
fi

# Função para validar usuário e imprimir dados padrões
validate_user() {
# Verifica se o parâmetro não está vazio
if [[ -z "$USER" ]]; then
	echo "${MESINST} Nome de usuário não pode estar vazio"
	exit 1
fi

# Verifica se o usuário existe no trueuserdomains
if awk '{print $2}' /etc/trueuserdomains | grep -qw "$USER"; then
	PLANO=$(whmapi1 accountsummary user="$USER" | grep plan | awk -F":" '{print $2}' | sed 's/^[ \t]*//')
	VALOR=$(whmapi1 getpkginfo pkg="$PLANO" | egrep '^    QUOTA' | awk '{print $2}')
	COTATUAL=$(whmapi1 accountsummary user="$USER" | grep diskused | awk '{print $2}' | tr -d 'M')
	IPCPAN=$(ui fuxica51 -d 2>/dev/null | grep IP: | awk '{print $2}')
	INFO=$(quota -u "$USER" | awk '/^[[:space:]]*\/dev\// {print $1, $2, $3, $4, $6, $7, $8}' | tail -n 1)
	read PART USED QUOTA LIMIT FILES FQUOTA FLIMIT <<< "$INFO"
	#USED_GB=$(awk "BEGIN {printf \"%.2f\", $USED/1048576}") (SUBSTITUIDO PELO WHMAPI1)
	#LIMIT_GB=$(awk "BEGIN {printf \"%.2f\", $LIMIT/1048576}") (SUBSTITUIDO PELO WHMAPI1)
	
	# Aqui são informações gerais do servidor que sempre vão aparecer não importa o tipo de fila definida no parâmetro
	echo ""
	echo -e "${MESINFO} Usuário '$USER' válido"
	echo -e "${SUBITEM} Plano de hospedagem ${PLANO} limite de disco do plano ${VALOR} e disco atual em ${COTATUAL} MB"
	echo -e "${SUBITEM} IP do cPanel ${IPCPAN}"
	echo -e "${SUBITEM} Sistema operacional $(cat /etc/redhat-release || cat /etc/os-release)"
	echo -e "${SUBITEM} Partição atual do usuário: ${PART} atualmente com $(df -h | grep ${PART} | awk '{print $5}') de uso"
	#echo -e "${SUBITEM} Uso de disco: ${USED_GB} GB e limite de ${LIMIT_GB} GB" (Desuso)
	#echo -e "${SUBITEM} Utilizando ${FILES} inodes com limite de ${FLIMIT} inodes." (NÃO DEU TEMPO - ideia era listar inodes e limite do usuário)
	echo ""
	echo "=== VERIFICAÇÃO DE SERVIÇOS COMUNS ==="
	
	# Preenche variável de vetor com domíno do usuário excluindo temporáros. (PLANEJADO PARA FAZER TRATATIVA DE TEMPORÁRIOS TAMBÉM PORÉM NÃO DEU TEMPO)
	DOMS=$(ui ${USER} -d 2>/dev/null | egrep 'Addon:|U. Domain:' | awk -F':' '{print $2}' | egrep -iv '*\.meusitehostgator.com.br')
	SUBDOMS=$(ui ${USER} -d 2>/dev/null | grep Sub: | awk -F':' '{print $2}' | egrep -iv '*\.meusitehostgator.com.br')
	
	# Verificando os principais serviços ativos/inativos do servidor
	COMMON_SERVICES="httpd mysqld cpanel pure-ftpd sshd exim dovecot"
	for SERVICE in $COMMON_SERVICES ; do
		if systemctl is-active "$SERVICE" >/dev/null 2>&1;  then
			status="${MESINFO} Ativo"
		else
			status="${MESERRO} Inativo - Comunique imediatemente um analista N2!"
		fi
		echo -e "Serviço: $SERVICE - Status: $status"
	done
	echo ""
	return 0
	else
		echo ""
		echo -e "${MESINST}" "Erro: Usuário '$USER' não encontrado no sistema"
		echo "   Verifique se o nome de usuário está correto"
		echo ""
	exit 1
fi

}

# Validação do usuário
#validate_user "$USER"

# Função principal para cada fila (compartilhados - construtores - email - domínio)
# Ideia aqui era fazer várias funcionalidades 
check_compartilhados() {
echo ""
echo -e "${MESINFO} Iniciando checklist para ${CYAN}Domínios Compartilhados${NC}"
echo -e "${SUBITEM} Retornando os últimos 10 acessos no cPanel..."
grep NEW /usr/local/cpanel/logs/session_log | egrep -iv "xml-api" | grep $USER | awk -F':' '{print $1":" $2":" $3}' | grep -iv '@' | tail -n 10
echo ""
# ...
}

check_construtores() {
echo ""
echo -e "${MESINFO} Iniciando checklist para ${CYAN}Construtores${NC}"
# Função para verificar status HTTP
check_status() {
	local url=$1
	local code
	code=$(curl -o /dev/null -s -w "%{http_code}" -L --max-time 10 "http://$url")
	echo "$code"
}

echo -e "${CYAN}${BOLD}► Verificando status dos domínios...${NC}"

for DOM in $DOMS; do
	STATUS=$(check_status "$DOM")
	if [[ $STATUS =~ ^2|3 ]]; then
		echo -e " • ${GREEN}$DOM${NC} → Status: ${BOLD}${STATUS}${NC}"
	else
		echo -e " • ${RED}$DOM${NC} → Status: ${BOLD}${STATUS}${NC}"
	fi
done

echo -e "\n${CYAN}${BOLD}► Verificando status dos subdomínios...${NC}"

for SUB in $SUBDOMS; do
	STATUS=$(check_status "$SUB")
	if [[ $STATUS =~ ^2|3 ]]; then
		echo -e " • ${GREEN}$SUB${NC} → Status: ${BOLD}${STATUS}${NC}"
	else
		echo -e " • ${RED}$SUB${NC} → Status: ${BOLD}${STATUS}${NC}"
	fi
done

echo -e "\n${YELLOW}${BOLD}✓ Verificação concluída.${NC}"
echo ""
# ...
}

check_email() {
echo ""
echo -e "${MESINFO} Iniciando checklist para ${CYAN}E-mail${NC}"
echo -e "${SUBITEM} Listando contas de e-mail do usuário..."
##echo -e "${PONTUACAO} $(uapi --user=$USER Email list_pops | egrep 'email.*@' | awk '{print $2}')\n"
uapi --user="$USER" Email list_pops | egrep 'email.*@' | awk '{print $2}' | while read -r email; do
    echo -e "${PONTUACAO} $email"
done
echo ""
# ...
}

#check_especializado() {
#echo ""
#echo -e "${MESINFO} Iniciando checklist para ${CYAN}Servidores Especializados${NC}"
#echo -e "${SUBITEM} Validando recursos dedicados..."
# ...
#}

check_dominios() {
echo ""
echo -e "${MESINFO} Iniciando checklist para ${CYAN}Domínios${NC}"
echo -e "${SUBITEM} Listando os domínios..."
echo -e "${DOMS}" "\n"
echo -e "${SUBITEM} Listando os subdomínios..."
echo -e "${SUBDOMS}" "\n"
echo -e "${SUBITEM} Verificando a validade da zona DNS..."
for DOM in ${DOMS} ; do
	ZONE_FILE="/var/named/${DOM}.db"
	#named-checkzone "$DOM" "$ZONE_FILE"
	#if [ $? -eq '0' ]; then
	if named-checkzone "$DOM" "$ZONE_FILE" &>/dev/null; then
		checagem="válida! $MESINFO"
 	else
		checagem="inválida! $MESERRO"
	fi
	echo -e "Domínio: $DOM - Zona DNS: $checagem"
done
echo ""
# ...
}

case $1 in
	--comp|--compartilhados)
		fila="compartilhados"
		validate_user "$USER" && check_compartilhados
		;;
	--const|--construtores)
		fila="construtores"
		validate_user "$USER" && check_construtores
		;;
	--mail|--email)
		fila="email"
		validate_user "$USER" && check_email
		;;
#	--esp|--especializado)
#		fila="especializado"
#		validate_user "$USER" && check_especializado
#		;;
	--dom|--dominios)
		fila="dominios"
		validate_user "$USER" && check_dominios
		;;
	-h|--help)
		show_help
		exit 0
		;;
	*)
		echo ""
		echo -e "${MESINST} Parâmetro '$1' inválido"
		show_help
		exit 1
		;;
esac
## FIM DO SCRIPT ##
