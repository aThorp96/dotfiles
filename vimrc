"
" .vimrc
"
" Vim configuration resource file.  Specifies desired
" behavior for the vim editor.
"
:set showmode          " Tell you if you're in insert mode
:set tabstop=4         " Set the tabstop to 4 spaces
:set shiftwidth=4      " Shiftwidth should match tabstop
:set expandtab         " Convert tabs to <tabstop> number of spaces
:set nowrap            " Do not wrap lines longer than the window
:set nowrapscan        " Do not wrap to the top of the file while searching
:set ruler             " Show the cursor position all the time
:set showmatch         " Show matching [] () {} etc...
:set smartindent       " Let vim help you with your code indention
:set nohlsearch        " Don't highlight strings you're searching for
:set formatoptions+=ro " Automatically insert the comment character when
                       " you hit <enter> (r) or o/O (o) in a block comment.

:set backspace=2       " makes backspace work like you expect
:set scrolloff=10      " leaves a buffer of ten lines below your curser until you reach the end of file.
:set number            " Makes line number appear (Why is this not default?).
:set relativenumber    " Makes relative numbers

" Switch syntax highlighting on, when the terminal can support colors
if &t_Co > 2 || has("gui_running")
    :syntax on
    " Change the highlight color for Comment and Special
    " to Cyan.  Blue is too dark for a black background.
    :highlight Comment  term=bold ctermfg=cyan guifg=cyan
    :highlight Special  term=bold ctermfg=cyan guifg=cyan
    :highlight Constant term=bold ctermfg=red  guifg=cyan
endif

" Make vim turn *off* expandtab for files named Makefile or makefile
" We need the tab literal
:autocmd BufNewFile,BufRead [Mm]akefile* set noexpandtab

" Make vim recognize a file ending in ".template" be a C++ source file
:autocmd BufNewFile,BufRead *.template set ft=cpp


""""""""""" Plugins"""""""""""
execute pathogen#infect()
filetype plugin indent on

