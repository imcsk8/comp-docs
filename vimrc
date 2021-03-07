set smartindent
set autoindent
set paste
set encoding=utf-8
set cursorline
set number
set tabstop=4
set shiftwidth=4
set expandtab
retab
set showmatch
let python_highlight_all = 1

autocmd FileType tex,pl,c,py,pp,txt setlocal textwidth=80
autocmd FileType pp setlocal tabstop=2
autocmd FileType js setlocal tabstop=2
autocmd FileType java setlocal tabstop=4 noexpandtab
autocmd BufNewFile,BufRead Jenkinsfile set syntax=groovy
autocmd BufNewFile,BufRead Jenkinsfile-curriculum set syntax=groovy
let g:airline_powerline_fonts = 1
set t_Co=256



" vmap <Enter> <Plug>(EasyAlign)
call plug#begin('~/.vim/plugged')

Plug 'valloric/youcompleteme'
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline-themes'
Plug 'fatih/vim-go'
" Initialize plugin system
call plug#end()
