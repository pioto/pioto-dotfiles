# Mike Kelly's .bashrc

[[ $- != *i* ]] && return

[[ "${TERM}" == "rxvt-unicode" ]] && export TERM="rxvt"

hostname="`hostname -f 2>/dev/null`"
[[ -z "$hostname" ]] && hostname="`hostname`"

# Locality type stuff
export TZ="America/New_York"
if [[ -x "$(type -P locale)" ]] ; then
    case "`locale -a`" in
        *en_US.UTF-8*)
            LANG="en_US.UTF-8"
            ;;
        *en_US.utf8*)
            LANG="en_US.utf8"
            ;;
        *en_US*)
            LANG="en_US"
            ;;
    esac
    [[ -n "${LANG}" ]] && export LANG SUPPORTED="${LANG}:en_US:en"
fi

[[ -f "${HOME}/.inputrc" ]] && \
    export INPUTRC="${HOME}/.inputrc"

# generous history size
export HISTFILESIZE=5000 HISTSIZE=5000
shopt -s histappend

# properly reorder path... this is icky
PATH=":${PATH}"
PATH="${PATH/:\/usr\/local\/bin/}"
PATH="${PATH/:\/usr\/local\/sbin/}"
PATH="${PATH/:\/usr\/sbin/}"
PATH="${PATH/:\/sbin/}"
PATH="${PATH/:${HOME}\/bin/}"
PATH="${PATH/#:/}"
PATH="/sbin:/usr/local/sbin:/usr/sbin:/usr/local/bin:${PATH}"
[[ -d "${HOME}/bin" ]] && PATH="${HOME}/bin:${PATH}"
export PATH

# the same sorta ickyness for perl lib and man paths
if [[ -n "${PERL5LIB}" ]] ; then
    PERL5LIB=":${PERL5LIB}"
    PERL5LIB="${PERL5LIB/:${HOME}\/lib\/perl5:${HOME}\/lib\/perl5\/site_perl}"
fi
[[ -d "${HOME}/lib/perl5" ]] && PERL5LIB+=":${HOME}/lib/perl5:${HOME}/lib/perl5/site_perl"
[[ -n "${PERL5LIB}" ]] && export PERL5LIB="${PERL5LIB/#:/}"
[[ -x "$(type -P manpath)" ]] && MANPATH="$(manpath 2>/dev/null)"
if [[ -n "${MANPATH}" ]] ; then
    MANPATH=":${MANPATH}"
    MANPATH="${MANPATH/:${HOME}\/man/}"
    MANPATH="${MANPATH/#:/}"
fi
[[ -d "${HOME}/man" ]] && MANPATH="${HOME}/man:${MANPATH}"
[[ -n "${MANPATH}" ]] && export MANPATH

# set up preferred apps
export EDITOR="$(type -P vim)"
[[ -z "${BROWSER}" && -x "$(type -P firefox3)" ]] \
    && export BROWSER="$(type -P firefox3)"
[[ -z "${BROWSER}" && -x "$(type -P firefox)" ]] \
    && export BROWSER="$(type -P firefox)"
[[ -z "${BROWSER}" && -x "$(type -P lynx)" ]] \
    && export BROWSER="$(type -P lynx)"
[[ -z "${BROWSER}" && -x "$(type -P links)" ]] \
    && export BROWSER="$(type -P links)"

PAGER="less"
[[ -x "$(type -P vimpager)" ]] && PAGER="$(type -P vimpager)"
export PAGER
[[ -x "$(type -P vimmanpager)" ]] && export MANPAGER="$(type -P vimmanpager)"

[[ -f /usr/local/etc/bash_completion && -z "${BASH_COMPLETION}" ]] && \
    . /usr/local/etc/bash_completion
[[ -f /etc/profile.d/bash-completion && -z "${BASH_COMPLETION}" ]] && \
    source /etc/profile.d/bash-completion

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

current_scm_info() {
    local mygitinfo="$(__git_ps1 2>/dev/null || current_git_branch)" # from the git bash_completion script
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
[[ -f "${HOME}/.bash_colors" ]] && source "${HOME}/.bash_colors"

[[ "${EUID}" -eq 0 ]] && host_bg_color="${root_bg_color}"

[[ -n "${host_bg_color}" ]] && host_bg_color=";${host_bg_color}"

export PS1='\[\e[01;${host_fg_color}${host_bg_color}m\]\u@\h\[\e[0m\] \D{%F} \t\n ($?) \[\e[01;34m\]\w\[\e[0m\]$(current_scm_info) \[\e[01;34m\]\$\[\e[0m\] '

# Change the window title of X terminals
case ${TERM} in
        xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix)
                PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
                ;;
        screen)
                PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
                ;;
esac

# some os-specific aliases
case "$(uname -s)" in
    FreeBSD)
        alias ls='ls -GF'
        ;;
    Linux)
        alias ls='ls -F --color=auto'
        ;;
    *)
        alias ls='ls -F'
        ;;
esac

alias fixssh='. ~/.ssh_env'

export PALUDIS_OPTIONS="--continue-on-failure if-satisfied --resume-command-template ${HOME}/paludis-resume-XXXXXX"

[[ -f "${HOME}/.bashrc.local" ]] && source "${HOME}/.bashrc.local"

unset hostname

# vim: set ft=sh :
