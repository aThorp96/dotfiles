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
