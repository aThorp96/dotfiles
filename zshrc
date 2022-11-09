# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh


default_tmux="base"
if [[ -z "$TMUX" && "$TERM_PROGRAM" != "vscode" ]] ; then
	# launch tmux if it isn't running
	if tmux ls |&grep $default_tmux 2>&1 >/dev/null ; then
		# attach to default session if it exists
		tmux attach -t "$default_tmux"
	else
		tmux new-session -t "$default_tmux"
	fi
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="gnzh"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

autoload -U compinit
compinit -i

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='kak'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
export GOPATH=$HOME/go
export GOGIT=$GOPATH/src/github.com/aThorp96/
export GOPRIVATE="git.playchat.net"

export PATH=$GOPATH/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/bin:$PATH
export PATH=$PATH:~/.platformio/penv/bin
export PATH="$PATH":"$HOME/.pub-cache/bin"
export PATH="$PATH":"$HOME/code/uxn/uxn/bin"
export PATH="$HOME/.rbenv/bin:$PATH"

export ANDROID_HOME="$HOME/SDKs/Android"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"


# Source optional files
declare -a optional_sources=(
"$HOME/.cargo/env"
"$HOME/.fzf.zsh"
"$HOME/.plato.zsh"
"$HOME/.zsh_aliases"
)
for file in ${optional_sources[@]}; do
    [ -f "$file" ] && echo "Loading $file" && source "$file"
done

if (which osascript >/dev/null); then
	notify() {
		osascript -e "display notification \"${1:?Notification body required}\" with title \"Shell notification\" sound name \"Bell\""
    }
fi

bak() {
	mv "${1:?Must provide file to backup}{,.bak}"
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [[ -z "$(ssh-add -l | grep 'andrew@Andrews-MacBook-Pro.local')" ]]; then
    echo "Adding SSH Key to keyring"; ssh-add ~/.ssh/id_rsa_512
fi

