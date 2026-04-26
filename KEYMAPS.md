# Neovim Keymaps

這份速查表只整理目前這套設定最常用、最值得記的快捷鍵。

## First 7 Days

- Day 1: `<Space>`  
  先學會叫出 `which-key`，忘記快捷鍵就靠它。

- Day 2: `<leader><space>`  
  找檔案，這會是最常用的入口。

- Day 3: `<leader>/`  
  全專案搜尋字串。

- Day 4: `gd`  
  跳到 definition，看 code 最常用。

- Day 5: `<leader>ca`  
  code action，修正與重構很常用。

- Day 6: `<leader>tf`  
  打開浮動 terminal。

- Day 7: `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>`  
  在視窗之間切換。

## Top 10 Daily

- `<Space>`: 叫出 `which-key`
- `<leader><space>`: 找檔案
- `<leader>/`: 全專案 grep
- `<leader>,`: 切換 buffer
- `<leader>bd`: 關閉目前 buffer
- `gd`: 跳到 definition
- `<leader>ca`: code action
- `<leader>cr`: rename symbol
- `<leader>tf`: 浮動 terminal
- `<leader>tg`: lazygit
- `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>`: 切換視窗

## Tips

- `leader` = `<Space>`
- `localleader` = `<Space>`
- 按 `<Space>` 停一下，可以叫出 `which-key`
- 按 `<leader>?` 可以看目前 buffer 的快捷鍵
- 按 `<C-w><Space>` 可以看視窗相關快捷鍵
- AI 需要先設定 `AVANTE_OPENAI_API_KEY` 或 `OPENAI_API_KEY`
- 標註 `(custom)` 表示自訂覆蓋了 LazyVim 預設行為，看別人教學時要注意

## Symbol 查找

游標放在 symbol 上：

- `gd`: 跳到 definition
- `gr`: 找出所有 references（**這個 symbol 在哪邊被用到**）
- `gI`: 跳到 implementation
- `gy`: 跳到 type definition
- `gD`: 跳到 declaration
- `K`: hover 看文件
- `<leader>cr`: rename symbol
- `<leader>ca`: code action

整檔 / 整個 workspace 看 symbol 列表：

- `<leader>ss`: 目前檔案的 symbols（picker 列出）
- `<leader>sS`: workspace symbols
- `<leader>cs`: trouble 開 symbols 樹狀視窗（停留式）
- `<leader>cS`: trouble 開 LSP references / definitions / implementations（停留式）

picker 結果上的常用鍵：`<CR>` 跳過去、`<C-v>` 垂直開、`<C-x>` 水平開、`<Esc>` / `q` 關閉。

## Search

- `<leader><space>`: 找檔案
- `<leader>,`: 切換 buffer
- `<leader>ff`: 找檔案
- `<leader>fF`: 在目前 cwd 找檔案
- `<leader>fg`: 找 git tracked files
- `<leader>fp`: Projects
- `<leader>fr`: 最近開過的檔案
- `<leader>fc`: 找 nvim config 檔案
- `<leader>/`: 全專案 grep
- `<leader>sg`: 全專案 grep
- `<leader>sG`: 目前 cwd grep
- `<leader>sw`: 搜尋游標下單字
- `<leader>sk`: 搜尋 keymaps
- `<leader>sh`: 搜尋 help
- `<leader>sd`: 搜尋 diagnostics
- `<leader>ss`: 搜尋目前檔案 symbols
- `<leader>sS`: 搜尋 workspace symbols

## Buffers

- `<leader>bd`: 關閉目前 buffer
- `<leader>bo`: 關閉其他 buffers
- `<leader>bD`: 關閉目前 buffer 和視窗
- `<leader>bp`: pin / unpin buffer
- `<leader>bP`: 關閉所有未 pin 的 buffers
- `<leader>bj`: 選擇 buffer
- `<S-h>` / `<S-l>`: 上一個 / 下一個 buffer
- `<C-w>h` / `<C-w>l`: 上一個 / 下一個 buffer (custom，原本是 window 操作)
- `[b` / `]b`: 上一個 / 下一個 buffer
- `[B` / `]B`: 左移 / 右移 buffer

## Windows

> 注意：以下 `<leader>w*` 系列是 custom 加的（LazyVim 預設要按 `<C-w>` 系列才是 split 操作）。

- `<leader>wv`: 垂直分割 (custom)
- `<leader>ws`: 水平分割 (custom)
- `<leader>we`: 平衡視窗大小 (custom)
- `<leader>wx`: 關閉目前視窗 (custom)
- `\w`: 關閉目前視窗 (custom)
- `<C-w>w`: 關閉目前視窗 (custom，原本 vim 預設是「跳到下個 window」)
- `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>`: 切換視窗（同時也會跳 tmux pane）
- `<C-S-h>` / `<C-S-j>` / `<C-S-k>` / `<C-S-l>`: 移動視窗位置
- `<C-Left>` / `<C-Right>` / `<C-Up>` / `<C-Down>`: 調整視窗大小

## Terminal

- `<leader>tf`: 浮動 terminal
- `<leader>th`: 水平 terminal
- `<leader>tv`: 垂直 terminal
- `<leader>tg`: lazygit
- `<leader>tG`: tig，目前 cwd
- `<leader>tn`: node terminal
- `<leader>tp`: python terminal
- `<C-\>`: 開關 toggleterm
- terminal 裡按 `<Esc>` 或 `jk`: 回到 normal mode

## AI

- `<leader>aa`: 問 AI
- `<leader>ac`: 開聊天
- `<leader>ae`: 讓 AI 編輯
- `<leader>af`: 聚焦 AI 側邊欄
- `<leader>ah`: 聊天歷史
- `<leader>am`: 切換模型
- `<leader>an`: 新聊天
- `<leader>ap`: 切換 provider
- `<leader>ar`: 重新整理 AI
- `<leader>as`: 停止目前請求
- `<leader>at`: 顯示 / 隱藏 AI
- `<leader>ap` 可在 `codex` 和 `claude` 之間切換 provider
- Claude 需要先設定 `AVANTE_ANTHROPIC_API_KEY`

## LSP

- `<leader>cl`: LSP info
- `gd`: 跳到 definition
- `gr`: references
- `gI`: implementation
- `gy`: type definition
- `gD`: declaration
- `K`: hover
- `<leader>ca`: code action
- `<leader>cr`: rename symbol
- `<leader>co`: organize imports
- `[d` / `]d`: 上一個 / 下一個 diagnostic
- `<leader>cd`: 顯示當前行 diagnostic

## DAP

- `<leader>db`: toggle breakpoint
- `<leader>dB`: conditional breakpoint
- `<leader>dc`: run / continue
- `<leader>da`: run with args
- `<leader>dC`: run to cursor
- `<leader>di`: step into
- `<leader>dO`: step over
- `<leader>do`: step out
- `<leader>dr`: toggle REPL
- `<leader>du`: toggle DAP UI
- `<leader>dt`: terminate
- `<leader>dPt`: debug Python method
- `<leader>dPc`: debug Python class

## Trouble

- `<leader>xo`: 開啟 workspace diagnostics 視窗
- `<leader>xc`: 關閉 diagnostics 視窗
- `<leader>xO`: 開啟目前 buffer diagnostics 視窗
- `<leader>xx`: workspace diagnostics
- `<leader>xX`: buffer diagnostics
- `<leader>cs`: symbols
- `<leader>cS`: LSP references / definitions / implementations
- `<leader>xL`: location list
- `<leader>xQ`: quickfix list

## Editing

- `jj`: 離開 insert mode (custom，注意 toggleterm 裡是 `jk` 才回 normal)
- `<C-s>`: 存檔
- `<leader>n+`: 數字加一
- `<leader>n-`: 數字減一
- `s`: `flash` 跳到畫面上的位置
- `S`: `flash` 用 Treesitter 跳語法節點
- `gsa`: 加上包圍字元
- `gsd`: 刪掉包圍字元
- `gsr`: 替換包圍字元
- `gsh`: 高亮目前包圍
- `gsf` / `gsF`: 找右邊 / 左邊包圍

## Sessions / Quit

- dashboard `s`: 還原目前 cwd session
- dashboard `S`: 選擇 session
- `<leader>qs`: 還原 session
- `<leader>qS`: 選擇 session
- `<leader>ql`: 還原上次 session
- `<leader>qd`: 不儲存目前 session
- `<leader>qq`: 全部離開

## Git

- `<leader>gg`: lazygit，使用 git root
- `<leader>gG`: lazygit，使用目前 cwd
- `<leader>gt`: tig，目前 branch，使用 git root
- `<leader>gta`: tig --all，所有 branches，使用 git root
- `<leader>gT`: tig，使用目前 cwd
- `<leader>gs`: git status
- `<leader>gc`: git commits
- `<leader>gS`: git stash
- `<leader>gb`: blame line

## Toggles

- `<leader>uf`: toggle auto format
- `<leader>uF`: toggle auto format for current buffer
- `<leader>uw`: toggle wrap
- `<leader>uL`: toggle relative number
- `<leader>ud`: toggle diagnostics
- `<leader>ul`: toggle line numbers
- `<leader>ub`: toggle dark background
- `<leader>ua`: toggle animations
