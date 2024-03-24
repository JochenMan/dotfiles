" remap jj to Esc in insert mode
inoremap jj <Esc>

" a colored line at column 80
set colorcolumn=80

" line numbers
set number
set relativenumber

" backspace settings
set backspace=indent,eol,start

" Don't create swapfiles
set noswapfile

" cool color
colo desert

" fix tabstops
set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab

" enter the current millenium
set nocompatible

" enable syntax and plugins (for netrw)
syntax enable
filetype plugin on

" FINDING FILES:

" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=**

" Display all matching files when we tab complete
set wildmenu

" NOW WE CAN:
" - Hit tab to :find by partial match
" - Use * to make it fuzzy

" THINGS TO CONSIDER:
" - :b lets you autocomplete any open buffer

" TAG JUMPING:

" Create the `tags` file (may need to install ctags first)
command! MakeTags !ctags -R .

" NOW WE CAN:
" - Use ^] to jump to tag under cursor
" - Use g^] for ambiguous tags
" - Use ^t to jump back up the tag stack

" THINGS TO CONSIDER:
" - This doesn't help if you want a visual list of tags

" AUTOCOMPLETE:

" The good stuff is documented in |ins-completion|

" HIGHLIGHTS:
" - ^x^n for JUST this file
" - ^x^f for filenames (works with our path trick!)
" - ^x^] for tags only
" - ^n for anything specified by the 'complete' option

" NOW WE CAN:
" - Use ^n and ^p to go back and forth in the suggestion list

" FILE BROWSING:

" Tweaks for browsing
let g:netrw_banner=0        " disable annoying banner
let g:netrw_browse_split=4  " open in prior window
let g:netrw_altv=1          " open splits to the right
let g:netrw_liststyle=3     " tree view

" NOW WE CAN:
" - :edit a folder to open a file browser
" - <CR>/v/t to open in an h-split/v-split/tab
" - check |netrw-browse-maps| for more mappings

" open results of last global command in a split window
let @g = ':redir @a:g//:redir END:vnew:put! a'

" macros for oe and ae and ue
let @a = ':s/oe/ö/e | :s/ae/ä/e | :s/ue/ü/e'

" macros and remappings for todos
let @u = ':g/- \[ \]/'
let @f = ':g/- \[x\]/'
let @d = ':%s/^\(.\{-}-\{1}\)/-\2'
let @n = ':norm I- [ ]'
nnoremap <silent> <F5> :s/^- \[ \]/- \[x\]/
nnoremap <silent> <F7> :g/- \[ \]/<CR>@g:%s/^\(.\{-}-\{1}\)/-\2
nnoremap <silent> <F8> :g/- \[x\]/<CR>@g:%s/^\(.\{-}-\{1}\)/-\2

function Meow()
  let checked='- [x]'
  let unchecked='- [ ]'
  let l=getline('.')
  let is_checked = stridx(l, checked)
  let is_unchecked = stridx(l, unchecked)
  if is_checked == 0
   let l=substitute(l, '- \[x\]', '- \[ \]', "1")
  endif
  if is_unchecked == 0
   let l=substitute(l, '- \[ \]', '- \[x\]', "1")
  endif
  call setline('.', l)
endfunction

function Newtd()
  let l=getline('.')
  let todo='- ['
  let is_todo = stridx(l, todo)
  if is_todo == 0
   echo 'toll'
   norm o
   norm o
   let l=''
  endif

  let date=system('date +%y%m%d')
  let l='- [ ]' . date . ' ' . l
  let l = substitute(l, '\n', '', 'g')
  call setline('.', l)

  norm $
  startinsert!
endfunction

nnoremap <silent> <F5> :call Newtd()<CR>
nnoremap <silent> <F6> :call Meow()<CR>
