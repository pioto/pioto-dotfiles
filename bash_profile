[[ -f ~/.bashrc ]] && . ~/.bashrc

if [[ -x "$(type -P keychain)" ]] ; then
    ssh="$(cd ${HOME}/.ssh 2>/dev/null && command ls id_*.pub 2>/dev/null|sed s/.pub//)"
    [[ -d "${HOME}/.gnupg" ]] \
    	&& gpg="$(gpg --list-secret-keys |sed -n '/^sec/s/.*\d*[DR]\/\([0-9A-E]*\).*/\1/p')"
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

#case "${HOSTNAME}" in
#esac

for v in ${!SSH*} DISPLAY ; do
    echo "export $v=\"${!v}\""
done > "${HOME}/.ssh_env"

[[ -f "${HOME}/.bash_profile.local" ]] && source "${HOME}/.bash_profile.local"

# vim: set ft=sh :
