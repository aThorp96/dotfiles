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
addhl global/ number-lines -hlcursor
set global scrolloff 15,0

# Colors and things
colorscheme gruvbox-dark
add-highlighter global/ regex \b(TODO|FIXME|XXX|NOTE)\b 0:default+rb
add-highlighter global/ regex "( |\t)+$" 0:default+rb
add-highlighter global/ show-matching
add-highlighter shared/fold-mark column 73 PrimaryCursor

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
map -docstring "reload kakrc" global user r :source<space>~/.config/kak/kakrc<ret>
map -docstring "lsp mode" global user l ':enter-user-mode lsp<ret>'
map -docstring "spell" global user s :spell<ret>
map -docstring "clear spell" global user C :spell-clear<ret>
map -docstring "system-yank" global user y |pbcopy&&pbpaste<ret>
map -docstring "comment line" global user c :comment-line<ret>

############
# Plugins
############
# source "%val{config}/plugins/uxn.kak/tal.kak"
source "%val{config}/plugins/plug.kak/rc/plug.kak"

plug "golang/tools" noload do %{
    go install -v golang.org/x/tools/gopls@latest
    echo DONE
}

plug "ul/kak-lsp" do %{
    cargo install --locked --force --path .
    echo DONE
}
hook global WinSetOption filetype=(rust|typescript|dart) %{
	lsp-enable-window
}

plug "ABuffSeagull/kakoune-vue"

plug "https://git.sr.ht/~athorp96/uxntal.kak"

plug "kakoune-editor/kakoune-extra-filetypes"

plug "andreyorst/fzf.kak"
map global normal <c-f> ': fzf-mode<ret>'

plug "Anfid/cosy-gruvbox.kak" theme

plug "https://git.sr.ht/~athorp96/uxntal.kak"

plug "whereswaldon/shellcheck.kak"

##############################################
# Type specific hooks (Thanks @whereswaldon )
##############################################
#-Typescript
hook global BufSetOption filetype=typescript %{
    set buffer indentwidth 0
    add-highlighter buffer/ show-whitespaces
    lsp-auto-hover-enable
}

#-Markdown
hook global WinSetOption filetype=markdown %{
    colorscheme gruvbox
	add-highlighter buffer/ wrap -word -indent 
    add-highlighter window/fold-mark ref fold-mark
}

hook global WinCreate .*\.tex %{
    colorscheme gruvbox
	add-highlighter buffer/ wrap -word -indent 
}

hook global BufWritePre .*\.tex %{
	spell
}

#-Golang
hook global WinSetOption filetype=go %{
    echo -debug "Go mode"
	set window lintcmd 'golangci-lint run'
    lsp-enable-window
    lsp-auto-hover-enable
    lsp-auto-signature-help-enable
    hook -group gofmt buffer BufWritePre .* %{
        lsp-formatting-sync
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
#	format
}

#	- .pt files are python templated HTML
hook global WinCreate .*\.pt %{
	set-option window filetype html
}

hook global WinCreate .*\.json %{
	addhl buffer/ show-whitespaces
}

hook global BufSetOption filetype=yaml %{
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

#-Dart
hook global WinSetOption filetype=dart %{
    echo -debug "Dart mode"
    # Set tab length to 2 space characters
    set global tabstop 2
    set global indentwidth 2
    hook global InsertChar \t %{ exec -draft -itersel h@ }
    lsp-enable-window
    lsp-auto-hover-enable
    lsp-auto-signature-help-enable

  	set-option window formatcmd 'dartfmt -l 160'
}

hook global BufWritePre filetype=dart %{
  format
}

# Protobuf
hook global WinSetOption filetype=protobuf %{
    # Set tab length to 2 space characters
    set global tabstop 2
    set global indentwidth 2
    hook global InsertChar \t %{ exec -draft -itersel h@ }
}


# Aerc email client
hook global WinCreate .*\.eml %{
    add-highlighter window/fold-mark ref fold-mark
    set global autoreload no
}

hook global WinCreate .*COMMIT_EDITMSG %{
    add-highlighter window/fold-mark ref fold-mark
    set global autoreload no
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

hook global BufCreate filetype=sh %{
    echo "enableing shellcheck"
    shellcheck-enable
}

# Not sure why this doesn't work in the filetype block
hook global WinCreate .*\.sh %{
    add-highlighter buffer/fold-mark ref fold-mark
}
