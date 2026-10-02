#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

readonly REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly NVIM_CONFIG="$CONFIG_HOME/nvim"
readonly LOCAL_BIN="$HOME/.local/bin"
readonly ORIGINAL_PATH="$PATH"
readonly MIN_NVIM_MAJOR=0
readonly MIN_NVIM_MINOR=11
readonly NVIM_RELEASE="${NVIM_RELEASE:-v0.11.6}"

log() {
  printf '\n==> %s\n' "$*"
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

nvim_is_new_enough() {
  local version major minor
  has_command nvim || return 1
  version="$(nvim --version | sed -n '1s/^NVIM v\([0-9][0-9.]*\).*$/\1/p')"
  major="${version%%.*}"
  version="${version#*.}"
  minor="${version%%.*}"
  [[ "$major" =~ ^[0-9]+$ && "$minor" =~ ^[0-9]+$ ]] || return 1
  (( major > MIN_NVIM_MAJOR || (major == MIN_NVIM_MAJOR && minor >= MIN_NVIM_MINOR) ))
}

install_ubuntu_packages() {
  local -a packages=(
    build-essential
    ca-certificates
    curl
    git
    golang-go
    neovim
    nodejs
    npm
    python3
    python3-venv
    ripgrep
    default-jdk
  )
  local -a missing=()
  local package

  has_command apt-get || die "apt-get が見つかりません。Ubuntu / Debian 系の環境で実行してください。"
  for package in "${packages[@]}"; do
    if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'install ok installed'; then
      missing+=("$package")
    fi
  done

  if ((${#missing[@]} == 0)); then
    log "Ubuntu packages はすべて導入済みです"
    return
  fi

  log "不足している Ubuntu packages を導入します: ${missing[*]}"
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
}

install_official_nvim_linux() {
  local machine asset archive checksum_file tmp_dir install_root install_dir
  machine="$(uname -m)"
  case "$machine" in
    x86_64) asset="nvim-linux-x86_64" ;;
    aarch64|arm64) asset="nvim-linux-arm64" ;;
    *) die "Neovim 0.11 以上が必要ですが、architecture $machine の自動導入には対応していません。" ;;
  esac

  archive="$asset.tar.gz"
  checksum_file="shasum.txt"
  tmp_dir="$(mktemp -d)"
  install_root="$HOME/.local/opt"
  install_dir="$install_root/nvim-$NVIM_RELEASE"
  trap 'rm -rf -- "$tmp_dir"' RETURN

  log "Neovim $NVIM_RELEASE 公式 release を user directory に導入します"
  curl --fail --location --proto '=https' --tlsv1.2 \
    --output "$tmp_dir/$archive" \
    "https://github.com/neovim/neovim/releases/download/$NVIM_RELEASE/$archive"
  curl --fail --location --proto '=https' --tlsv1.2 \
    --output "$tmp_dir/$checksum_file" \
    "https://github.com/neovim/neovim/releases/download/$NVIM_RELEASE/$checksum_file"

  (
    cd "$tmp_dir"
    grep "  $archive\$" "$checksum_file" | sha256sum --check --status -
  ) || die "Neovim archive の SHA-256 verification に失敗しました。"

  mkdir -p -- "$install_root" "$LOCAL_BIN"
  if [[ ! -d "$install_dir" ]]; then
    tar -xzf "$tmp_dir/$archive" -C "$tmp_dir"
    mv -- "$tmp_dir/$asset" "$install_dir"
  fi
  ln -sfn -- "$install_dir/bin/nvim" "$LOCAL_BIN/nvim"
  export PATH="$LOCAL_BIN:$PATH"
  trap - RETURN
  rm -rf -- "$tmp_dir"
}

install_macos_packages() {
  local brew_prefix openjdk_prefix
  has_command brew || die "Homebrew が必要です。https://brew.sh/ の公式手順で導入してから再実行してください。"

  if ! xcode-select -p >/dev/null 2>&1; then
    log "Xcode Command Line Tools の installer を開きます"
    xcode-select --install || true
    die "導入を完了してから setup.sh を再実行してください。"
  fi

  log "Homebrew packages を確認・導入します"
  brew install git neovim ripgrep node python go openjdk

  brew_prefix="$(brew --prefix)"
  openjdk_prefix="$(brew --prefix openjdk)"
  export PATH="$brew_prefix/bin:$openjdk_prefix/bin:$LOCAL_BIN:$PATH"
  mkdir -p -- "$LOCAL_BIN"
  if [[ -x "$openjdk_prefix/bin/java" ]]; then
    ln -sfn -- "$openjdk_prefix/bin/java" "$LOCAL_BIN/java"
  fi
  if [[ -x "$openjdk_prefix/bin/javac" ]]; then
    ln -sfn -- "$openjdk_prefix/bin/javac" "$LOCAL_BIN/javac"
  fi
}

link_config() {
  local current_target
  mkdir -p -- "$CONFIG_HOME"

  if [[ "$REPO_DIR" == "$NVIM_CONFIG" ]]; then
    log "この repository はすでに $NVIM_CONFIG にあります"
    return
  fi

  if [[ -L "$NVIM_CONFIG" ]]; then
    current_target="$(cd -- "$(dirname -- "$NVIM_CONFIG")" && cd -- "$(readlink "$NVIM_CONFIG")" 2>/dev/null && pwd -P || true)"
    if [[ "$current_target" == "$REPO_DIR" ]]; then
      log "$NVIM_CONFIG はすでにこの repository を参照しています"
      return
    fi
    die "$NVIM_CONFIG は別の場所を参照する symbolic link です。確認して手動で退避してください。"
  fi

  if [[ -e "$NVIM_CONFIG" ]]; then
    die "$NVIM_CONFIG がすでに存在します。内容を確認して手動で退避してから再実行してください。"
  fi

  ln -s -- "$REPO_DIR" "$NVIM_CONFIG"
  log "$NVIM_CONFIG -> $REPO_DIR を作成しました"
}

install_gopls() {
  if has_command gopls || [[ -x "$HOME/go/bin/gopls" ]]; then
    log "gopls は導入済みです"
    return
  fi
  has_command go || die "Go が見つからないため gopls を導入できません。"
  log "gopls を導入します"
  go install golang.org/x/tools/gopls@latest
}

check_prerequisites() {
  local -a required=(git nvim rg node npm python3 go java javac cc)
  local -a missing=()
  local command_name
  for command_name in "${required[@]}"; do
    has_command "$command_name" || missing+=("$command_name")
  done
  ((${#missing[@]} == 0)) || die "必要な commands が見つかりません: ${missing[*]}"
  nvim_is_new_enough || die "Neovim 0.11 以上が必要です。現在 PATH 上にある nvim を確認してください。"
}

sync_neovim_tools() {
  log "Neovim plugins を同期します"
  nvim --headless "+Lazy! sync" +qa

  log "Tree-sitter parsers を同期します"
  nvim --headless "+TSUpdateSync" +qa

  log "Mason の自動導入を待ちます（最大 5 分）"
  nvim --headless \
    "+lua local bins={'typescript-language-server','vscode-html-language-server','vscode-css-language-server','vscode-json-language-server','yaml-language-server','basedpyright-langserver','jdtls','bash-language-server'}; local ok=vim.wait(300000,function() for _,b in ipairs(bins) do if vim.fn.executable(b)==0 then return false end end return true end,500); if not ok then vim.api.nvim_err_writeln('Mason tools の一部が時間内に導入されませんでした。:Mason で確認してください。'); vim.cmd('cq') end" \
    +qa

  log "Neovim の headless 起動を確認します"
  nvim --headless "+lua print('Neovim configuration OK')" +qa
}

main() {
  case "$(uname -s)" in
    Linux)
      if [[ ! -r /etc/os-release ]]; then
        die "/etc/os-release を読めないため Linux distribution を判定できません。"
      fi
      # shellcheck disable=SC1091
      . /etc/os-release
      case "${ID:-}" in
        ubuntu|debian) install_ubuntu_packages ;;
        *) die "この script の Linux package 自動導入は Ubuntu / Debian のみ対応です（検出: ${ID:-unknown}）。" ;;
      esac
      nvim_is_new_enough || install_official_nvim_linux
      ;;
    Darwin)
      install_macos_packages
      ;;
    *) die "対応 OS は WSL / Ubuntu / Debian / macOS です。" ;;
  esac

  export PATH="$LOCAL_BIN:$HOME/go/bin:$PATH"
  check_prerequisites
  link_config
  install_gopls
  sync_neovim_tools

  log "セットアップが完了しました"
  printf '%s\n' \
    "nvim を起動し、:checkhealth / :Lazy / :Mason / :LspInfo を確認してください。" \
    "SSH キーと GitHub の認証設定は変更していません。"
  case ":$ORIGINAL_PATH:" in
    *":$LOCAL_BIN:"*) ;;
    *) printf '今後も user-local tools を使うため、shell の PATH に %s を追加してください。\n' "$LOCAL_BIN" ;;
  esac
}

main "$@"
