#
# Panboticon completion for Zsh
#
# Usage: . lib/panboticon/completion.zsh
#

_panboticon() {

    PANBOTICON_PREFIX="$(panboticon config "PANBOTICON_PREFIX")"
    PANBOTICON_LIBEXEC="$PANBOTICON_PREFIX/libexec/panboticon"

    local -a subcommands
    subcommands=($(
        ls -1 "$PANBOTICON_LIBEXEC" |
        sort |
        xargs -I _ echo "_:"
    ))

    if (( ${subcommands[(I)${words[$CURRENT]}:]} + ${subcommands[(I)${words[$CURRENT-1]}:]} ))
    then
        :
    else
        _arguments \
            "-c[configuration file]:configuration file:_files" \
            "1: :->subcommand"
    fi

    if [[ "$state" == "subcommand" ]]
    then _describe "subcommand" subcommands
    fi
}

compdef _panboticon panboticon
