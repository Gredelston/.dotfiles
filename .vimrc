syntax on
filetype indent plugin on

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
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'tpope/vim-fugitive'

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
