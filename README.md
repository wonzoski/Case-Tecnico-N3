# Case-Tecnico-N3
Repositório referente a criação de script para desafio técnico de N3

# Checklist Script - HostGator

Script de **checklist técnico** para análise e diagnóstico de contas.
Desenvolvido para auxiliar equipes de suporte e monitoramento em verificações rápidas de contas cPanel.

---

## Execução Rápida

Execute diretamente no terminal **(sem precisar baixar o arquivo manualmente):**

```bash
bash <(curl -sSL "https://raw.githubusercontent.com/wonzoski/Case-Tecnico-N3/main/forum_checklist.sh") <usuário> <opção>
```

---

## Sintaxe e Parâmetros

```bash
bash checklist.sh <usuário> <opção>
```

| Opção     | Alias              | Descrição                                            |
| :-------- | :----------------- | :--------------------------------------------------- |
| `--comp`  | `--compartilhados` | Checklist para **domínios compartilhados**           |
| `--const` | `--construtores`   | Checklist para **domínios criados em Construtores**  |
| `--mail`  | `--email`          | Checklist para **serviços de e-mail**                |
| `--dom`   | `--dominios`       | Checklist para **domínios principais e subdomínios** |
| `-h`      | `--help`           | Mostra ajuda e exemplos de uso                       |

---

## Exemplos de Uso

```bash
# Checklist de domínios compartilhados
bash <(curl -sSL "https://raw.githubusercontent.com/wonzoski/Case-Tecnico-N3/main/forum_checklist.sh") meuusuario --comp

# Checklist de construtores
bash <(curl -sSL "https://raw.githubusercontent.com/wonzoski/Case-Tecnico-N3/main/forum_checklist.sh") meuusuario --const

# Checklist de e-mail
bash <(curl -sSL "https://raw.githubusercontent.com/wonzoski/Case-Tecnico-N3/main/forum_checklist.sh") meuusuario --mail

# Checklist de domínios e zonas DNS
bash <(curl -sSL "https://raw.githubusercontent.com/wonzoski/Case-Tecnico-N3/main/forum_checklist.sh") meuusuario --dom
```

---

## Estrutura da Saída

### Cabeçalho Geral

* Validação do usuário
* Uso de disco e limites
* Partição atual e uso
* Status dos serviços comuns

### Seções Específicas por Tipo de Checklist

** Compartilhados (`--comp`)**

* Últimos 10 acessos ao cPanel
* Logs de sessão do usuário

** Construtores (`--const`)**

* Verificação HTTP dos domínios (✅ 2xx/3xx = OK, ❌ outros = falha)
* Verificação HTTP dos subdomínios
* Resumo geral da checagem

** E-mail (`--mail`)**

* Lista de contas de e-mail do usuário
* Contas POP/IMAP configuradas

** Domínios (`--dom`)**

* Lista de domínios e subdomínios
* Validação de zonas DNS
* ✅/❌ Checagem de sintaxe das zonas

---

## Limitações e Dependências

### Ambiente

* ✅ Exclusivo para servidores compartilhados na HostGator
* ✅ Requer `/opt/hgctrl/.zengator` presente
* ❌ Não executa em ambientes não-HostGator
* ❌ Não possúi uma versão em espanhol
* ❌ Não executa verificações para fila de especializado

### Dependências

* **cPanel/WHM** ativo
* Comandos necessários: `uapi`, `ui`, `quota`, `named-checkzone`
* Serviços padrão: `httpd`, `mysqld`, etc.

### Funcionalidades e Restrições

* Apenas usuários em `/etc/trueuserdomains` são aceitos
* Verificação de inodes desabilitada (linha 101)
* Domínios temporários `*.meusitehostgator.com.br` são ignorados
* Timeout HTTP: 10s por domínio
* Limite de logs: 10 últimos acessos

---

## Segurança

* ✅ Verifica existência e validade do usuário
* ✅ Executa apenas com permissões adequadas
* ⚠️ Logs podem conter informações sensíveis — uso restrito à equipe técnica

---

## Mensagens de Erro Comuns

| Erro                                          | Causa                     | Solução                                  |
| --------------------------------------------- | ------------------------- | ---------------------------------------- |
| `É necessário especificar um usuário e opção` | Argumentos insuficientes  | Use: `bash checklist.sh usuario --opcao` |
| `Usuário 'X' não encontrado`                  | Usuário inexistente       | Verifique o nome informado               |
| `Parâmetro 'X' inválido`                      | Opção incorreta           | Consulte `--help`                        |
| `Ambiente não-HostGator`                      | Execução fora do ambiente | Execute apenas em servidores HostGator   |

---

## Informações de Desenvolvimento

* **Versão:** 1.0
* **Última atualização:** 08/10/2025
* **Autor:** [Fabrício Wonzoski](https://github.com/wonzoski) — *N2 Advanced Support*
* **Compatibilidade:** Linux / cPanel / HostGator

> **Uso restrito:** Este script é destinado exclusivamente à equipe técnica em ambientes autorizados.

---
