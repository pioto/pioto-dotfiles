# Mike Kelly's ~/.zshrc
# Largely ported from my ~/.bashrc (same repo), with help from this
# series of blog posts:
#   https://scriptingosx.com/2019/06/moving-to-zsh/

if [[ -r /etc/zshrc ]] ; then
    . /etc/zshrc
fi

# Lines configured by zsh-newuser-install
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/pioto/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Additional shell completion stuff
autoload bashcompinit && bashcompinit
if [[ -x "$(whence -p aws_completer)" ]] ; then
    complete -C aws_completer aws
fi

# additional history config and zsh option tuning

# Include timestamps in history
setopt EXTENDED_HISTORY
# share history across multiple zsh sessions
setopt SHARE_HISTORY
# append to history
setopt APPEND_HISTORY
# expire duplicates first
setopt HIST_EXPIRE_DUPS_FIRST
# do not store duplications
setopt HIST_IGNORE_DUPS
#ignore duplicates when searching
setopt HIST_FIND_NO_DUPS
# removes blank lines from history
setopt HIST_REDUCE_BLANKS

[[ -f "${HOME}/.inputrc" ]] && \
    export INPUTRC="${HOME}/.inputrc"

# default prompt coloring
host_fg_color="yellow"
host_bg_color="default"
root_bg_color="red"
# color prompts differently for different hosts
[[ -f "${HOME}/.zsh_colors" ]] && source "${HOME}/.zsh_colors"

[[ "${EUID}" -eq 0 ]] && host_bg_color="${root_bg_color}"

# Shell Prompt

# include scm info in my prompt, courtesy of
#   https://git-scm.com/book/en/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Zsh
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
zstyle ':vcs_info:git:*' formats '%f(%b) %F{blue}'
zstyle ':vcs_info:*' enable git

PS1="%B%F{${host_fg_color}}%K{${host_bg_color}}%n@%m%k%f%b %D{%F %T} "$'\n'" (%?) %B%F{blue}%~ %b\${vcs_info_msg_0_}%B%#%f%b "

# Change the window title of X terminals
case ${TERM} in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix|vt100)
        precmd_term_title() { echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007" }
        precmd_functions+=( precmd_term_title )
        ;;
    screen*)
        precmd_term_title() { echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\" }
        precmd_functions+=( precmd_term_title )
        ;;
esac

[[ "${TERM}" == "rxvt-unicode-256color" ]] && export TERM="rxvt-unicode"

[[ -n "${TMUX}" && "${TERM}" == "screen" ]] && export TERM="xterm-256color"

# some os-specific aliases and such
case "$(uname -s)" in
    FreeBSD|Darwin)
        alias ls='ls -GF'
        [[ "${TERM}" == "rxvt-unicode" ]] && export TERM="rxvt"
        ;;
    Linux|CYGWIN*)
        alias ls='ls -F --color=auto'
        # debian/ubuntu are annoying...
        [[ -x "$(whence -p ack-grep)" && ! -x "$(whence -p ack)" ]] \
            && alias ack='ack-grep'
        ;;
    *)
        alias ls='ls -F'
        [[ "${TERM}" == "rxvt-unicode" ]] && export TERM="rxvt"
        ;;
esac

alias fixssh='. ~/.ssh_env'

export CAVE_RESOLVE_OPTIONS="--continue-on-failure if-satisfied --resume-file ${HOME}/cave-resume"
export CAVE_RESUME_OPTIONS="${CAVE_RESOLVE_OPTIONS}"
export PALUDIS_OPTIONS="--continue-on-failure if-satisfied --resume-command-template ${HOME}/paludis-resume"
export RECONCILIO_OPTIONS="${PALUDIS_OPTIONS}"

alias cr="sudo cave resume --resume-file ${HOME}/cave-resume"

function pen_lookup() {
    curl -s https://www.iana.org/assignments/enterprise-numbers/enterprise-numbers | grep -A3 "^${1}$"
}

[[ -x "$(whence -p hub)" ]] && eval "$(hub alias -s)"

[[ -f "${HOME}/.zshrc.local" ]] && source "${HOME}/.zshrc.local"

[[ -f "${HOME}/perl5/perlbrew/etc/zshrc" ]] && source "${HOME}/perl5/perlbrew/etc/zshrc"

:

# vim: set ft=zsh :
