" Features
"
" These options and commands enable some very useful features in Vim, that
" no user should have to live without.

" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Set number of colors for terminal
set t_Co=256

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting
syntax on

" Colorscheme
colorscheme holokai

" Paste toggle
set pastetoggle=<F2>

" Start spell checking
set spell spelllang=bg,en_us
set complete+=kspell


"------------------------------------------------------------
" Must have options {{{1
"
" These are highly recommended options.

" Vim with default settings does not allow easy switching between multiple files
" in the same editor window. Users can use multiple split windows or multiple
" tab pages to edit multiple files, but it is still best to enable an option to
" allow easier switching between files.
"
" One such option is the 'hidden' option, which allows you to re-use the same
" window and switch from an unsaved buffer without saving it first. Also allows
" you to keep an undo history for multiple files when re-using the same window
" in this way. Note that using persistent undo also lets you undo in multiple
" files even in the same window, but is less efficient and is actually designed
" for keeping undo history after closing Vim entirely. Vim will complain if you
" try to quit without saving, and swap files will keep you safe if your computer
" crashes.
set hidden

" Better command-line completion
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight current line
set cursorline
hi CursorLine   cterm=bold ctermbg=black ctermfg=NONE

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch

"------------------------------------------------------------
" Usability options {{{1
"
" These are options that users frequently set in their .vimrc. Some of them
" change Vim's behaviour in ways which deviate from the true Vi way, but
" which are considered to add usability. Which, if any, of these options to
" use is very much a personal preference, but they are harmless.

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Search as the search expression is being typed
set incsearch

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
" set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
" set t_vb=

" Enable use of the mouse for all modes
" set mouse=a

" Set the command window height to 2 lines, to avoid many cases of having to
set cmdheight=1

" More cmdline history
set history=2000

" Redraw only when we need to
set lazyredraw

" Display line numbers on the left
set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Enable folding
set foldenable

"------------------------------------------------------------
" Indentation options
"
" Indentation settings according to personal preference.

" Indentation settings for using 4 spaces instead of tabs.
" Do not change 'tabstop' from its default value of 8 with this setup.

set shiftwidth=4
set softtabstop=4
"set tabstop=4
set expandtab

autocmd FileType html setlocal ts=2 sts=2 sw=2
autocmd FileType ruby setlocal ts=2 sts=2 sw=2
autocmd FileType javascript setlocal ts=2 sts=2 sw=2
autocmd FileType python setlocal ts=4 sts=4 sw=4

"------------------------------------------------------------
" Mappings
"

" Mapping leader to 'space'
let mapleader = "\<Space>"

" Windows orientation
map <C-right> <C-w>l
map <C-left> <C-w>h
map <C-up> <C-w>k
map <C-down> <C-w>j
map <leader><tab> <C-w><C-w><CR>

" Buffers orientation
map <leader>l :bnext<CR>
map <leader>h :bprevious<CR>
map <leader>k :b#<CR>
map <leader>j :ls<CR>:b
map <leader>d :bdelete<CR>
map <leader>b :b

" Spell
nn <F7> :setlocal spell! spell?<CR>

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default

map Y y$
map <leader>w :w<CR>
map <leader>q :q<CR>

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

" Map toggle show line number
nnoremap <C-B> :set nonumber<CR>
nnoremap <S-B> :set number<CR>

"------------------------------------------------------------
" Airline status bar

" let g:airline_theme=''
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

"------------------------------------------------------------
" Tagbar Settings
nmap <F8> :TagbarToggle<CR>

"------------------------------------------------------------
" NerdTree settings
nmap <F9> :NERDTreeToggle<CR>

"------------------------------------------------------------
" Map grep

noremap <C-g> :Grep  *<left><left>

"------------------------------------------------------------
" Syntastic"
"let g:syntastic_mode_map = { 'passive_filetypes': ['python'] }

"------------------------------------------------------------
" Tex
let g:tex_flavor = 'latex'

" ALE
"------------------------------------------------------------
let b:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['black', 'isort'],
\   'javascript': ['prettier', 'eslint']
\}
let b:ale_linters = {
\   'python': ['pylint', 'mypy'],
\   'javascript': ['eslint']
\}
let g:ale_javascript_xo_options = "--plug=react --prettier"
let g:ale_sign_error = '❌'
let g:ale_sign_warning = '⚠️'
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_fix_on_save = 1
let g:ale_lint_on_save = 1

noremap <F6> :ALEFix<CR>
noremap <F5> :ALELint<CR>
noremap <F5> :ALEGoToDefinition<CR>
noremap <F4> :ALEFindReferences<CR>

"-----------------------------------------------------------
" C++
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_template_highlight = 1
let g:cpp_concepts_highlight = 1

"-----------------------------------------------------------
" DVC
autocmd! BufNewFile,BufRead Dvcfile,*.dvc setfiletype yaml

"-----------------------------------------------------------
" Vim translate

"g:goog_user_conf = {
"  'langpair': 'en|bg', " language code iso 639-1
"  'v_key': 'R' " ? define key in visual-mode (optional)
"}
"
"g:goog_user_conf = {
"  'langpair': 'bg|en', " language code iso 639-1
"  'v_key': 'T' " ? define key in visual-mode (optional)
"}
"

"-----------------------------------------------------------
" Highlight trailing whitespaces
"
highlight RedundantWhitespace ctermbg=red guibg=red
match RedundantWhitespace /\s\+$\| \+\ze\t\|\t\+\ze /

"-----------------------------------------------------------

" gotags for Tagbar
"
let g:tagbar_type_go = {
	\ 'ctagstype' : 'go',
	\ 'kinds'     : [
		\ 'p:package',
		\ 'i:imports:1',
		\ 'c:constants',
		\ 'v:variables',
		\ 't:types',
		\ 'n:interfaces',
		\ 'w:fields',
		\ 'e:embedded',
		\ 'm:methods',
		\ 'r:constructor',
		\ 'f:functions'
	\ ],
	\ 'sro' : '.',
	\ 'kind2scope' : {
		\ 't' : 'ctype',
		\ 'n' : 'ntype'
	\ },
	\ 'scope2kind' : {
		\ 'ctype' : 't',
		\ 'ntype' : 'n'
	\ },
	\ 'ctagsbin'  : 'gotags',
	\ 'ctagsargs' : '-sort -silent'
	\ }

"-----------------------------------------------------------
" Alias function
fun! SetupCommandAlias(from, to)
	exec 'cnoreabbrev <expr> '.a:from
		\ .' ((getcmdtype() is# ":" && getcmdline() is# "'.a:from.'")'
		\ .'? ("'.a:to.'") : ("'.a:from.'"))'
endfun

"-----------------------------------------------------------
" Aliases
call SetupCommandAlias("W", "w")

"-----------------------------------------------------------
" Plugin manager (vim-plug)

call plug#begin('~/.vim/plugged')

"Plug 'jceb/vim-orgmode'
Plug 'dense-analysis/ale'
" Plug 'vim-syntastic/syntastic'
Plug 'tpope/vim-surround'
" Plug 'vim-perl/vim-perl'
Plug 'scrooloose/nerdtree'
Plug 'honza/vim-snippets'
Plug 'majutsushi/tagbar'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Plug 'klen/python-mode'
" Plug 'vim-scripts/Conque-Shell'
" Plug 'fatih/vim-go'
" Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'flazz/vim-colorschemes'
Plug 'vim-scripts/grep.vim'
Plug 'jremmen/vim-ripgrep'
" Plug 'aquach/vim-http-client'
Plug 'fidian/hexmode'
" Plug 'fholgado/minibufexpl.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug '~/Code/cloned-projects/fzf'
"Plug 'bundle/vim-translator'
Plug 'tmux-plugins/vim-tmux'
Plug 'lervag/vimtex'
"Plug 'vim-latex/vim-latex'
Plug 'szymonmaszke/vimpyter'

call plug#end()
