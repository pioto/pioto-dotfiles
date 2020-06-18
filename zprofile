# zsh ~/.zprofile file

if [[ -r /etc/zprofile ]] ; then
    . /etc/zprofile
fi

if [[ -x "$(whence -p keychain)" ]] ; then
    ssh="$(cd ${HOME}/.ssh 2>/dev/null && command ls id_*.pub 2>/dev/null|sed s/.pub//)"
    #[[ -d "${HOME}/.gnupg" && -x "$(whence -p gpg)" ]] \
    #	&& gpg="$(gpg --list-secret-keys |sed -n '/^sec/s/.*\d*[DR]\/\([0-9A-F]*\).*/\1/p')"
    if [[ -n "${ssh}${gpg}" ]] ; then
        keychain ${ssh} ${gpg}
        if [[ -f "${HOME}/.keychain/${HOSTNAME}-sh" ]] ; then
            . "${HOME}/.keychain/${HOSTNAME}-sh"
        fi
        if [[ -f "${HOME}/.keychain/${HOSTNAME}-sh-gpg" ]] ; then
            . "${HOME}/.keychain/${HOSTNAME}-sh-gpg"
        fi
    fi
    unset ssh gpg
fi

for v in $(typeset +m 'SSH*' 'DISPLAY*' | sed 's/^exported //') ; do
    typeset +p "${v}"
done > "${HOME}/.ssh_env"

[[ -f "${HOME}/.zprofile.local" ]] && source "${HOME}/.zprofile.local"

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

:

# vim: set ft=zsh :
