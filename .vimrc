" Refs
" http://oli.me.uk/2015/06/17/wrangling-javascript-with-vim/
" https://github.com/VundleVim/Vundle.vim

" Vundle options
" ~~~~~~~~~~~~~~~~
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'pangloss/vim-javascript'
Plugin 'townk/vim-autoclose'
Plugin 'airblade/vim-gitgutter'
Plugin 'scrooloose/syntastic'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

set number

" vim-gitgutter options
" ~~~~~~~~~~~~~~~~

let g:gitgutter_realtime = 1
set updatetime=750

" syntastic option
" ~~~~~~~~~~~~~~~~

set statusline+=%#warnings#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1

let g:syntastic_js_checkers = ['jshint', 'jscs']
let g:syntastic_javascript_checkers = ['jshint', 'jscs']

" Tabs options
" ~~~~~~~~~~~~~~~~
set tabstop=2 " How to display tabs
set softtabstop=2 " How many columns inserted when hit tab in INSERT mode
set shiftwidth=2 " How many columns moved when indent or un-indent
set expandtab " Always insert spaces not tabs

" Show tabs
" ~~~~~~~~~~~~~~~~
set list
set listchars=tab:!_,precedes:<,extends:>,trail:-

" Strip trailing whitespace on save
" ~~~~~~~~~~~~~~~~
fun! <SID>StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  call cursor(l, c)
endfun

autocmd FileType c,cpp,java,php,ruby,pyhton,html
  \ autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

" Code stuff
" ~~~~~~~~~~~~~~~~

syntax on
set textwidth=80
set wrapmargin=2
set nowrap
execute "set colorcolumn=" . join(range(81,355), ',')
highlight colorcolumn ctermbg=6 guibg=#2c2d27
set autoindent
set smartindent
highlight Comment ctermfg=2
au BufNewFile,BufRead *.handlebars set filetype=html
autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\'))

" HTML
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
"inoremap <F8> </<C-X><C-O>
autocmd FileType html,xml source ~/.vim/scripts/closetag.vim

" Folding
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=1

" Git commits
" ~~~~~~~~~~~~~~~~
autocmd FileType gitcommit setlocal spell
