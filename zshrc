# Mike Kelly's ~/.zshrc
# Largely ported from my ~/.bashrc (same repo), with help from this
# series of blog posts:
#   https://scriptingosx.com/2019/06/moving-to-zsh/

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

# fun stuff from ferdy
current_git_branch() {
    # don't let gnu git mess stuff up
    git --version 1>/dev/null 2>&1 || return

    local result=$(git symbolic-ref HEAD 2>/dev/null)

    [[ -z ${result} ]] || echo " (${result##refs/heads/})"
}

current_cvs_repo() {
    local result tag

    if [[ -f CVS/Repository ]] ; then
        result="$(< CVS/Repository)"
        if [[ -f CVS/Tag ]] ; then
            tag=" $(sed s/^.// CVS/Tag)"
        fi
        echo " (CVS: ${result%%/*}${tag})"
    fi
}

current_svn_rev() {
    local result

    if [[ -d .svn ]] ; then
        result=$(svn info | sed -n -e '/^Revision: \([0-9]*\).*$/s//\1/p')
        echo " (SVN: r${result})"
    fi
}

_git_branch_status() {
    local result="${1}"
    [[ -n "${result}" ]] || return

    local desc="$(git describe 2>/dev/null)"
    [[ -n "${desc}" ]] && result="${result%)}@${desc})"

    local status="$(git branch -v 2>/dev/null |perl -ne '/^\*/ or next; /(\[(?:ahead|behind)[^\]]+\])/; print $1')"
    [[ -n "${status}" ]] && result="${result%)} ${status})"

    echo "${result}"
}

current_scm_info() {
    local mygitinfo="$(__git_ps1 2>/dev/null || current_git_branch)" # from the git bash_completion script
    mygitinfo="$(_git_branch_status "${mygitinfo}")"
    local mycvsinfo="$(current_cvs_repo)"
    local mysvninfo="$(current_svn_rev)"

    if [[ -n ${mygitinfo} ]] ; then
        echo "${mygitinfo}"
    elif [[ -n ${mycvsinfo} ]] ; then
        echo "${mycvsinfo}"
    elif [[ -n ${mysvninfo} ]] ; then
        echo "${mysvninfo}"
    else
        echo ""
    fi
}

# default prompt coloring
host_fg_color="33"
host_bg_color=""
root_bg_color="41"
# color prompts differently for different hosts
# TODO port this to zsh
#[[ -f "${HOME}/.bash_colors" ]] && source "${HOME}/.bash_colors"

[[ "${EUID}" -eq 0 ]] && host_bg_color="${root_bg_color}"

[[ -n "${host_bg_color}" ]] && host_bg_color=";${host_bg_color}"

# Shell Prompt magic

#export PS1='\[\e[01;${host_fg_color}${host_bg_color}m\]\u@\h\[\e[0m\] \D{%F} \t\n ($?) \[\e[01;34m\]\w\[\e[0m\]$(current_scm_info) \[\e[01;34m\]\$\[\e[0m\] '
# TODO dynamic host coloring
# TODO scm info
PS1="%B%F{yellow}%n@%m%f%b %D{%F %T} "$'\n'" (%?) %B%F{blue}%~ %#%f%b "

# Change the window title of X terminals
case ${TERM} in
        xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix)
                PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
                ;;
        screen*)
                PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
                ;;
esac

[[ "${TERM}" == "rxvt-unicode-256color" ]] && export TERM="rxvt-unicode"

# some os-specific aliases and such
case "$(uname -s)" in
    FreeBSD)
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

[[ -x "$(whence -p hub)" ]] && eval "$(hub alias -s)"

[[ -f "${HOME}/.zshrc.local" ]] && source "${HOME}/.zshrc.local"

[[ -f "${HOME}/perl5/perlbrew/etc/zshrc" ]] && source "${HOME}/perl5/perlbrew/etc/zshrc"

:

# vim: set ft=zsh :
