
" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2008 Dec 17
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

"dein Scripts-----------------------------
" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=/Users/pampers/.vim/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('/Users/pampers/.vim/dein')
  call dein#begin('/Users/pampers/.vim/dein')

  " Let dein manage dein
  " Required:
  call dein#add('/Users/pampers/.vim/dein/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here:
  call dein#add('Shougo/neosnippet.vim')
  call dein#add('Shougo/neosnippet-snippets')

  "================= plug in =================
  call dein#add('tpope/vim-commentary')
  call dein#add('tpope/vim-surround')
  call dein#add('kana/vim-textobj-user')
  call dein#add('kana/vim-textobj-entire')
  call dein#add('davidhalter/jedi-vim')
  call dein#add('Flake8-vim')
  call dein#add('hynek/vim-python-pep8-indent')
  call dein#add('scrooloose/syntastic')
  call dein#add('tpope/vim-abolish')
  call dein#add('nathanaelkane/vim-indent-guides')
  " For ES6
  call dein#add('othree/yajs.vim')

  "================= plug in =================


  " You can specify revision/branch/tag.
  call dein#add('Shougo/vimshell', { 'rev': '3787e5' })

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts-------------------------



" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set directory=/tmp
set backupdir=/tmp
set undodir=/tmp
" set nobackup		" do not keep a backup file, use versions instead
set title
set autoread
set viminfo='100,/50,%,<1000,f50,s100,:100,c,h,!
set history=500		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set number
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set showmatch
set nostartofline

" One of the most important options to activate. Allows you to switch from an
" unsaved buffer without saving it first. Also allows you to keep an undo
" history for multiple files. Vim will complain if you try to quit without
" saving, and swap files will keep you safe if your computer crashes.
" バッファを保存しなくても他のバッファを表示できるようにする
set hidden

" Better command-line completion
" コマンドライン補完を便利に
set wildmenu
set wildmode=list:longest

" Modelines have historically been a source of security
" vulnerabilities.  As
" such, it may be a good idea to disable them and use the
" securemodelines
" script,
" <http://www.vim.org/scripts/script.php?script_id=1876>.
" 歴史的にモードラインはセキュリティ上の脆弱性になっていたので、
" オフにして代わりに上記のsecuremodelinesスクリプトを使うとよい。
set nomodeline

 " Use case insensitive search, except when using capital letters
 " 検索時に大文字・小文字を区別しない。ただし、検索後に大文字小文字が
 " 混在しているときは区別する
 set ignorecase
 set smartcase
 set wrapscan

" Always display the status line, even if only one window is displayed
" ステータスラインを常に表示する
set laststatus=2

" Use visual bell instead of beeping when doing something wrong
" ビープの代わりにビジュアルベル（画面フラッシュ）を使う
set visualbell
set t_vb=

" Display line numbers on the left
set number

" two characters wide.
set shiftwidth=2
set tabstop=2
set softtabstop=2
set expandtab

" Look & Feel
set list
set listchars=tab:>-


augroup vimrc
    autocmd! FileType py   setlocal shiftwidth=4 tabstop=4 softtabstop=4
augroup END

set nrformats=

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72, " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on
  set smartindent
  set smarttab

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" Clipboard
set clipboard+=unnamed

"------------------------------------
" KeyRemap
"------------------------------------
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfirst<CR>
nnoremap <silent> ]B :blast<CR>
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
nnoremap <ESC><ESC> :<C-u>nohlsearch<CR><Esc>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
nnoremap Q <Nop>
noremap <Space>h ^
noremap <Space>l $
noremap <Space>a *
" set cursorline
nnoremap <C-l><C-l> :<C-u>setlocal cursorcolumn! cursorcolumn! cursorline!<CR>

" Open a directory path of current open buffer
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

imap <F11> <nop>
set pastetoggle=<F11>

" Encoding
set encoding=utf-8
set fileencodings=iso-2022-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932,utf-8

"------------------------------------
" Plugin
"------------------------------------
runtime macros/matchit.vim

" https://github.com/nelstrom/vim-qargs
command! -nargs=0 -bar Qargs execute 'args' QuickfixFilenames()
function! QuickfixFilenames()
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
endfunction

" PyFlake
let g:PyFlakeOnWrite = 1
let g:PyFlakeCheckers = 'pep8,mccabe,pyflakes'
let g:PyFlakeDefaultComplexity = 10

" syntastic
let g:syntastic_python_checkers = ['pyflakes', 'pep8']

" Remove space at the end of line
autocmd BufWritePre * :%s/\s\+$//ge


" vim-inent-guides
colorscheme default
" let s:hooks = neobundle#get_hooks("vim-indent-guides")
" function! s:hooks.on_source(bundle)
  " let g:indent_guides_auto_colors = 0
  let g:indent_guides_guide_size = 1
  let g:indent_guides_start_level = 2
  let g:indent_guides_enable_on_vim_startup = 1
"  hi IndentGuidesOdd  guibg=red   ctermbg=236
"  hi IndentGuidesEven guibg=green ctermbg=236
"  IndentGuidesEnable
" endfunction
