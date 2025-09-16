#!/bin/sh
# Ports Source Base (PSB) - Gerenciador de programas esqueleto completo

### -------------------------
### Diretórios padrão
### -------------------------
REPO="${REPO:-/usr/ports}"
SRC="/var/ports/src"
PKG="/var/ports/pkg"
BIN="/var/ports/bin"
LOG="/var/log/ports"
DESTDIR="/tmp/ports-destdir"

ACTION=""
PKGNAME=""
CATEGORY=""
FORCE=false
STRIP=false

### -------------------------
### Funções de logging
### -------------------------
log_info()    { printf "\033[1;34m>>> %s\033[0m\n" "$*"; }
log_warn()    { printf "\033[1;33m!!! %s\033[0m\n" "$*" >&2; }
log_error()   { printf "\033[1;31m*** %s\033[0m\n" "$*" >&2; }
log_success() { printf "\033[1;32m### %s\033[0m\n" "$*"; }

prepare_log() {
    local pkg="$1"
    mkdir -p "$LOG/$pkg"
    LOG_FILE="$LOG/$pkg/$pkg.log"
    : > "$LOG_FILE"
}

run_hook() {
    local hook_name="$1"
    local hook_cmd
    hook_cmd=$(eval "echo \${$hook_name}")
    [ -n "$hook_cmd" ] && log_info "Executando hook $hook_name" 
}

spinner() {
    local pid=$1 delay=0.1 spinstr='|/-\'
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "      \b\b\b\b\b\b"
}

run_cmd() {
    local cmd="$*"
    log_info "Executando: $cmd"
    bash -c "$cmd" >>"$LOG_FILE" 2>&1 &
    local pid=$!
    spinner $pid
    wait $pid
    local ret=$?
    [ $ret -ne 0 ] && log_error "Comando falhou: $cmd" || log_success "Comando concluído"
    return $ret
}

### -------------------------
### Parser de receitas
### -------------------------
load_recipe() {
    local target="$1"
    CATEGORY=$(echo "$target" | cut -d'/' -f1)
    PKGNAME=$(echo "$target" | cut -d'/' -f2)
    [ -z "$CATEGORY" ] && log_error "Categoria não especificada." && exit 1
    [ -z "$PKGNAME" ] && log_error "Pacote não especificado." && exit 1

    local recipe="$REPO/$CATEGORY/$PKGNAME/recipe"
    [ ! -f "$recipe" ] && log_error "Receita não encontrada: $recipe" && exit 1

    # Reset variáveis
    NAME="" VERSION="" SUMMARY="" HOMEPAGE="" LICENSE=""
    BUILD_SYSTEM="" SOURCES=() SHA256S=() BUILD_DEPS=() RUN_DEPS=() CONFIGURE_ARGS=() PATCHES=()
    HOOK_PRE_FETCH="" HOOK_POST_FETCH="" HOOK_PRE_BUILD="" HOOK_POST_BUILD="" HOOK_PRE_INSTALL="" HOOK_POST_INSTALL="" HOOK_PRE_CLEAN="" HOOK_POST_CLEAN="" HOOK_PRE_PACKAGE="" HOOK_POST_PACKAGE=""
    . "$recipe"
    log_info "Receita carregada: $NAME $VERSION (build=$BUILD_SYSTEM)"
}

### -------------------------
### Hooks pré/pós etapas
### -------------------------
hook_pre_fetch() { run_hook "HOOK_PRE_FETCH"; }
hook_post_fetch() { run_hook "HOOK_POST_FETCH"; }
hook_pre_build() { run_hook "HOOK_PRE_BUILD"; }
hook_post_build() { run_hook "HOOK_POST_BUILD"; }
hook_pre_install() { run_hook "HOOK_PRE_INSTALL"; }
hook_post_install() { run_hook "HOOK_POST_INSTALL"; }
hook_pre_clean() { run_hook "HOOK_PRE_CLEAN"; }
hook_post_clean() { run_hook "HOOK_POST_CLEAN"; }
hook_pre_package() { run_hook "HOOK_PRE_PACKAGE"; }
hook_post_package() { run_hook "HOOK_POST_PACKAGE"; }

### -------------------------
### SHA256 / validação
### -------------------------
check_sha256() {
    local file="$1" expected="$2"
    [ ! -f "$file" ] && log_error "Arquivo não encontrado: $file" && return 1
    local actual=$(sha256sum "$file" | awk '{print $1}')
    [ "$actual" != "$expected" ] && log_error "SHA256 mismatch: $file" && return 1
    log_info "SHA256 OK: $file"
}
verify_sources() {
    for i in "${!SOURCES[@]}"; do
        local src="${SOURCES[$i]}" sha="${SHA256S[$i]}" file="$SRC/$PKGNAME/$(basename "$src")"
        [ -f "$file" ] && check_sha256 "$file" "$sha" || log_warn "Arquivo não encontrado, ignorando SHA256: $file"
    done
}

### -------------------------
### Dependências
### -------------------------
check_build_deps() { for dep in "${BUILD_DEPS[@]}"; do log_info "Dependência build: $dep"; done }
check_run_deps() { for dep in "${RUN_DEPS[@]}"; do log_info "Dependência run: $dep"; done }
install_build_deps() { for dep in "${BUILD_DEPS[@]}"; do log_info "Instalando dependência build: $dep"; done }
install_run_deps() { for dep in "${RUN_DEPS[@]}"; do log_info "Instalando dependência run: $dep"; done }

### -------------------------
### Build handlers (esqueleto)
### -------------------------
build_autotools() { log_info "[autotools] Construindo $NAME"; }
build_meson() { log_info "[meson] Construindo $NAME"; }
build_cmake() { log_info "[cmake] Construindo $NAME"; }
build_cargo() { log_info "[cargo] Construindo $NAME"; }
build_wheel() { log_info "[wheel] Construindo $NAME"; }
build_make() { log_info "[make] Construindo $NAME"; }
build_custom() { log_info "[custom] Construindo $NAME"; }
build_meta() { log_info "[meta] Pacote meta, nada para construir"; }

### -------------------------
### Install handlers (esqueleto)
### -------------------------
install_autotools() { log_info "[autotools] Instalando $NAME"; }
install_meson() { log_info "[meson] Instalando $NAME"; }
install_cmake() { log_info "[cmake] Instalando $NAME"; }
install_cargo() { log_info "[cargo] Instalando $NAME"; }
install_wheel() { log_info "[wheel] Instalando $NAME"; }
install_make() { log_info "[make] Instalando $NAME"; }
install_custom() { log_info "[custom] Instalando $NAME"; }
install_meta() { log_info "[meta] Pacote meta, nada para instalar"; }

### -------------------------
### Package handlers (esqueleto)
### -------------------------
package_autotools() { log_info "[autotools] Empacotando $NAME"; }
package_meson() { log_info "[meson] Empacotando $NAME"; }
package_cmake() { log_info "[cmake] Empacotando $NAME"; }
package_cargo() { log_info "[cargo] Empacotando $NAME"; }
package_wheel() { log_info "[wheel] Empacotando $NAME"; }
package_make() { log_info "[make] Empacotando $NAME"; }
package_custom() { log_info "[custom] Empacotando $NAME"; }
package_meta() { log_info "[meta] Registro metapacote $NAME"; }

### -------------------------
### Clean handlers (esqueleto)
### -------------------------
clean_autotools() { log_info "[autotools] Limpando $NAME"; }
clean_meson() { log_info "[meson] Limpando $NAME"; }
clean_cmake() { log_info "[cmake] Limpando $NAME"; }
clean_cargo() { log_info "[cargo] Limpando $NAME"; }
clean_wheel() { log_info "[wheel] Limpando $NAME"; }
clean_make() { log_info "[make] Limpando $NAME"; }
clean_custom() { log_info "[custom] Limpando $NAME"; }
clean_meta() { log_info "[meta] Pacote meta, nada para limpar"; }

### -------------------------
### Funções principais
### -------------------------
fetch() {
    load_recipe "$1"
    prepare_log "$PKGNAME"
    hook_pre_fetch
    log_info "Baixando fontes: ${SOURCES[*]}"
    hook_post_fetch
    log_success "Fetch concluído para $NAME"
}

extract() {
    load_recipe "$1"
    prepare_log "$PKGNAME"
    hook_pre_extract() { run_hook "HOOK_PRE_EXTRACT"; }
    hook_post_extract() { run_hook "HOOK_POST_EXTRACT"; }
    hook_pre_extract
    log_info "Extraindo fontes de $NAME"
    verify_sources
    hook_post_extract
    log_success "Extração concluída para $NAME"
}

build() {
    load_recipe "$1"
    prepare_log "$PKGNAME"
    hook_pre_build
    check_build_deps "$PKGNAME"
    install_build_deps "$PKGNAME"
    case "$BUILD_SYSTEM" in
        autotools) build_autotools ;; meson) build_meson ;; cmake) build_cmake ;; cargo) build_cargo ;; wheel|python) build_wheel ;; make) build_make ;; custom) build_custom ;; meta) build_meta ;; *) log_error "Sistema de build desconhecido"; exit 1 ;; 
    esac
    hook_post_build
    log_success "$NAME construído com sucesso"
}

install_pkg() {
    load_recipe "$1"
    prepare_log "$PKGNAME"
    hook_pre_install
    check_run_deps "$PKGNAME"
    install_run_deps "$PKGNAME"
    case "$BUILD_SYSTEM" in
        autotools) install_autotools ;; meson) install_meson ;; cmake) install_cmake ;; cargo) install_cargo ;; wheel|python) install_wheel ;; make) install_make ;; custom) install_custom ;; meta) install_meta ;; *) log_error "Sistema de build desconhecido"; exit 1 ;; 
    esac
    hook_post_install
    log_success "$NAME instalado com sucesso"
}

package() {
    load_recipe "$1"
    prepare_log "$PKGNAME"
    hook_pre_package
    case "$BUILD_SYSTEM" in
        autotools) package_autotools ;; meson) package_meson ;; cmake) package_cmake ;; cargo) package_cargo ;; wheel|python) package_wheel ;; make) package_make ;; custom) package_custom ;; meta) package_meta ;; *) log_error "Sistema de build desconhecido"; exit 1 ;; 
    esac
    hook_post_package
    log_success "$NAME empacotado com sucesso"
}

clean() {
    load_recipe "$1"
    prepare_log "$PKGNAME"
    hook_pre_clean
    case "$BUILD_SYSTEM" in
        autotools) clean_autotools ;; meson) clean_meson ;; cmake) clean_cmake ;; cargo) clean_cargo ;; wheel|python) clean_wheel ;; make) clean_make ;; custom) clean_custom ;; meta) clean_meta ;; *) log_error "Sistema de build desconhecido"; exit 1 ;; 
    esac
    hook_post_clean
    log_success "$NAME limpo com sucesso"
}

### -------------------------
### Upgrade, revdep, search, info, remove, system rebuild
### -------------------------
upgrade() { log_info "Upgrade do sistema (esqueleto)"; }
revdep() { load_recipe "$1"; log_info "Verificando dependências reversas (esqueleto)"; }
search() { log_info "Buscando pacotes para: $1 (esqueleto)"; }
info() { load_recipe "$1"; log_info "Informações de $NAME"; echo "Resumo: $SUMMARY"; echo "Licença: $LICENSE"; echo "BuildSystem: $BUILD_SYSTEM"; }
remove_pkg() { load_recipe "$1"; log_info "Removendo $NAME (esqueleto)"; }

system_rebuild() {
    log_info "Rebuild do sistema iniciado"
    for cat in $(ls -1 "$REPO"); do
        for pkg in $(ls -1 "$REPO/$cat"); do
            full="$cat/$pkg"
            load_recipe "$full"
            hook_pre_build
            check_build_deps "$full"
            install_build_deps "$full"
            case "$BUILD_SYSTEM" in
                autotools) build_autotools; install_autotools ;; meson) build_meson; install_meson ;; cmake) build_cmake; install_cmake ;; cargo) build_cargo; install_cargo ;; wheel|python) build_wheel; install_wheel ;; make) build_make; install_make ;; custom) build_custom; install_custom ;; meta) build_meta; ;; *) log_error "Sistema de build desconhecido" ;; 
            esac
            package "$full"
            hook_post_build
            log_success "$NAME recompilado com sucesso"
        done
    done
    log_info "Rebuild do sistema concluído"
}

### -------------------------
### CLI parser
### -------------------------
[ $# -lt 1 ] && echo "Uso: $0 <ação> <pacote>" && exit 0
ACTION="$1"; shift
case "$ACTION" in
    fetch) fetch "$1" ;; extract) extract "$1" ;; build|b) build "$1" ;; install|i) install_pkg "$1" ;; package|p) package "$1" ;; clean) clean "$1" ;; manifest) log_info "Manifest (esqueleto)" ;; search|s) search "$1" ;; info) info "$1" ;; upgrade|u) upgrade ;; revdep) revdep "$1" ;;
