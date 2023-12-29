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
add-highlighter global/ show-whitespaces

##########################
#  Homebrew commands
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
map -docstring "parse JSON string" global user j "| python3 -c 'import json,sys;print(json.load(sys.stdin))' | jq .<ret>"
map -docstring "reload kakrc" global user r :source<space>~/.config/kak/kakrc<ret>
map -docstring "lsp mode" global user l ':enter-user-mode lsp<ret>'
map -docstring "next lint message" global user L :lint-next-message<ret>
map -docstring "spell" global user s :spell<ret>
map -docstring "clear spell" global user C :spell-clear<ret>
map -docstring "system-yank" global user y |pbcopy&&pbpaste<ret>
map -docstring "comment line" global user c :comment-line<ret>
map -docstring "format" global user f :format<ret>
# map -docstring "tagbar" global user t :tagbar-toggle<ret>
map -docstring "fzf open file" global user o :fzf-mode<ret>f
map -docstring "fzf switch buffer" global user b :fzf-mode<ret>b

############
# Plugins
############
# source "%val{config}/plugins/uxn.kak/tal.kak"
source "%val{config}/plugins/plug.kak/rc/plug.kak"

plug "enricozb/tabs.kak" config %{
    set-option global tabs_options --minified
}

# plug "danr/kakoune-easymotion" config %{
#     map global user w :easy-motion-w<ret>
#     map global user W :easy-motion-W<ret>
#     map global user j :easy-motion-j<ret>
# }

# plug "andreyorst/tagbar.kak" defer "tagbar" %{
#     set-option global tagbar_sort true
#     set-option global tagbar_size 40
#     set-option global tagbar_display_anon false
# } config %{
#     # if you have wrap highlighter enamled in you configuration
#     # files it's better to turn it off for tagbar, using this hook:
#     hook global WinSetOption filetype=tagbar %{
#         remove-highlighter window/wrap
#         # you can also disable rendering whitespaces here, line numbers, and
#         # matching characters
#     }
# }

plug "golang/tools" noload do %{
    go install -v golang.org/x/tools/gopls@latest
    echo DONE
}

plug "occivink/kakoune-filetree" do %{
    map -docstring "toggle kaktree" global user t :filetree<ret>
}


plug "ul/kak-lsp" do %{
    cargo install --locked --force --path .

    define-command -override -hidden lsp-show-error -params 1 -docstring "Render error" %{
        echo -debug "kak-lsp:" %arg{1}
        info -markup -title "{Error}KAK-LSP Error!" "{Error}kak-lsp: %arg{1}"
    }

    echo DONE
} config %{
    declare-option str lsp_toml_path '$HOME/.config/kak-lsp/kak-lsp.toml'

    # Look for a file named .kakrc.local in working directory on kakoune startup
    evaluate-commands %sh{
        DIR="$(git rev-parse --show-toplevel 2>/dev/null)"
        if [ -f "${DIR:-.}/deno.json" ]; then
            printf "set-option global lsp_toml_path '$HOME/.config/kak-lsp/kak-lsp-deno.toml'"
        fi
    }

    set global lsp_cmd "kak-lsp -s %val{session} --config %opt{lsp_toml_path}" # -vvv --log /tmp/kak-lsp.log"

    hook global WinSetOption filetype=(rust|typescript|dart|python|ruby|`python`) %{
      echo -debug "Starting LSP with configuration %opt{lsp_toml_path}"
      lsp-start
      lsp-enable-window
      lsp-auto-hover-enable
      lsp-inlay-diagnostics-enable window
      # lsp-inlay-hints-enable window
      lsp-inlay-code-lenses-enable window

      set-option window lsp_hover_anchor true
    }

    hook global KakEnd .* lsp-exit
}



plug "ABuffSeagull/kakoune-vue"

plug "https://git.sr.ht/~athorp96/uxntal.kak"

plug "kakoune-editor/kakoune-extra-filetypes"

plug "andreyorst/fzf.kak"
map global normal <c-f> ': fzf-mode<ret>'

plug "Anfid/cosy-gruvbox.kak" theme

plug "https://git.sr.ht/~athorp96/uxntal.kak"

plug "whereswaldon/shellcheck.kak"

plug "andreyorst/smarttab.kak"

plug "andreyorst/kaktree" defer kaktree %{
  set-option global kaktree_double_click_duration '0.5'
  set-option global kaktree_indentation 1
  map global normal <F2> ': kaktree-toggle<ret>' -docstring 'toggle filetree'
} config %{
  hook global WinSetOption filetype=kaktree %{
    remove-highlighter buffer/numbers
    remove-highlighter buffer/matching
    remove-highlighter buffer/wrap
    remove-highlighter buffer/show-whitespaces
  }
  kaktree-enable
}

##############################################
# Type specific hooks (Thanks @whereswaldon )
##############################################
#-Typescript
hook global BufSetOption filetype=typescript %{
    set-option buffer lintcmd 'run() { if [[ -f "$(git rev-parse --show-toplevel)/package.json" ]]; then cat "$1" | npx eslint -f unix --stdin --stdin-filename "$kak_buffile"; fi } && run'
    set-option buffer formatcmd "prettier --stdin-filepath=%val{buffile}"

    hook buffer ModeChange pop:insert:normal %{
        lint
    }

    hook buffer BufWritePre .* %{
        lint
    }

    hook buffer WinDisplay .* %{
        lint
    }


    set buffer tabstop 2
    set buffer indentwidth 2
    expandtab

    lsp-auto-hover-enable
}

#-Ruby
hook global BufSetOption filetype=ruby %{
    echo "Ruby mode"
    set-option buffer lintcmd %{ run() { cat "${1}" | timeout 5 bundle exec rubocop -c $(git rev-parse --show-toplevel 2>/dev/null || pwd)/.rubocop.yml --format emacs -s "${kak_buffile}" 2>&1; } && run }
    set-option buffer formatcmd "timeout 5 bundle exec rubocop -x -o /dev/null -c $(git rev-parse --show-toplevel 2>/dev/null || pwd)/.rubocop.yml -s '${kak_buffile}' | sed -n '2,$p'"

    hook buffer ModeChange pop:insert:normal %{
        lint
    }

    hook buffer BufWritePre .* %{
        lint
    }

    hook buffer BufWritePost .* %{
        git show-diff
    }

    hook buffer WinDisplay .* %{
        lint
    }


    git show-diff
    set buffer tabstop 2
    set buffer indentwidth 2
    expandtab
    # tagbar-enable

    lsp-auto-hover-enable

}

#-Markdown
hook global WinSetOption filetype=markdown %{
  add-highlighter buffer/ wrap -word -indent
  add-highlighter window/fold-mark ref fold-mark
}

hook global BufSetOption filetype=gemini %{
  echo -debug "Gemini mode"
  colorscheme gruvbox-dark
  add-highlighter buffer/ wrap -word -indent
}

hook global WinCreate .*\.tex %{
  add-highlighter buffer/ wrap -word -indent
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
hook global BufOpenFile .*\.pyi %{
    set-option buffer filetype python
}

hook global WinSetOption filetype=python %{
  expandtab

  addhl buffer/ show-whitespaces

    # hook global InsertChar \t %{ exec -draft -itersel h@ }
  jedi-enable-autocomplete
    set-option window lintcmd %{ run() { timeout 5 python3 -m pylint --msg-template='{path}:{line}:{column}: {category}: {msg_id}: {msg} ({symbol})' "$1" | awk -F: 'BEGIN { OFS=":" } { if (NF == 6) { $3 += 1; print } }'; }; run }
    set-option window formatcmd 'black -q  -'
  # tagbar-enable
}

#  - Format on write
hook global BufWritePre .*\.py %{
  # echo -debug "Running Black on %val{bufname}"
  # format
  lint
}

#  - .pt files are python templated HTML
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
