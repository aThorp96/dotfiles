# Mouse navigation
set global ui_options ncurses_enable_mouse=false

# Set tab length to 4 characters
set global tabstop 4
set global indentwidth 4

# jk to escape
hook global InsertChar k %{ try %{
      exec -draft hH <a-k>jk<ret> d
        exec <esc>
}}

# Set line numbers
addhl global/ number-lines -relative -hlcursor
set global scrolloff 999,0

# Colors and things
# colorscheme gruvbox
add-highlighter global/ regex \b(TODO|FIXME|XXX|NOTE)\b 0:default+rb
add-highlighter global/ show-matching

# Type specific hooks (Thanks @whereswaldon )
##############################################

#-Markdown
hook global WinCreate .*\.md %{ 
	add-highlighter global wrap -word -indent 
}

#-Golang
hook global WinCreate .*\.go %{
    echo -debug "Go mode"
    go-enable-autocomplete
    map buffer user ? :go-doc-info<ret>
    map buffer user j :go-jump<ret>
}

hook global BufWritePre .*\.go %{
    go-format
}

#-Python
hook global WinSetOption filetype=python %{
    hook global InsertChar \t %{ exec -draft -itersel h@ }
	jedi-enable-autocomplete
	lint-enable
	addhl buffer/ show-whitespaces
	set-option window lintcmd 'python -m pylint'
	set-option window formatcmd 'black -q  -'
}

#	- Format on write
hook global BufWritePre .*\.py %{
	echo -debug "Running Black on %val{bufname}"
	format
}

#	- .pt files are python templated HTML
hook global WinCreate .*\.pt %{
	set-option window filetype html
}

hook global WinCreate .*\.json %{
	addhl buffer/ show-whitespaces
}

hook global WinCreate .*\.yaml %{
    set global tabstop 2
    set global indentwidth 2
    hook global InsertChar \t %{ exec -draft -itersel h@ }
	addhl buffer/ show-whitespaces
}

#-C
hook global WinSetOption filetype=c %{
    clang-enable-autocomplete
    clang-enable-diagnostics
    hook buffer BufWritePre .* %{
        clang-parse
    }
    hook buffer InsertEnd .* %{
        clang-parse
    }
}

#-Ledger 
hook global WinCreate .*\.dat %{
    colorscheme gruvbox
}
hook global WinCreate .*\.ledger %{
    colorscheme gruvbox
}

