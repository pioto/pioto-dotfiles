set ruler
set title
set background=dark

" Vundle config, see https://github.com/VundleVim/Vundle.vim#quick-start
if isdirectory(expand("~/.vim/bundle/Vundle.vim/")) && v:version > 700
    set nocompatible " be iMproved, required
    filetype off     " required

    " set the runtime path to include Vundle and initialize
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()

    " let Vundle manage Vundle, required
    Plugin 'VundleVim/Vundle.vim'

    " stuff from vim.org i care about:
    Plugin 'vcscommand.vim'
    Plugin 'irssilog.vim'

    " other useful stuff
    Plugin 'ciaranm/securemodelines'

    Plugin 'plasticboy/vim-markdown'
    Plugin 'PProvost/vim-markdown-jekyll'

    Plugin 'pangloss/vim-javascript'

    Plugin 'jamessan/vim-gnupg'

    Plugin 'rodjek/vim-puppet'

    Plugin 'tfnico/vim-gradle'

    Plugin 'scottdware/vim-slax'
    Plugin 'ClockworkNet/vim-junos-syntax'
    Plugin 'zainin/vim-mikrotik'
    Plugin 'drools.vim'

    " All of your Plugins must be added before the following line
    call vundle#end()         " required
    filetype plugin indent on " required
endif

if has("eval")
    let perl_include_pod = 1
    let perl_want_scope_in_variables = 1
    let perl_extended_vars = 1
    let perl_fold = 1
    "let perl_fold_blocks = 1

    let perl6_embedded_pir = 1
    let perl6_extended_all = 1

    " dash is a posix sh
    if executable("/bin/sh")
        if resolve("/bin/sh") =~ 'dash$'
            let g:is_posix=1
        endif
    endif

    let g:full_name = 'Mike Kelly'

    "if executable("curl")
    "    let g:netrw_http_cmd = "curl -o"
    "elseif executable("wget")
    if executable("wget")
        let g:netrw_http_cmd = "wget -q -O"
    elseif executable("fetch")
        let g:netrw_http_cmd = "fetch -o"
    else
        let g:netrw_http_cmd = ""
    endif
endif

" wrap at column 72
set tw=72
" no line numbering
set nonu
" use 4 spaces per indent instead of tabs
set et sts=4 sw=4

" some stuff borrowed from ciaranm
"-----------------------------------------------------------------------
" terminal setup
"-----------------------------------------------------------------------

" Extra terminal things
if (&term =~ "xterm\\|rxvt")
    set termencoding=utf-8
endif

if &term =~ "xterm\\|rxvt"
    " use xterm titles
    if has('title')
        set title
    endif

    " change cursor colour depending upon mode
    if exists('&t_SI')
        let &t_SI = "\<Esc>]12;lightgoldenrod\x7"
        let &t_EI = "\<Esc>]12;grey80\x7"
    endif
endif

if &term =~ "screen"
    set t_Co=256
elseif &term =~ "rxvt"
    set t_Co=88
endif

"-----------------------------------------------------------------------
" settings
"-----------------------------------------------------------------------

" Don't be compatible with vi
set nocompatible

" Enable a nice big viminfo file
set viminfo='1000,f1,:1000,/1000
set history=500

" Make backspace delete lots of things
set backspace=indent,eol,start

" Show us the command we're typing
set showcmd

" Highlight matching parens
set showmatch

" Search options: incremental search, highlight search
set hlsearch
set incsearch

" Enable syntax highlighting
if has("syntax")
    syntax on
endif

" Don't make a # force column zero.
inoremap # X<BS>#

" Enable folds
"if has("folding")
"    set foldenable
"    set foldmethod=indent
"endif

" Enable filetype settings
if has("eval")
    filetype on
    filetype plugin on
    filetype indent on
endif

" Disable modelines, use securemodelines.vim instead
set nomodeline
if has("eval")
    let g:secure_modelines_verbose = 0
    let g:secure_modelines_modelines = 15
endif

"-----------------------------------------------------------------------
" completion
"-----------------------------------------------------------------------
set dictionary=/usr/share/dict/words

"-----------------------------------------------------------------------
" autocommands
"-----------------------------------------------------------------------

if has("eval") && has("autocmd")
    augroup fromgentoo
        autocmd!

        " When editing a file, always jump to the last cursor position
        autocmd BufReadPost *
              \ if ! exists("g:leave_my_cursor_position_alone") |
              \     if line("'\"") > 0 && line ("'\"") <= line("$") |
              \         exe "normal g'\"" |
              \     endif |
              \ endif
    augroup END

    " From AHF
    function! MakeGenericCopyrightHeader()
        0 put ='# Copyright '.strftime('%Y').' '.g:full_name
        put ='# Distributed under the terms of the GNU General Public License v2'
        $
    endfun
    if exists(":for")
        fun! <SID>UpdateCopyrightHeaders()
            let l:a = 0
            for l:x in getline(1, 10)
                let l:a = l:a + 1
                if -1 != match(l:x, 'Copyright \((c) \)\?[- 0-9,]*20\(0[456789]\|1[01]\) Mike Kelly')
                    if input("Update copyright header? (y/N) ") == "y"
                        call setline(l:a, substitute(l:x, '\(20\(0[456789]\|1[01]\)\) Mike',
                                    \ '\1, 2012 Mike', ""))
                    endif
                endif
            endfor
        endfun
    endif
    augroup pioto
        autocmd!

        autocmd BufReadPost **.git/COMMIT_EDITMSG exe "normal gg"
        autocmd BufNewFile,BufRead /etc/dbus-1/**/*.conf setl ft=xml
        autocmd BufNewFile *.exheres-* call MakeGenericCopyrightHeader()
        autocmd FileType perl setl makeprg=$VIMRUNTIME/tools/efm_perl.pl\ -c\ %\ $*
        autocmd FileType perl setl errorformat=%f:%l:%m
        if exists("*<SID>UpdateCopyrightHeaders")
            autocmd BufWritePre * call <SID>UpdateCopyrightHeaders()
        endif
        autocmd BufNewFile,BufRead /tmp/*sup*,/tmp/ner-* setl ft=mail
        autocmd BufNewFile,BufRead mutt-*-\w\+,/tmp/*sup*,/tmp/ner-* +/^\s*$
        autocmd FileType remind autocmd BufWritePost <buffer> :!pkill -HUP -f remind-notify
        autocmd BufNewFile,BufRead /{etc,lib*}/systemd/**.{conf,target,service,socket,mount,automount,swap,path,timer,snapshot,device} setl ft=desktop
        autocmd BufNewFile,BufRead **/.claws-mail/tmp/tmpmsg.* setl ft=mail
    augroup END
endif

"-----------------------------------------------------------------------
" special less.sh and man modes
"-----------------------------------------------------------------------

if has("eval") && has("autocmd")
    fun! <SID>check_pager_mode()
        if exists("g:loaded_less") && g:loaded_less
            " we're in vimpager / less.sh / man mode
            set laststatus=0
            set ruler
            set nonumber
            set foldmethod=manual
            set foldlevel=99
            set nolist
        endif
    endfun
    autocmd VimEnter * :call <SID>check_pager_mode()
endif

" show info about the syntax hilighting under the cursor
map <Leader>sc :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
            \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Keep all swap files in one place; makes recovering later easier, and
" avoids Dropbox being dumb, etc...
if !isdirectory(expand("~/.vim_swap/"))
    if exists("*mkdir")
        call mkdir(expand("~/.vim_swap/"), "", 0700)
    end
endif
set directory^=~/.vim_swap//

" For some things that're local to certain systems.
if filereadable( expand("~") . "/.vimrc.local" )
    source ~/.vimrc.local
endif

