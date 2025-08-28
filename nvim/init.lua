vim.opt.number = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autochdir = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.updatetime = 300

vim.cmd.highlight({'ExtraWhitespace', 'ctermbg=red', 'guibg=#ea6962'})
local whitespace_group = vim.api.nvim_create_augroup('HighlightTrailingWhitespace', { clear = true })
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'InsertLeave' }, {
  group = whitespace_group,
  pattern = '*',
  callback = function()
    vim.fn.matchadd('ExtraWhitespace', '\\s\\+$')
  end,
})
vim.api.nvim_create_autocmd('InsertEnter', {
  group = whitespace_group,
  pattern = '*',
  callback = function()
    vim.fn.matchadd('ExtraWhitespace', '\\s\\+\\%#\\@<!$')
  end,
})
vim.api.nvim_create_autocmd('BufWinLeave', {
  group = whitespace_group,
  pattern = '*',
  callback = function()
    vim.fn.clearmatches()
  end,
})

vim.api.nvim_create_autocmd({'BufWinEnter'}, {
  desc = 'return cursor to where it was last time closing the file',
  pattern = '*',
  command = 'silent! normal! g`"zv',
})

if not vim.g.vscode then
  vim.g.ale_completion_enabled = true

  local Plug = vim.fn['plug#']
  vim.call('plug#begin')

  Plug('catppuccin/nvim', { ['as'] = 'catppuccin' })
  Plug('preservim/nerdtree')
  Plug('dense-analysis/ale')

  vim.call('plug#end')

  require("catppuccin").setup({
      transparent_background = true,
  })

  vim.cmd.colorscheme('catppuccin-mocha')

  vim.keymap.set('n', '<C-n>', ':NERDTreeToggle<CR>')
  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    callback = function()
      if vim.fn.winnr('$') == 1 and vim.b.NERDTree and vim.fn.eval('b:NERDTree.isTabTree()') == 1 then
        vim.cmd('quit')
      end
    end,
  })

  vim.g.ale_fixers = {
    ['*'] = {'remove_trailing_lines', 'trim_whitespace'},
    javascript = {'prettier', 'eslint'},
    typescript = {'prettier', 'eslint'},
  }
  vim.keymap.set('n', '<C-S-i>', ':ALEFix<CR>')
  vim.keymap.set('n', '<C-/>', ':ALEGoToDefinition<CR>')
  vim.opt.omnifunc = 'ale#completion#OmniFunc'
  vim.g.ale_hover_to_floating_preview = true
  vim.api.nvim_create_autocmd('CursorHold', {
    pattern = '*',
    callback = function()
      vim.cmd(':ALEHover')
    end,
  })
end
