":""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
" Sets how many lines of history VIM has to remember
set history=700

" Enable filetype plugin
filetype on
filetype plugin on
filetype indent on
au BufNewFile,BufRead *.dml set filetype=dml
au BufNewFile,BufRead *.go set filetype=go
au BufNewFile,BufRead *.sls set filetype=sls
au BufNewFile,BufRead *.isa set filetype=cpp

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vundle management
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Bundle management
" Install :
"   open vim and :BundleInstall
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

"""""""""""""""""""""""""""""
" Plugin list
" Let Vundle manage itself
Plugin 'gmarik/vundle'

" Plugins
Plugin 'tpope/vim-surround'
"   general lint
Plugin 'scrooloose/syntastic'
"   folder based syntax rule
Plugin 'thinca/vim-localrc'
"   turn on ascii color
Plugin 'jbnicolai/vim-AnsiEsc'
" search and display information from arbitrary sources
" like files, buffers, recently used files
Plugin 'Shougo/unite.vim'
" Required by unite.vim
Plugin 'Shougo/vimproc.vim'
" salt syntax
Plugin 'saltstack/salt-vim'
" a tool to bind different formatter
Plugin 'Chiel92/vim-autoformat'

"""""""""""""""""""""""""""""
" Plugin Setting
" scrooloose/syntastic checker "
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 1
let g:syntastic_enable_perl_checker = 1
let g:syntastic_loc_list_height = 3

let g:syntastic_cpp_compiler_options = '-std=c++11'
let g:syntastic_asm_checkers = ["aarch64-gcc"]
let g:syntastic_perl_checkers = ["perlcritic"]
let g:syntastic_python_checkers = ["pyflakes", "pylint"]
let g:ycm_confirm_extra_conf = 0

if filereadable(".pylintrc")
    let g:syntastic_python_pylint_post_args = '--rcfile=".pylintrc"'
elseif filereadable("../.pylintrc")
    let g:syntastic_python_pylint_post_args = '--rcfile="../.pylintrc"'
elseif filereadable("../../.pylintrc")
    let g:syntastic_python_pylint_post_args = '--rcfile="../../.pylintrc"'
endif

call unite#filters#matcher_default#use(['matcher_fuzzy'])

" local rc
call localrc#load('.local.vimrc', getcwd())


" Set to auto read when a file is changed from the outside
set autoread

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

" Fast saving and quiting
nmap <leader>w :w!<cr>
nmap <leader>qa :qa!<cr>

" small trick
nmap <leader>s  :%s/\s\+$//<cr>
nmap <leader>m  :%s///<cr>
nmap <leader>d  :diffu<cr>

" unite
nmap <leader>f :Unite -no-split -buffer-name=files   -start-insert file_rec/async:!<cr>
nmap <leader>b :Unite -no-split -buffer-name=buffer  buffer<cr>

" write file as root
command W :execute ':silent w !sudo tee % > /dev/null' | :edit!

" When vimrc is edited, reload it
autocmd! bufwritepost vimrc source ~/.vimrc

" Use default template for program language "
autocmd bufnewfile *.c  0r ~/.vim/skel/c_template.c
autocmd bufnewfile CMakeLists.txt  0r ~/.vim/skel/cmake_template.txt
autocmd bufnewfile *.cpp  0r ~/.vim/skel/cpp_template.cpp
autocmd bufnewfile *.go  0r ~/.vim/skel/go_template.go
autocmd bufnewfile *.pl  0r ~/.vim/skel/perl_template.pl
autocmd bufnewfile *.py 0r ~/.vim/skel/python_template.py
autocmd bufnewfile *.sh 0r ~/.vim/skel/bash_template.sh

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the curors - when moving vertical..
"set so=7

set wildmenu "Turn on WiLd menu

set ruler "Always show current position

set cmdheight=2 "The commandbar height

set hid "Change buffer - without saving

" Set backspace config
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

set ignorecase "Ignore case when searching
set smartcase

set hlsearch "Highlight search things

set incsearch "Make search act like search in modern browsers
set nolazyredraw "Don't redraw while executing macros

set magic "Set magic on, for regular expressions

set showmatch "Show matching bracets when text indicator is over them
set mat=2 "How many tenths of a second to blink

set foldmethod=syntax  "alternative : marker/indent
set foldlevel=0        "default is off
set foldnestmax=3
" No sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500
set colorcolumn=80

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax enable "Enable syntax hl

set encoding=utf8
try
    lang en_US
catch
endtry

set ffs=unix,dos,mac "Default file types


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git anyway...
set nobackup
set nowb
set noswapfile


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set lbr    "linebreak
set tw=500 "textwidth
set wrap "Wrap lines

" ref : https://stackoverflow.com/questions/30408178/indenting-after-newline-following-new-indent-level-vim
set expandtab       "Use softtabstop spaces instead of tab characters for indentation
set shiftwidth=4    "Indent by 4 spaces when using >>, <<, == etc.
set softtabstop=4   "Indent by 4 spaces when pressing <TAB>

set autoindent      "Keep indentation from previous line
set smartindent     "Automatically inserts indentation in some cases
set cindent         "Like smartindent, but stricter and more customisable

set tags=./tags,../tags,../../tags,../../../tags

let g:clang_use_library = 1
let g:clang_library_path = '/usr/lib'




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => formatter
" """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" auto-fomrmat : ptyhon
" copy from default.vim in auto-format repo since I don't want to export
" PYTHONLIB path
let g:formatters_python = ['yapf']  "siable autopep8
let s:configfile_def   = "'python /usr/local/lib/python2.7/dist-packages/yapf -l '.a:firstline.'-'.a:lastline"
let s:noconfigfile_def = "'python /usr/local/lib/python2.7/dist-packages/yapf --style=\"{based_on_style:'.g:formatter_yapf_style.',indent_width:'.&shiftwidth.(&textwidth ? ',column_limit:'.&textwidth : '').'}\" -l '.a:firstline.'-'.a:lastline"
let g:formatdef_yapf   = "g:YAPFFormatConfigFileExists() ? (" . s:configfile_def . ") : (" . s:noconfigfile_def . ")"

" auto-fomrmat : ptyhon
let g:formatters_cpp = ['clangformat'] "disable astyle

" auto-fomrmat : enabling key mapping
map <C-k> :Autoformat<CR>
imap <C-k> <ESC>:Autoformat<CR>

" debug
" let g:autoformat_verbosemode=1




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => MISC
" """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" " Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm
nmap M :%s///g

let hexmode = 0
map <leader>x  :%!xxd <cr>
map <leader>nx :%!xxd -r<cr>
map <leader>p  :call TooglePaste()<cr>

"syntastic oo/off
nnoremap <leader>v :SyntasticCheck<cr>
nnoremap <leader>nv :SyntasticReset<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs and buffers
" """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" " Map space to / (search) and c-space to ? (backgwards search)
"map <space> /
"map <c-space> ?
"map <silent> <leader><cr> :noh<cr>

map <right> :bn<cr>
map <left> :bp<cr>
nmap <leader>c :b#<bar>bd#<cr>

" Tab configuration
map <leader>tn :tabnew<cr>
map <leader>te :tabedit
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove

""""""""""""""""""""""""""""""
" => Statusline
""""""""""""""""""""""""""""""
" Always hide the statusline
set laststatus=2

" Format the statusline
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{CurDir()}%h\ \ \ Line:\ %l/%L:%c


function! CurDir()
    let curdir = substitute(getcwd(), '/Users/amir/', "~/", "g")
    return curdir
endfunction

function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    else
        return ''
    endif
endfunction

function! TooglePaste()
    if &paste
        let &paste = 0
    else
        let &paste = 1
    endif
endfunction

if $DISPLAY =~ '\(\(cos\|scs\)\d\+nai\d\+\)\|\(spkpc\d\+\)\|\(tc-garyjohn\)' 
    set clipboard=autoselect,exclude:.* 
endif 

set guioptions-=e

if exists("+showtabline")
     function! MyTabLine()
         let s = ''
         let t = tabpagenr()
         let i = 1
         while i <= tabpagenr('$')
             let buflist = tabpagebuflist(i)
             let winnr = tabpagewinnr(i)
             let s .= (i != 1 ? ' |%#TabLine#' : '')
             let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
             let s .= i
             let s .= ' '
             let file = substitute(simplify(bufname(buflist[winnr - 1])), $HOME, '~', '')
             if file == ''
                 let file = '[No Name]'
             endif
             let s .= (getbufvar(buflist[winnr - 1], "&mod") ? '*' : '')
             let s .= file
             let s .= ' '
             let i = i + 1
         endwhile
         let s .= '%T%#TabLineFill#%='
         return s
     endfunction

     set stal=2
     set tabline=%!MyTabLine()
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""
"        session
"""""""""""""""""""""""""""""""""""""""""""""""""""
"fu! SaveSess()
"  execute 'mksession! ' . getcwd() . '/.session.vim'
"endfunction
"
"fu! RestoreSess()
"  if filereadable(getcwd() . '/.session.vim')
"    execute 'so ' . getcwd() . '/.session.vim'
"    if bufexists(1)
"      for l in range(1, bufnr('$'))
"        if bufwinnr(l) == -1
"          exec 'sbuffer ' . l
"        endif
"      endfor
"    endif
"  endif
"endfunction
"
"autocmd VimLeave * call SaveSess()
"autocmd VimEnter * nested call RestoreSess()
"
"set sessionoptions-=options  " Don't save options

"""""""""""""""""""""""""""""""""""""""""""""""""""
"        color block
"""""""""""""""""""""""""""""""""""""""""""""""""""
hi clear
set background=dark
if exists("syntax_on")
	  syntax reset
  endif
  let g:colors_name = "murphy"

  "hi Normal      ctermbg=Black  ctermfg=lightgreen guibg=Black guifg=lightgreen
  hi Comment      term=bold      ctermfg=LightRed   guifg=Orange
  hi Constant     term=underline ctermfg=LightGreen guifg=White   gui=NONE
  hi Identifier   term=underline ctermfg=LightCyan  guifg=#00ffff
  hi Ignore                      ctermfg=black      guifg=bg
  hi PreProc      term=underline ctermfg=LightBlue  guifg=Wheat
  hi Search       term=reverse                      guifg=white   guibg=Blue
  hi Special      term=bold      ctermfg=LightRed   guifg=magenta
  hi Statement    term=bold      ctermfg=Yellow     guifg=#ffff00 gui=NONE
  hi Type                        ctermfg=LightGreen guifg=grey    gui=none
  hi Error        term=reverse   ctermbg=Red    ctermfg=White guibg=Red guifg=White
  hi Todo         term=standout  ctermbg=Yellow ctermfg=Black guifg=Blue guibg=Yellow

  " From the source:
  hi Cursor                                         guifg=Orchid  guibg=fg
  hi Directory    term=bold      ctermfg=LightCyan  guifg=Cyan
  hi ErrorMsg     term=standout  ctermbg=DarkRed    ctermfg=White guibg=Red guifg=White
  hi IncSearch    term=reverse   cterm=reverse      gui=reverse
  hi LineNr       term=underline ctermfg=Yellow                   guifg=Yellow
  hi ModeMsg      term=bold      cterm=bold         gui=bold
  hi MoreMsg      term=bold      ctermfg=LightGreen gui=bold      guifg=SeaGreen
  hi NonText      term=bold      ctermfg=Blue       gui=bold      guifg=Blue
  hi Question     term=standout  ctermfg=LightGreen gui=bold      guifg=Cyan
  hi SpecialKey   term=bold      ctermfg=LightBlue  guifg=Cyan
  hi StatusLine   term=reverse,bold cterm=reverse   gui=NONE      guifg=White guibg=darkblue
  hi StatusLineNC term=reverse   cterm=reverse      gui=NONE      guifg=white guibg=#333333
  hi Title        term=bold      ctermfg=LightMagenta gui=bold    guifg=Pink
  hi WarningMsg   term=standout  ctermfg=LightRed   guifg=Red
  hi Visual       term=reverse   cterm=reverse      gui=NONE      guifg=white guibg=darkgreen

  " For tabline
  hi TabLine           cterm=underline ctermfg=15    ctermbg=242   gui=underline guibg=#6c6c6c guifg=White
  hi TabLineSel        cterm=bold      gui=NONE      guifg=White
  hi TabLineNr         cterm=underline ctermbg=238   guibg=#444444
  hi TabLineNrSel      cterm=bold      ctermfg=45    guifg=#00d7ff
  hi TabLineFill       cterm=reverse   gui=reverse
  hi TabLineMore       cterm=underline ctermfg=White ctermbg=236   gui=underline guifg=White   guibg=#303030
  hi TabLineSplitNr    cterm=underline ctermfg=148 ctermbg=240   gui=underline,italic guifg=#afd700   guibg=#6c6c6c
  hi TabLineSplitNrSel cterm=NONE      ctermfg=148 ctermbg=236   gui=NONE,italic      guifg=#afd700   guibg=#303030

