# nvim-setting

Go / Web 開発と大学のプログラミング課題で使う、自分用の Neovim 設定です。新しい WSL / Ubuntu / macOS 環境でも同じ編集環境を再現できるよう、設定本体とプラグインのロックファイル、セットアップスクリプトをまとめています。

この README は、Neovim を使い始めたばかりの自分が数か月後に見返しても、構成・操作・復元方法が分かることを目的にしています。

## 対応環境と前提

- Neovim 0.11 以上（`vim.lsp.config` / `vim.lsp.enable` を使用）
- WSL 2 / Ubuntu、または macOS
- Git
- ripgrep（Telescope の全文検索に必要）
- Node.js / npm（TypeScript、HTML、CSS、JSON、YAML、Bash の Language Server に必要）
- Python 3（basedpyright と jdtls の導入に必要。Ubuntu では `python3-venv` も必要）
- Go（`gopls` の導入に必要）
- JDK（Java Language Server の jdtls に必要）
- C compiler（Tree-sitter parser のビルドに必要。Ubuntu は `build-essential`、macOS は Xcode Command Line Tools）
- アイコンを正しく表示する場合は Nerd Font（なくても編集機能自体は使えます）

`setup.sh` は不足している前提ツールを準備し、`gopls`、プラグイン、Tree-sitter parser、Mason 管理の Language Server を導入します。既存の `~/.config/nvim` は上書きせず、SSH キーや GitHub の認証設定にも触れません。

## 対応言語

| 言語・ファイル | Tree-sitter | LSP | 補足 |
| --- | :---: | :---: | --- |
| Go / `go.mod` / `go.sum` | ○ | ○ | 保存時に `gopls` で format |
| TypeScript | ○ | ○ | `ts_ls` |
| JavaScript | ○ | ○ | `ts_ls` |
| React / TSX | ○ | ○ | `ts_ls` |
| HTML | ○ | ○ | `html` |
| CSS | ○ | ○ | `cssls` |
| JSON / JSONC | ○ | ○ | `jsonls` |
| YAML | ○ | ○ | `yamlls` |
| Python | ○ | ○ | `basedpyright` |
| Java | ○ | ○ | `jdtls` |
| Bash | ○ | ○ | `bashls` |
| Markdown | ○ | ― | 構文ハイライトのみ |
| Lua | ○ | ― | Neovim 設定の構文ハイライトのみ |

## 主な機能

| 機能 | 役割 |
| --- | --- |
| [lazy.nvim](https://github.com/folke/lazy.nvim) | プラグインの導入・更新・遅延読み込みを管理する |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | コードを構文として解析し、精度の高いハイライトを行う |
| [Mason](https://github.com/mason-org/mason.nvim) | Language Server など、Neovim が使う開発ツールを管理する |
| Neovim LSP | エラー表示、定義ジャンプ、参照検索、名前変更などを行う |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | LSP が返した候補を補完メニューとして表示する |
| [Telescope](https://github.com/nvim-telescope/telescope.nvim) | ファイル、文字列、開いている buffer、help を検索する |
| [neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim) | ディレクトリとファイルをツリー表示する |
| [gitsigns](https://github.com/lewis6991/gitsigns.nvim) | Git の追加・変更・削除箇所を行番号の横に表示する |

プラグインのバージョンは `lazy-lock.json` に固定されています。そのため、別環境でも同じ commit のプラグインを再現できます。

## LSP 一覧

実設定は `lua/config/lsp.lua` と `lua/plugins/lsp.lua` にあります。

| 言語 | Language Server | 導入方法 |
| --- | --- | --- |
| Go | `gopls` | `go install` |
| TypeScript / JavaScript / TSX | `ts_ls` | Mason |
| HTML | `html` | Mason |
| CSS | `cssls` | Mason |
| JSON / JSONC | `jsonls` | Mason |
| YAML | `yamlls` | Mason |
| Python | `basedpyright` | Mason |
| Java | `jdtls` | Mason |
| Bash | `bashls` | Mason |

Mason 管理の server は必要な実行環境があるものだけ導入されます。たとえば JDK がない環境では `jdtls` を無理に導入せず、Neovim の起動を妨げません。`gopls` は Mason ではなく Go 公式の方法で導入し、PATH 上になければ `~/go/bin/gopls` を使います。

## よく使うキーマップ

`<leader>` は Space キーです。たとえば `<leader>ff` は「Space を押してから `f`、`f`」です。

### 自分で定義しているキー

| キー | 動作 | 有効になる場面 |
| --- | --- | --- |
| `<leader>ff` | ファイル名を検索 | 通常モード |
| `<leader>fg` | プロジェクト内の文字列を全文検索 | 通常モード、ripgrep が必要 |
| `<leader>fb` | 開いている buffer を検索 | 通常モード |
| `<leader>fh` | Neovim の help を検索 | 通常モード |
| `<leader>e` | ファイルツリーを開く / 閉じる | 通常モード |
| `]h` | 次の Git 変更箇所へ移動 | Git 管理下の buffer |
| `[h` | 前の Git 変更箇所へ移動 | Git 管理下の buffer |
| `<leader>hp` | 現在の Git 変更箇所を preview | Git 管理下の buffer |
| `<leader>hb` | 現在行の詳細な Git blame を表示 | Git 管理下の buffer |
| `gd` | 定義へ移動 | LSP 接続中 |
| `gD` | 宣言へ移動 | LSP 接続中 |

### Neovim 0.11 標準の LSP キー

次のキーはこの設定が独自に追加したものではなく、Neovim 0.11 が LSP 接続時に提供する標準キーマップです。

| キー | 動作 |
| --- | --- |
| `K` | カーソル位置の型や説明を表示（hover） |
| `grn` | 変数や関数などの名前を変更（rename） |
| `grr` | 参照箇所を一覧表示（references） |
| `gra` | code action を表示 |
| `gri` | 実装へ移動（implementation） |
| `gO` | document symbol を一覧表示 |
| `<C-s>` | 関数の引数情報を表示（Insert mode） |

### 補完メニュー（Insert mode）

| キー | 動作 |
| --- | --- |
| `<C-n>` | 次の候補を選ぶ |
| `<C-p>` | 前の候補を選ぶ |
| `<C-y>` | 選択中の候補を確定 |
| `Enter` | 明示的に選択した候補だけを確定。未選択なら通常の改行 |
| `<C-Space>` | 補完候補を手動で表示 |
| `<C-e>` | 補完メニューを閉じる |
| `<C-b>` | 補完ドキュメントを上へ 4 行 scroll |
| `<C-f>` | 補完ドキュメントを下へ 4 行 scroll |

## 初心者向け Neovim 基本操作

Neovim は、文字を入力する Insert mode と、移動・操作を行う Normal mode を切り替えて使います。困ったらまず `Esc` を押して Normal mode に戻ります。

| キー / コマンド | 動作 |
| --- | --- |
| `i` | Insert mode に入る |
| `Esc` | Normal mode に戻る |
| `:w` | 保存する |
| `:q` | ウィンドウを閉じる |
| `:wq` | 保存して閉じる |
| `:q!` | 未保存の変更を破棄して閉じる |
| `u` | 取り消す（undo） |
| `Ctrl-r` | 取り消しを戻す（redo） |
| `dd` | 現在行を削除する |
| `yy` | 現在行をコピーする |
| `p` | カーソルの後ろに貼り付ける |
| `/文字列` | 下方向に検索する |
| `n` / `N` | 次 / 前の検索結果へ移動する |
| `gg` / `G` | ファイルの先頭 / 末尾へ移動する |
| `:help キーワード` | help を開く。例: `:help vim.lsp` |

ファイルツリーや help でウィンドウが分かれた場合は `Ctrl-w` の後に `h` / `j` / `k` / `l` を押すと、左 / 下 / 上 / 右のウィンドウへ移動できます。

## ディレクトリ構成

```text
.
├── init.lua                 # leader、表示、indent などの基本設定と入口
├── lazy-lock.json           # プラグインのバージョン固定
├── setup.sh                 # 新しい環境を準備するスクリプト
└── lua
    ├── config
    │   ├── lazy.lua         # lazy.nvim の導入と runtimepath 対策
    │   └── lsp.lua          # 共通 LSP 設定、gopls、LSP キー、Go format
    └── plugins
        ├── cmp.lua          # 補完
        ├── gitsigns.lua     # Git 差分表示とキー
        ├── lsp.lua          # Mason と Language Server 一覧
        ├── neo-tree.lua     # ファイルツリー
        ├── telescope.lua    # 検索
        └── treesitter.lua   # 対応 parser とハイライト
```

プラグイン本体、Mason のツール、cache はリポジトリ内ではなく Neovim の標準 data/cache directory に保存されます。通常は Linux では `~/.local/share/nvim`、macOS では `~/Library/Application Support/nvim` です。

## 新しい環境への導入

### 自動セットアップ（推奨）

GitHub に接続できる状態で、任意の作業用 directory に clone して実行します。

```bash
git clone git@github.com:o1m0/nvim-setting.git
cd nvim-setting
./setup.sh
```

SSH 認証をまだ用意していない場合は HTTPS でも clone できます。`setup.sh` 自身は SSH キーや認証設定を作成・変更しません。

```bash
git clone https://github.com/o1m0/nvim-setting.git
cd nvim-setting
./setup.sh
```

スクリプトはこの repository を `~/.config/nvim` から参照できるように symbolic link を作ります。すでに別のファイルや directory がある場合は、安全のため停止します。内容を確認して自分で退避してから再実行してください。

Ubuntu / WSL では `sudo apt-get`、macOS では Homebrew を使います。Homebrew がない場合や Xcode Command Line Tools の導入が必要な場合は、画面の案内を完了してからもう一度実行します。Ubuntu の package が Neovim 0.11 未満なら、公式 release を `~/.local/opt` に導入して `~/.local/bin/nvim` から使えるようにします。

セットアップ後に診断を確認します。

```bash
nvim
```

Neovim 内で次を実行できます。

```vim
:checkhealth
:Lazy
:Mason
:LspInfo
```

### 手動で導入する場合

前提ツールを用意した後、repository を Neovim の設定 directory として clone します。`~/.config/nvim` がすでに存在すると clone は失敗するため、先に中身を確認してください。

```bash
git clone git@github.com:o1m0/nvim-setting.git ~/.config/nvim
go install golang.org/x/tools/gopls@latest
nvim
```

初回起動時は lazy.nvim がプラグインを、Mason が利用可能な Language Server を download します。終わるまで少し待ち、必要なら `:Lazy sync` と `:Mason` で状態を確認します。

## 設定を更新する

別 PC で GitHub 上の更新を取り込む場合:

```bash
cd ~/.config/nvim
git status
git pull --ff-only
nvim --headless "+Lazy! sync" +qa
```

`git status` で自分の未保存変更がないことを確認してから pull します。`--ff-only` は意図しない merge commit を作らないための指定です。

自分で設定を編集して GitHub へ反映する場合:

```bash
cd ~/.config/nvim
git diff
git add README.md setup.sh lua init.lua lazy-lock.json
git commit -m "Update Neovim configuration"
git push
```

`git diff` で内容を確認し、秘密情報や個人用 token が入っていないことを確認してから commit します。

プラグインを更新したい場合は Neovim で `:Lazy update`、Tree-sitter parser は `:TSUpdate` を実行します。更新後は `lazy-lock.json` の差分も確認します。

## `/usr/lib/nvim` の runtimepath 対策

Ubuntu の Neovim package では、Neovim に同梱された Tree-sitter parser が `/usr/lib/nvim` にあります。一方、lazy.nvim が起動を高速化するため runtimepath を組み直す際、環境によっては library directory を `/usr/lib64/nvim` と推測し、実際の `/usr/lib/nvim` が runtimepath から抜けることがあります。

この directory が抜けると、Neovim 同梱の `vim` / `vimdoc` / `query` / `c` parser を見つけられず、ハイライトや `:checkhealth` で問題が出ます。`lua/config/lazy.lua` は、実行中の `nvim` binary の場所から対応する `lib/nvim` を計算し、実在するときだけ lazy.nvim の runtimepath に追加します。

固定文字列の `/usr/lib/nvim` を無条件に追加していないため、Homebrew の配置が異なる macOS でも同じ設定を使えます。macOS では通常、すでに含まれている directory を再指定するだけなので害はありません。この対策を削除する場合は、先に次で runtimepath と Tree-sitter の health を確認します。

```vim
:set runtimepath?
:checkhealth vim.treesitter
```

## トラブルシューティング

### `nvim` が古い / LSP 設定でエラーになる

```bash
nvim --version | head -n 1
```

`NVIM v0.11` 以上が必要です。`setup.sh` を再実行し、`~/.local/bin` が PATH に含まれているか確認します。

### `<leader>fg` で全文検索できない

```bash
rg --version
```

command が見つからない場合は ripgrep を導入するか `setup.sh` を再実行します。

### 補完、定義ジャンプ、エラー表示が動かない

対象ファイルを開いた状態で `:LspInfo` を実行し、Language Server が接続されているか確認します。`:Mason` で server の導入状態、`:checkhealth vim.lsp` で LSP の診断を確認します。Node、Python、JDK などの前提が後から揃った場合は Neovim を再起動すると Mason の自動導入対象になります。

### Go だけ LSP が起動しない

```bash
go version
~/go/bin/gopls version
```

`gopls` がなければ次を実行します。

```bash
go install golang.org/x/tools/gopls@latest
```

### Java の LSP が起動しない

```bash
java -version
javac -version
```

両方が見つかることを確認します。macOS で Homebrew の `openjdk` を入れた直後は、`setup.sh` の最後に表示される PATH の案内も確認します。

### Tree-sitter parser のエラーが出る

C compiler を確認してから parser を更新します。

```bash
cc --version
nvim --headless "+TSUpdateSync" +qa
```

Neovim 内では `:checkhealth vim.treesitter` も確認します。Ubuntu で同梱 parser だけが見つからない場合は、前述の `/usr/lib/nvim` が `:set runtimepath?` に含まれるか確認します。

### プラグインの導入や更新に失敗する

GitHub へ接続できることを確認し、Neovim で `:Lazy sync` を再実行します。状態が分からない場合は `:Lazy log` と `:checkhealth lazy` を確認します。むやみに `~/.local/share/nvim` 全体を削除せず、先にエラー内容を確認してください。

### 設定を一時的に無効化して起動したい

```bash
nvim --clean
```

これは現在の設定を読み込まずに Neovim を起動します。設定ファイル自体は削除されません。
