#!/bin/sh
#
# Ports Source Base (PSB) - protótipo esqueleto
# Gerenciador de programas baseado em receitas
#

# Diretórios padrão
REPO="${REPO:-/usr/ports}"
SRC="/var/ports/src"
PKG="/var/ports/pkg"
BIN="/var/ports/bin"
LOG="/var/log/ports"
DESTDIR="/tmp/ports-destdir"

# Variáveis globais
ACTION=""
PKGNAME=""
FORCE=false
STRIP=false

### -------------------------
### Funções utilitárias
### -------------------------

log_info()   { echo ">>> $*"; }
log_warn()   { echo "!!! $*" >&2; }
log_error()  { echo "*** $*" >&2; }
log_success(){ echo "### $*"; }

usage() {
    cat <<EOF
Uso: $0 <ação> [opções] <pacote>

Ações disponíveis:
  fetch        - baixar o source
  extract      - extrair source para $SRC
  build (b)    - compilar sem instalar
  install (i)  - instalar pacote
  package (p)  - empacotar para $PKG
  clean        - limpar diretórios temporários
  manifest     - gerar manifesto do pacote
  search (s)   - procurar por pacotes
  info         - mostrar informações do pacote
  upgrade (u)  - atualizar pacotes
  revdep       - verificar dependências reversas
  system-rebuild - recompilar o sistema inteiro
  remove (r)   - remover pacote
  help (h)     - mostrar esta ajuda

Opções:
  --force      - forçar ação
  --strip      - remover símbolos após build
EOF
    exit 0
}

### -------------------------
### Funções principais (esqueleto)
### -------------------------

fetch() {
    log_info "Baixando fonte de $PKGNAME"
    # TODO: implementar download (git, https, etc.)
}

extract() {
    log_info "Extraindo fonte de $PKGNAME"
    # TODO: implementar extração em $SRC
}

build() {
    log_info "Compilando $PKGNAME"
    # TODO: ler receita, aplicar patches, compilar
}

install_pkg() {
    log_info "Instalando $PKGNAME"
    # TODO: copiar arquivos de $DESTDIR para /
}

package() {
    log_info "Empacotando $PKGNAME"
    # TODO: criar tar.xz do DESTDIR
}

clean() {
    log_info "Limpando diretórios temporários"
    # TODO: remover /tmp/$PKGNAME e lixo de build
}

manifest() {
    log_info "Gerando manifesto de $PKGNAME"
    # TODO: listar arquivos e dependências
}

search() {
    log_info "Procurando por $PKGNAME"
    # TODO: buscar em $REPO e DB de pacotes
}

info() {
    log_info "Informações sobre $PKGNAME"
    # TODO: exibir versão, deps, descrição
}

upgrade() {
    log_info "Atualizando pacotes"
    # TODO: checar atualizações, rebuild, etc.
}

revdep() {
    log_info "Verificando dependências reversas de $PKGNAME"
    # TODO: implementar revdep
}

system_rebuild() {
    log_info "Recompilando o sistema inteiro"
    # TODO: loop sobre pacotes, respeitando deps
}

remove_pkg() {
    log_info "Removendo $PKGNAME"
    # TODO: remover pacote e deps não usadas
}

### -------------------------
### Parser de argumentos
### -------------------------

[ $# -lt 1 ] && usage

ACTION="$1"; shift

case "$ACTION" in
    fetch)          PKGNAME="$1"; fetch ;;
    extract)        PKGNAME="$1"; extract ;;
    build|b)        PKGNAME="$1"; build ;;
    install|i)      PKGNAME="$1"; install_pkg ;;
    package|p)      PKGNAME="$1"; package ;;
    clean)          PKGNAME="$1"; clean ;;
    manifest)       PKGNAME="$1"; manifest ;;
    search|s)       PKGNAME="$1"; search ;;
    info)           PKGNAME="$1"; info ;;
    upgrade|u)      upgrade ;;
    revdep)         PKGNAME="$1"; revdep ;;
    system-rebuild) system_rebuild ;;
    remove|r)       PKGNAME="$1"; remove_pkg ;;
    help|h|--help)  usage ;;
    *)              log_error "Ação inválida: $ACTION"; usage ;;
esac

exit 0
