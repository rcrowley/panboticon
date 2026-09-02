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
        PANBOTICON_BOT_GITHUB_APP_ID \
        PANBOTICON_BOT_GITHUB_APP_PRIVATE_KEY \
        PANBOTICON_HUMAN_SHELL \
        PANBOTICON_BOT_SHELL \
        PANBOTICON_TERM \
        PANBOTICON_LOCAL_BOOTSTRAP \
        PANBOTICON_HUMAN_BOOTSTRAP \
        PANBOTICON_BOT_BOOTSTRAP \
        PANBOTICON_SLACK_INCOMING_WEBHOOK_URL

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
grep -E "^: \\\$\\{PANBOTICON_[_0-9A-Z]+:=\"[-./_~@0-9:A-Za-z]*\"\\}\$" >"$TMP/config.sh"

. "$TMP/config.sh"
. "$TMP/export.sh"

export PANBOTICON_OPENER_FORK="rcrowley" PANBOTICON_OPENER_VERSION="v0.1.7-rcrowley.0"
export PANBOTICON_OPENER_ARCH="$(uname -m)" PANBOTICON_OPENER_OS="$(uname -s | tr "[:upper:]" "[:lower:]")"
case "$PANBOTICON_OPENER_ARCH" in
    "aarch64") PANBOTICON_OPENER_ARCH="arm64";; # Opener uses Go-style
    "x86_64") PANBOTICON_OPENER_ARCH="amd64";;  # architecture names
esac

export PANBOTICON_UBUNTU_VERSION="24.04" # XXX PlanetScale still mostly uses 24.04 but 26.04 is out

case "$PANBOTICON_BOT_GITHUB_APP_PRIVATE_KEY" in
    ""|"op://"*) ;;
    "~") PANBOTICON_BOT_GITHUB_APP_PRIVATE_KEY="";;
    "~/"*) PANBOTICON_BOT_GITHUB_APP_PRIVATE_KEY="$HOME/${PANBOTICON_BOT_GITHUB_APP_PRIVATE_KEY#"~/"}";;
    "/"*) ;;
    *) PANBOTICON_BOT_GITHUB_APP_PRIVATE_KEY="$(dirname "$PANBOTICON_CONFIG")/$PANBOTICON_BOT_GITHUB_APP_PRIVATE_KEY";;
esac
: ${PANBOTICON_BOT_GITHUB_APP_INSTALLATIONS:="$(
    jq -c -e '[.PANBOTICON_BOT_GITHUB_APP_INSTALLATIONS[] | select(.INSTALLATION_ID != "" and .ORGANIZATION != "")]' <"$PANBOTICON_CONFIG"
)"}
export PANBOTICON_BOT_GITHUB_APP_INSTALLATIONS

: ${PANBOTICON_TERM:="xterm-256color"}

: ${PANBOTICON_BOT_REJECT_CIDR_PREFIXES:="$(
    jq -c -e '.PANBOTICON_BOT_REJECT_CIDR_PREFIXES' <"$PANBOTICON_CONFIG"
)"}
export PANBOTICON_BOT_REJECT_CIDR_PREFIXES

case "$PANBOTICON_LOCAL_BOOTSTRAP" in
    "") ;;
    "~") PANBOTICON_LOCAL_BOOTSTRAP="";;
    "~/"*) PANBOTICON_LOCAL_BOOTSTRAP="$HOME/${PANBOTICON_LOCAL_BOOTSTRAP#"~/"}";;
    "/"*) ;;
    *) PANBOTICON_LOCAL_BOOTSTRAP="$(dirname "$PANBOTICON_CONFIG")/$PANBOTICON_LOCAL_BOOTSTRAP";;
esac
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
