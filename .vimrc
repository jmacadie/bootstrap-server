set number

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

" Folding
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=1

" Git commits
" ~~~~~~~~~~~~~~~~
autocmd FileType gitcommit setlocal spell
