# general environment variables I want to have all the time
# mostly my very special path tuning for every system I've ever used

# Locality type stuff
export TZ="America/New_York"
if [[ -x "$(whence -p locale)" ]] ; then
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

export GOPATH="${HOME}/gopath"

# properly reorder path... this is icky
PATH=":${PATH}"
PATH="${PATH/:\/usr\/local\/bin/}"
PATH="${PATH/:\/usr\/local\/sbin/}"
PATH="${PATH/:\/usr\/sbin/}"
PATH="${PATH/:\/sbin/}"
PATH="${PATH/:\/usr\/local\/scripts/}"
PATH="${PATH/:${HOME}\/bin/}"
texlive_year="2012"
texlive_arch="$(echo `uname -m`-`uname -s`|tr '[A-Z]' '[a-z]')"
PATH="${PATH/:\/usr\/local\/texlive\/${texlive_year}\/bin\/${texlive_arch}/}"
PATH="${PATH/:${HOME}\/.local\/lib\/npm\/bin/}"
PATH="${PATH/:\/opt\/local\/bin/}"
PATH="${PATH/:\/opt\/local\/sbin/}"
if which ruby >/dev/null 2>&1 && which gem >/dev/null 2>&1; then
    gem_userdir="$(ruby -r rubygems -e 'puts Gem.user_dir')"
    PATH="${PATH/:${gem_userdir}\/bin/}"
fi
PATH="${PATH/:${HOME}\/.node\/bin/}"
PATH="${PATH/:${HOME}\/.rvm\/bin/}"
PATH="${PATH/:${GOPATH}/}"
PATH="${PATH/:\/opt\/local\/Library\/Frameworks\/Python.framework\/Versions\/2.7\/bin}"
PATH="${PATH/:${HOME}\/Library\/Python\/3.7\/bin/}"
PATH="${PATH/#:/}"
PATH="/sbin:/usr/local/sbin:/usr/sbin:/usr/local/bin:${PATH}"
[[ -d "/usr/local/scripts" ]] && PATH="/usr/local/scripts:${PATH}"
[[ -d "${HOME}/bin" ]] && PATH="${HOME}/bin:${PATH}"
[[ -d "/usr/local/texlive/${texlive_year}/bin/${texlive_arch}" ]] &&
    PATH="/usr/local/texlive/${texlive_year}/bin/${texlive_arch}:${PATH}"
[[ -d "${HOME}/.local/lib/npm/bin" ]] &&
    PATH="${HOME}/.local/lib/npm/bin:${PATH}"
for d in /opt/local/{s,}bin ; do
    [[ -d "$d" ]] &&
        PATH="${d}:${PATH}"
done
[[ -n "${gem_userdir}" && -d "${gem_userdir}" ]] &&
    PATH="${gem_userdir}/bin:${PATH}"
[[ -d "${HOME}/.node/bin" ]] && PATH="${HOME}/.node/bin:${PATH}"
[[ -d "$HOME/.rvm/bin" ]] && PATH="$PATH:$HOME/.rvm/bin"
[[ -d "${HOME}/.local/lib/npm/bin" ]] &&
    PATH="${HOME}/.local/lib/npm/bin:${PATH}"
for d in /opt/local/{s,}bin ; do
    [[ -d "$d" ]] &&
        PATH="${d}:${PATH}"
done
[[ -d "${HOME}/Library/Python/3.7/bin" ]] && PATH="${HOME}/Library/Python/3.7/bin:${PATH}"
export PATH
unset texlive_year texlive_arch

# the same sorta ickyness for perl lib and man paths
if [[ -n "${PERL5LIB}" ]] ; then
    PERL5LIB=":${PERL5LIB}"
    PERL5LIB="${PERL5LIB/:${HOME}\/lib\/perl5:${HOME}\/lib\/perl5\/site_perl}"
fi
[[ -d "${HOME}/lib/perl5" ]] && PERL5LIB="${PERL5LIB}:${HOME}/lib/perl5:${HOME}/lib/perl5/site_perl"
[[ -n "${PERL5LIB}" ]] && export PERL5LIB="${PERL5LIB/#:/}"
[[ -x "$(whence -p manpath)" ]] && MANPATH="$(manpath 2>/dev/null)"
if [[ -n "${MANPATH}" ]] ; then
    MANPATH=":${MANPATH}"
    MANPATH="${MANPATH/:${HOME}\/man/}"
    MANPATH="${MANPATH/:${HOME}\/share\/man/}"
    MANPATH="${MANPATH/:${HOME}\/.node\/share\/man/}"
    MANPATH="${MANPATH/#:/}"
fi
[[ -d "${HOME}/man" ]] && MANPATH="${HOME}/man:${MANPATH}"
[[ -d "${HOME}/share/man" ]] && MANPATH="${HOME}/share/man:${MANPATH}"
[[ -d "${HOME}/.node/share/man" ]] && MANPATH="${HOME}/.node/share/man:${MANPATH}"
[[ -n "${MANPATH}" ]] && export MANPATH

[[ -d "${HOME}/.node/lib/node_modules" ]] && export NODE_PATH="${HOME}/.node/lib/node_modules"

# set up preferred apps
[[ -x "$(whence -p vim)" ]] && export EDITOR="$(whence -p vim)"
[[ -z "$EDITOR" || ! -x "$EDITOR" && -x "$(whence -p vi)" ]] && export EDITOR="$(whence -p vi)"
[[ -z "${BROWSER}" && -x "$(whence -p browser)" ]] \
    && export BROWSER="$(whence -p browser)"
[[ -z "${BROWSER}" && -x "$(whence -p chrome)" ]] \
    && export BROWSER="$(whence -p chrome)"
[[ -z "${BROWSER}" && -x "$(whence -p firefox3)" ]] \
    && export BROWSER="$(whence -p firefox3)"
[[ -z "${BROWSER}" && -x "$(whence -p firefox)" ]] \
    && export BROWSER="$(whence -p firefox)"
[[ -z "${BROWSER}" && -x "$(whence -p lynx)" ]] \
    && export BROWSER="$(whence -p lynx)"
[[ -z "${BROWSER}" && -x "$(whence -p links)" ]] \
    && export BROWSER="$(whence -p links)"

export PAGER="less"
export LESS="-R"

export GPG_TTY="$(tty)"

[[ -x "$(whence -p gnome-ssh-askpass)" ]] \
    && export SSH_ASKPASS="$(whence -p gnome-ssh-askpass)"

# Mac OS Java Magic
[[ -x /usr/libexec/java_home ]] && export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"

# Gradle
[[ -x /opt/local/share/java/gradle ]] && export GRADLE_HOME="/opt/local/share/java/gradle"

# Maven
for m2 in /opt/local/share/java/maven3 ; do
    if [[ -n "${m2}" && -d "${m2}" && -x "${m2}/bin/mvn" ]] ; then
        export M2_HOME="${m2}"
        break
    fi
done
unset m2

# make Eclipse use native SSH
if [[ -x "$(whence -p ssh)" ]] ; then
    export GIT_SSH="$(whence -p ssh)"
    export SVN_SSH="${GIT_SSH} -q"
fi

# Mac OS environment variable handling MADNESS...
if [[ "$(uname -s)" == "Darwin" && -x "/bin/launchctl" ]] ; then
    for k in GIT_SSH SVN_SSH M2_HOME JAVA_HOME GRADLE_HOME PATH ; do
        /bin/launchctl setenv "$k" "${!k}"
    done
fi

