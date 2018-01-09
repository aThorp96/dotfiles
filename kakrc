# Turns off mouse navigation
set global ui_options ncurses_enable_mouse=false

# Set tab length to 4 characters
hook global InsertChar \t %{ exec -draft -itersel h@ }
set global tabstop 4
set global indentwidth 4

#Set line numbers
addhl global/ number_lines -relative -hlcursor
set global scrolloff 999,0

#Set color scheme
colorscheme YellowLines

#Type specific hooks (Thanks @whereswaldon )
#   -Markdown
hook global WinCreate .*\.md %{ add-highlighter global wrap -word -indent }

#   -Golang
hook global WinCreate .*\.go %{
    echo -debug "Go mode"
    go-enable-autocomplete
    map buffer user ? :go-doc-info<ret>
    map buffer user j :go-jump<ret>
}

hook global BufWritePre .*\.go %{
    go-format
}

#   -Ledger 
hook global WinCreate .*\.dat %{
    colorscheme gruvbox
}
