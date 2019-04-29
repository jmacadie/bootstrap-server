set number        " show line numbers
syntax on		  " syntax highlighting for code please

" Refs
" http://oli.me.uk/2015/06/17/wrangling-javascript-with-vim/
" https://github.com/VundleVim/Vundle.vim

" Vundle options
" ~~~~~~~~~~~~~~~~
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
" set rtp+=~/.vim/bundle/Vundle.vim
" call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
" Plugin 'VundleVim/Vundle.vim'

" Plugin 'pangloss/vim-javascript'
" Plugin 'townk/vim-autoclose'
" Plugin 'airblade/vim-gitgutter'
" Plugin 'scrooloose/syntastic'

" All of your Plugins must be added before the following line
" call vundle#end()            " required
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

" vim-gitgutter options
" ~~~~~~~~~~~~~~~~

let g:gitgutter_realtime = 1
set updatetime=750

" Syntastic Options
" ~~~~~~~~~~~~~~~~

" set statusline+=%#warnings#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1

let g:syntastic_js_checkers = ['jshint', 'jscs']
let g:syntastic_javascript_checkers = ['jshint', 'jscs']

" Indenting Options
" ~~~~~~~~~~~~~~~~

set autoindent
set smartindent

" Tabs options
" ~~~~~~~~~~~~~~~~
set tabstop=2       " How to display tabs
set softtabstop=2   " How many columns inserted when hit tab in INSERT mode
set shiftwidth=2    " How many columns moved when indent or un-indent
set expandtab       " Always insert spaces not tabs

" Show tabs and trailing whitespace
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

" Toggle spelling on & off
" ~~~~~~~~~~~~~~~~
function! ToggleSpelling()
  if &spell
    set nospell
  else
    setlocal spell spelllang=en_gb
  endif
endfunction

nmap <silent> gs :call ToggleSpelling()<CR>

" Toggle paste mode on & off
" ~~~~~~~~~~~~~~~~
function! TogglePaste()
  if &paste
    set nopaste
  else
    set paste
    startinsert
  endif
endfunction

nmap <silent> gp :call TogglePaste()<CR>

" Highlighting
" ~~~~~~~~~~~~~~~~
" Set visual clue to end of recommended range
execute "set colorcolumn=80," . join(range(120,355), ',')
highlight ColorColumn ctermbg=4

highlight Comment ctermfg=2
autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\'))

" HTML
" ~~~~~~~~~~~~~~~~
"au BufNewFile,BufRead *.handlebars set filetype=html
"autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
"inoremap <F8> </<C-X><C-O>
"autocmd FileType html,xml source ~/.vim/scripts/closetag.vim

" Folding
" ~~~~~~~~~~~~~~~~
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=1

" Git commits
" ~~~~~~~~~~~~~~~~
autocmd FileType gitcommit setlocal spell

" Status Line
" ~~~~~~~~~~~~~~~~
set laststatus=2		" always show a status line

function! GitBranch()
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

set statusline=
set statusline+=%#PmenuSel#
"set statusline+=%{StatuslineGit()}
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m\
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\ 
