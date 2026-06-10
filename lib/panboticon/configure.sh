set -e

export TMP="$(mktemp -d)"
trap "rm -f -r \"$TMP\"" EXIT

: ${PANBOTICON_CONFIG:="$HOME/.panboticon.json"}
export PANBOTICON_CONFIG

{
    printf '[' >&3
    printf "export" >&4
    COMMA=""

    # List every valid configuration file key / environment variable name here.
    for V in \
        PANBOTICON_REGION \
        PANBOTICON_AZ \
        PANBOTICON_VPC_ID \
        PANBOTICON_SUBNET_ID \
        PANBOTICON_INSTANCE_PROFILE \
        PANBOTICON_INSTANCE_TYPE \
        PANBOTICON_HUMAN_USER \
        PANBOTICON_BOT_USER \
        PANBOTICON_HUMAN_EMAIL \
        PANBOTICON_BOT_EMAIL \
        PANBOTICON_HUMAN_SHELL \
        PANBOTICON_BOT_SHELL \
        PANBOTICON_HUMAN_BOOTSTRAP \
        PANBOTICON_BOT_BOOTSTRAP

    do
        printf "$COMMA\n    \": \${$V:=\\\\\"\\(.$V // \"\")\\\\\"}\"" >&3
        COMMA=","
        printf " $V" >&4
    done
    echo >&3
    echo '] | join("\\n")' >&3
    echo >&4
} 3>"$TMP/filter.jq" 4>"$TMP/export.sh"

jq -e -f "$TMP/filter.jq" -r <"$PANBOTICON_CONFIG" |
grep -E "^: \\\$\\{PANBOTICON_[_A-Z]+:=\"[-./_~@0-9A-Za-z]*\"\\}\$" >"$TMP/config.sh"

. "$TMP/config.sh"
. "$TMP/export.sh"

case "$PANBOTICON_HUMAN_BOOTSTRAP" in
    "") ;;
    "~") PANBOTICON_HUMAN_BOOTSTRAP="";;
    "~/"*) PANBOTICON_HUMAN_BOOTSTRAP="$HOME/${PANBOTICON_HUMAN_BOOTSTRAP#"~/"}";;
    "/"*) ;;
    *) PANBOTICON_HUMAN_BOOTSTRAP="$(dirname "$PANBOTICON_CONFIG")/$PANBOTICON_HUMAN_BOOTSTRAP";;
esac
case "$PANBOTICON_BOT_BOOTSTRAP" in
    "") ;;
    "~") PANBOTICON_BOT_BOOTSTRAP="";;
    "~/"*) PANBOTICON_BOT_BOOTSTRAP="$HOME/${PANBOTICON_BOT_BOOTSTRAP#"~/"}";;
    "/"*) ;;
    *) PANBOTICON_BOT_BOOTSTRAP="$(dirname "$PANBOTICON_CONFIG")/$PANBOTICON_BOT_BOOTSTRAP";;
esac
