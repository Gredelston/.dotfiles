syntax on
filetype indent plugin on
set encoding=UTF-8

" Remaps!
inoremap jk <ESC>
nnoremap ; :
nnoremap : ;

set number

" Syntax highlighting for weird extensions
autocmd BufNewFile,BufRead *.star set ft=starlark syntax=python shiftwidth=2 tabstop=2 softtabstop=2

""" Begin Vim-Plug section

" Install vimplug if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a ddirectory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'tpope/vim-fugitive'
Plug 'jiangmiao/auto-pairs'
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'ryanoasis/vim-devicons'

" orgmode and its dependencies
Plug 'jceb/vim-orgmode'
Plug 'tpope/vim-speeddating'
Plug 'vim-scripts/utl.vim'

" Initialize plugin system
call plug#end()

""" End Vim-Plug section

" Allow saving of files as sudo when I forget to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" NERDTree customizations from the NERDTree FAQ
nnoremap <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
  exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
  exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction
call NERDTreeHighlightFile('go', 'blue', 'none', 'blue', '#151515')
call NERDTreeHighlightFile('py', 'blue', 'none', 'blue', '#151515')
call NERDTreeHighlightFile('cfg', 'grey', 'none', 'grey', '#151515')
call NERDTreeHighlightFile('ini', 'grey', 'none', 'grey', '#151515')
call NERDTreeHighlightFile('md', 'grey', 'none', 'grey', '#151515')

" Ctrl+F to open FZF
nnoremap <C-f> :FZF<CR>

" wincmd shortcuts, for when I'm in SSH
nnoremap <C-h> :wincmd h<CR>
nnoremap <C-j> :wincmd j<CR>
nnoremap <C-k> :wincmd k<CR>
nnoremap <C-l> :wincmd l<CR>

" Git blame
nnoremap <C-b> :Git blame<CR>

" Macro tricks, from https://hillelwayne.com/vim-macro-trickz/
nnoremap Q @@
set lazyredraw
nnoremap Y y$

" Fix indents when pasting, from https://stackoverflow.com/q/2514445#38258720
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()
function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction

" Syntax highlighting for strange extensions
autocmd BufNewFile,BufRead *.star set syntax=python

" Allow local .vimrc files
set exrc
set secure

" Set custom shiftwidths in certain directories.
autocmd BufRead,BufNewFile */chromite/*.py,*/infra/recipes/*.py,*/infra/config/*.py set shiftwidth=2 tabstop=2 softtabstop=2
