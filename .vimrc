" Remaps!
inoremap jk <ESC>
nnoremap ; :
nnoremap : ;

""" Begin Vim-Plug section

" Specify a ddirectory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Initialize plugin system
call plug#end()

""" End Vim-Plug section
