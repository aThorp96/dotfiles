# Mouse navigation
set global ui_options ncurses_enable_mouse=false
colorscheme default

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
colorscheme desertex
add-highlighter global/ regex \b(TODO|FIXME|XXX|NOTE)\b 0:default+rb
add-highlighter global/ show-matching

##########################
#	Homebrew commands
##########################
define-command -docstring "vsplit [<commands>]: split tmux vertically" \
vsplit -params .. -command-completion %{
        tmux-terminal-horizontal kak -c %val{session} -e "%arg{@}"
}

define-command -docstring "split [<commands>]: split tmux horizontally" \
split -params .. -command-completion %{
        tmux-terminal-vertical kak -c %val{session} -e "%arg{@}"
}

define-command -docstring "tabnew [<commands>]: create new tmux window" \
tabnew -params .. -command-completion %{
        tmux-terminal-window kak -c %val{session} -e "%arg{@}"
}

map -docstring "edit kakrc" global user e :e<space>~/.config/kak/kakrc<ret>
map -docstring "source kakrc" global user s :source<space>~/.config/kak/kakrc<ret>

############
# Plugins
############
source "%val{config}/plugins/plug.kak/rc/plug.kak"

plug "golang/tools" noload do %{
    env --chdir=$HOME GO111MODULE=on go get -v golang.org/x/tools/gopls@latest
    echo DONE
}

plug "ul/kak-lsp" do %{
    cargo install --locked --force --path .
    echo DONE
}

plug "ABuffSeagull/kakoune-vue"

plug "andreyorst/fzf.kak"
map global normal <c-f> ': fzf-mode<ret>'

plug "Anfid/cosy-gruvbox.kak" theme

plug "abuffseagull/kakoune-discord" do %{ cargo install --path . --force } %{
      discord-presence-enable
}

##############################################
# Type specific hooks (Thanks @whereswaldon )
##############################################

#-Markdown
hook global WinSetOption filetype=markdown %{
    colorscheme gruvbox
	add-highlighter buffer/ wrap -word -indent 
}

hook global WinCreate .*\.tex %{
    colorscheme gruvbox
	add-highlighter buffer/ wrap -word -indent 
}

hook global BufWritePre .*\.tex %{
	spell
}
#-Golang
hook global WinCreate .*\.go %{
    echo -debug "Go mode"
	set window lintcmd 'golangci-lint run'
    lint-enable
    lsp-enable-window
    lsp-auto-hover-enable
    lsp-auto-signature-help-enable
    hook -group gofmt buffer BufWritePre .* %{
        go-format -use-goimports
        lint
    }
    # go-enable-autocomplete
    map buffer user ? :go-doc-info<ret>
    map buffer user j :go-jump<ret>
}

#-Python
hook global WinSetOption filetype='python' %{
	addhl buffer/ show-whitespaces
    colorscheme desertex
    hook global InsertChar \t %{ exec -draft -itersel h@ }
	jedi-enable-autocomplete
	lint-enable
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
    set buffer filetype ledger
}
hook global WinCreate .*\.journal %{
    set buffer filetype ledger
}

