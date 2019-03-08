<<<<<<< HEAD
# Turns off mouse navigation
set global ui_options ncurses_enable_mouse=false

=======
>>>>>>> d42b260ae18a8708dc3b9b1b0759f4b2c6487bbe
# Set tab length to 4 characters
hook global InsertChar \t %{ exec -draft -itersel h@ }
set global tabstop 4
set global indentwidth 4

<<<<<<< HEAD
#Set line numbers
addhl global/ number_lines -relative -hlcursor
set global scrolloff 999,0

#Set color scheme
colorscheme YellowLines
=======
# Interface option
 
#   Set line numbers
addhl global/ number_lines -relative -hlcursor
set global scrolloff 999,0
add-highlighter global/ show_matching
#   Turns off mouse navigation
set global ui_options ncurses_enable_mouse=false # ncurses_assistant=dilbert


#   Set color scheme
colorscheme gruvbox
>>>>>>> d42b260ae18a8708dc3b9b1b0759f4b2c6487bbe

#Type specific hooks (Thanks @whereswaldon )
#   -Markdown
hook global WinCreate .*\.md %{ 
add-highlighter global wrap -word -indent 
}

<<<<<<< HEAD
=======
#   -C
hook global WinCreate .*\.c %{

    }

>>>>>>> d42b260ae18a8708dc3b9b1b0759f4b2c6487bbe
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
<<<<<<< HEAD
hook global WinCreate .*\.dat %{
    colorscheme gruvbox
}
=======
hook global WinCreate .*\.ledger %{
    colorscheme gruvbox
}

>>>>>>> d42b260ae18a8708dc3b9b1b0759f4b2c6487bbe
