set number
set tabstop=2
set shiftwidth=2
set expandtab
set autochdir
set clipboard=unnamedplus

highlight ExtraWhitespace ctermbg=red guibg=#ea6962
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()
