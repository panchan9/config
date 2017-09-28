set title
set autoread
set history=50
set viminfo='100,/50,%,<1000,f50,s100,:100,c,h,!

set showmatch
set nostartofline

set incsearch
set ignorecase
set smartcase
set wrapscan

"----Format----
set smartindent
set autoindent
set smarttab

set tabstop=4
set shiftwidth=4
set softtabstop=4

"----Look%Feel----
set list
set listchars=tab:>-

set hlsearch
nmap <ESC><ESC> :nohl<CR><ESC>

set ruler
set number

set cmdheight=1

"set cursorline
nnoremap <C-l><C-l> :<C-u>setlocal cursorcolumn! cursorline!<CR>

syntax on
filetype plugin on
filetype indent on



imap <F11> <nop>
set pastetoggle=<F11>

set encoding=utf-8
"set fileencodings=ucs-bom,iso-2022-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932,utf-8
set fileencodings=iso-2022-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932,utf-8

"memo
"reopen
":e ++enc=char-code
":e ++ff=line feed





" Anywhere SID.
function! s:SID_PREFIX()
	return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

" Set tabline.
function! s:my_tabline()	"{{{
	let s = ''
	for i in range(1, tabpagenr('$'))
		let bufnrs = tabpagebuflist(i)
		let bufnr = bufnrs[tabpagewinnr(i) - 1]		" first window, first appears
		let no = i		" display 0-origin tabpagenr.
		let mod = getbufvar(bufnr, '%modified') ? '!' : ' '
		let title = fnamemodify(bufname(bufnr), ':t')
		let title = '[' . title . ']'
		let s .= '%'.i.'T'
		let s .= '%#' . (i == tabpagenr() ? 'TabLineSel' : 'TabLine') . '#'
		let s .= no . ':' . title
		let s .= mod
		let s .= '%#TabLineFill# '
	endfor
	let s .= '%#TabLineFill#%T%=%#TabLine#'
	return s
endfunction		"}}}
let &tabline = '%!' . s:SID_PREFIX() . 'my_tabline()'
set showtabline=2		" always display tab line

" The prefix key.
nnoremap [Tag] <Nop>
nmap t [Tag]
" Tab jump
for n in range(1, 9)
	execute 'nnoremap <silent> [Tag]' .n ':<C-u>tabnext'.n.'<CR>'
endfor

map <silent> [Tag]c :tablast <bar> tabnew<CR>
map <silent> [Tag]x :tabclose<CR>
map <silent> [Tag]n :tabnext<CR>
map <silent> [Tag]p :tabprevious<CR>
