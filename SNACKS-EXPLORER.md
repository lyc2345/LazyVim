# Snacks Explorer

這份小抄整理 `Snacks Explorer` 最常用的操作。

## Open

- `:lua Snacks.explorer()`
- `:lua Snacks.explorer.reveal()`

## Navigation

- `j` / `k`: 上下移動
- `<CR>` / `l`: 開啟檔案或展開資料夾
- `<C-s>`: 水平 split 開啟檔案
- `<C-v>`: 垂直 split 開啟檔案
- `h`: 收起資料夾
- `<BS>`: 回到上一層
- `.`: 聚焦目前節點
- `Z`: 關閉所有已展開資料夾

## File Actions

- `a`: 新增檔案 / 資料夾
- `r`: 重新命名
- `d`: 刪除
- `c`: 複製
- `m`: 移動
- `o`: 用系統預設程式開啟

## Yank / Paste

- `y`: 複製選取項目
- `p`: 貼上
- `u`: 更新 / 重新整理

## Search / Tools

- `<C-f>`: 在當前項目資料夾內 grep
- `<C-t>`: 在當前項目資料夾開 terminal

## Git / Diagnostics

- `]g` / `[g`: 下一個 / 上一個 git 變更
- `]d` / `[d`: 下一個 / 上一個 diagnostic
- `]w` / `[w`: 下一個 / 上一個 warning
- `]e` / `[e`: 下一個 / 上一個 error

## Toggles

- `f`: toggle follow
- `h`: toggle hidden
- `i`: toggle ignored

## Notes

- `follow`: 自動跟隨目前檔案或游標上下文
- `hidden`: 顯示像 `.env` 這種隱藏檔
- `ignored`: 顯示原本被 ignore 的檔案

## Useful Lua

```lua
Snacks.explorer.open({ cwd = vim.fn.expand("%:p:h") })
```

用目前檔案所在資料夾作為 explorer 起點。

```lua
Snacks.explorer.reveal()
```

在 explorer 裡定位目前檔案。
