#
# Panboticon completion for Bash
#
# Usage: . lib/panboticon/completion.bash
#        complete -F _panboticon panboticon
#

_panboticon() {

    PANBOTICON_PREFIX="$(cd "$(dirname "$(dirname "$(which "panboticon")")")" && pwd)"
    PANBOTICON_LIBEXEC="$PANBOTICON_PREFIX/libexec/panboticon"

    if [ "$1" != "panboticon" ]
    then echo '1!' >&2 && return
    fi

    case "$3" in
        "-c"|"--conf"|"--config"|"--configuration")
            COMPREPLY=($(compgen -f -- "$2"))
            return;;
    esac

    if [ "$3" -a -x "$PANBOTICON_LIBEXEC/$3" ]
    then return
    fi

    COMPREPLY=($(compgen -W "$(ls -1 --color="never" "$PANBOTICON_LIBEXEC" | sort) -c" -- "$2"))
}

complete -F _panboticon panboticon
