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
CATEGORY=""
FORCE=false
STRIP=false

### -------------------------
### Funções utilitárias
### -------------------------

log_info()   { printf "\033[1;34m>>> %s\033[0m\n" "$*"; }
log_warn()   { printf "\033[1;33m!!! %s\033[0m\n" "$*" >&2; }
log_error()  { printf "\033[1;31m*** %s\033[0m\n" "$*" >&2; }
log_success(){ printf "\033[1;32m### %s\033[0m\n" "$*"; }

usage() {
    cat <<EOF
Uso: $0 <ação> [opções] <categoria/pacote>

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
### Carregamento de receita
### -------------------------

load_recipe() {
    local target="$1"
    CATEGORY=$(echo "$target" | cut -d'/' -f1)
    PKGNAME=$(echo "$target" | cut -d'/' -f2)

    [ -z "$CATEGORY" ] && log_error "Categoria não especificada." && exit 1
    [ -z "$PKGNAME" ] && log_error "Pacote não especificado." && exit 1

    local recipe="$REPO/$CATEGORY/$PKGNAME/recipe"
    if [ ! -f "$recipe" ]; then
        log_error "Receita não encontrada: $recipe"
        exit 1
    fi

    # Resetar variáveis antes de carregar
    NAME="" VERSION="" SUMMARY="" HOMEPAGE="" LICENSE=""
    BUILD_SYSTEM="" SOURCES="" SHA256S="" BUILD_DEPS="" RUN_DEPS=""
    CONFIGURE_ARGS="" PATCHES="" STRIP="" PKG_FORMAT=""
    HOOK_PRE_FETCH="" HOOK_PRE_BUILD="" HOOK_POST_BUILD="" HOOK_INSTALL=""

    # Carregar receita
    . "$recipe"

    log_info "Receita carregada: $NAME $VERSION"
}

### -------------------------
### Funções principais (esqueleto)
### -------------------------

fetch() {
    load_recipe "$1"
    log_info "Baixando fonte de $NAME-$VERSION"
    # TODO: implementar download (git, https, etc.)
}

extract() {
    load_recipe "$1"
    log_info "Extraindo fonte de $NAME-$VERSION"
    # TODO: implementar extração em $SRC
}

build() {
    load_recipe "$1"
    log_info "Compilando $NAME-$VERSION"
    # TODO: ler BUILD_SYSTEM e chamar rotina correta
}

install_pkg() {
    load_recipe "$1"
    log_info "Instalando $NAME-$VERSION"
    # TODO: copiar arquivos de $DESTDIR para /
}

package() {
    load_recipe "$1"
    log_info "Empacotando $NAME-$VERSION"
    # TODO: criar tar.xz do DESTDIR
}

clean() {
    load_recipe "$1"
    log_info "Limpando diretórios temporários de $NAME-$VERSION"
    # TODO: remover /tmp/$NAME e lixo de build
}

manifest() {
    load_recipe "$1"
    log_info "Gerando manifesto de $NAME-$VERSION"
    # TODO: listar arquivos e dependências
}

search() {
    log_info "Procurando por $1"
    # TODO: buscar em $REPO e DB de pacotes
}

info() {
    load_recipe "$1"
    log_info "Informações sobre $NAME-$VERSION"
    echo "Resumo:    $SUMMARY"
    echo "Homepage:  $HOMEPAGE"
    echo "Licença:   $LICENSE"
    echo "BuildSys:  $BUILD_SYSTEM"
    echo "Sources:   ${SOURCES[*]}"
}

upgrade() {
    log_info "Atualizando pacotes"
    # TODO
}

revdep() {
    load_recipe "$1"
    log_info "Verificando dependências reversas de $NAME"
    # TODO
}

system_rebuild() {
    log_info "Recompilando o sistema inteiro"
    # TODO
}

remove_pkg() {
    load_recipe "$1"
    log_info "Removendo $NAME-$VERSION"
    # TODO
}

### -------------------------
### Parser de argumentos
### -------------------------

[ $# -lt 1 ] && usage

ACTION="$1"; shift

case "$ACTION" in
    fetch)          fetch "$1" ;;
    extract)        extract "$1" ;;
    build|b)        build "$1" ;;
    install|i)      install_pkg "$1" ;;
    package|p)      package "$1" ;;
    clean)          clean "$1" ;;
    manifest)       manifest "$1" ;;
    search|s)       search "$1" ;;
    info)           info "$1" ;;
    upgrade|u)      upgrade ;;
    revdep)         revdep "$1" ;;
    system-rebuild) system_rebuild ;;
    remove|r)       remove_pkg "$1" ;;
    help|h|--help)  usage ;;
    *)              log_error "Ação inválida: $ACTION"; usage ;;
esac

exit 0
