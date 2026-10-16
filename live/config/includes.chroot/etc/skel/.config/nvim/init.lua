-- 최소 neovim 설정 (플러그인 없음)
local o = vim.opt
o.number = true
o.mouse = "a"
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.termguicolors = true
o.clipboard = "unnamedplus"

-- 빌드 / 실행 단축키
vim.keymap.set("n", "<F5>", function()
  local ft = vim.bo.filetype
  vim.cmd("write")
  if ft == "python" then
    vim.cmd("!python3 %")
  elseif ft == "cpp" then
    vim.cmd("!g++ -std=c++20 -O2 -Wall -Wextra % -o /tmp/a.out && /tmp/a.out")
  end
end, { desc = "저장 후 실행" })

-- clangd / pylsp 가 설치되어 있으면 내장 LSP 사용 (neovim 0.8+)
local ok = pcall(function()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function() vim.lsp.start({ name = "clangd", cmd = { "clangd" }, root_dir = vim.fn.getcwd() }) end,
  })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python" },
    callback = function() vim.lsp.start({ name = "pylsp", cmd = { "pylsp" }, root_dir = vim.fn.getcwd() }) end,
  })
end)
