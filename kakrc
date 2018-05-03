# Set tab length to 4 characters
hook global InsertChar \t %{ exec -draft -itersel h@ }
set global tabstop 4
set global indentwidth 4

# Interface option
 
#   Set line numbers
addhl global/ number_lines -relative -hlcursor
set global scrolloff 999,0
add-highlighter global/ show_matching
#   Turns off mouse navigation
set global ui_options ncurses_enable_mouse=false # ncurses_assistant=dilbert


#   Set color scheme
colorscheme gruvbox

#Type specific hooks (Thanks @whereswaldon )
#   -Markdown
hook global WinCreate .*\.md %{ add-highlighter global wrap -word -indent }

#   -C
hook global WinCreate .*\.cc %{

    }

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
hook global WinCreate .*\.ledger %{
    colorscheme gruvbox
}

