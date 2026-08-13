set -e

. "$(dirname "$0")/test.sh"

if [ ! -f "$HOME/.panboticon.json" ]
then
    echo "{}" >"$HOME/.panboticon.json"
    trap "rm -f \"$HOME/panboticon.json\"" EXIT
fi

(
    PANBOTICON_CONFIG=""
    . "$PANBOTICON_LIB/configure.sh"
    set -x
    test "$PANBOTICON_CONFIG" = "$HOME/.panboticon.json"
)

(
    PANBOTICON_CONFIG="$PANBOTICON_LIB/config.json"
    . "$PANBOTICON_LIB/configure.sh"
    set -x
    test "$PANBOTICON_CONFIG" = "$PANBOTICON_LIB/config.json"
    test -z "$PANBOTICON_REGION"
    test -z "$PANBOTICON_AZ"
    test -z "$PANBOTICON_VPC_ID"
    test -z "$PANBOTICON_SUBNET_ID"
    test -z "$PANBOTICON_INSTANCE_PROFILE"
    test -z "$PANBOTICON_INSTANCE_TYPE"
    test -z "$PANBOTICON_HUMAN_USER"
    test -z "$PANBOTICON_BOT_USER"
    test -z "$PANBOTICON_HUMAN_EMAIL"
    test -z "$PANBOTICON_BOT_GITHUB_APP_ID"
    test "$PANBOTICON_BOT_GITHUB_APP_INSTALLATIONS" = '[]'
    test -z "$PANBOTICON_BOT_GITHUB_APP_PRIVATE_KEY"
    test "$PANBOTICON_HUMAN_SHELL" = "/bin/zsh"
    test "$PANBOTICON_BOT_SHELL" = "/bin/bash"
    test "$PANBOTICON_TERM" = "xterm-256color"
    test "$PANBOTICON_BOT_REJECT_CIDR_PREFIXES" = '["169.254.169.254/32","fd00:ec2::254/128"]'
    test -z "$PANBOTICON_HUMAN_BOOTSTRAP"
    test -z "$PANBOTICON_BOT_BOOTSTRAP"
    test -z "$PANBOTICON_SLACK_INCOMING_WEBHOOK_URL"
)

(
    PANBOTICON_CONFIG="$(dirname "$0")/config.json"
    . "$PANBOTICON_LIB/configure.sh"
    set -x
    test "$PANBOTICON_CONFIG" = "$(dirname "$0")/config.json"
    test "$PANBOTICON_REGION" = ""
    test "$PANBOTICON_AZ" = "usw2-az3"
    test "$PANBOTICON_VPC_ID" = "vpc-d2264baa"
    test -z "$PANBOTICON_SUBNET_ID"
    test "$PANBOTICON_INSTANCE_PROFILE" = "test"
    test "$PANBOTICON_INSTANCE_TYPE" = "t4g.nano"
    test "$PANBOTICON_HUMAN_USER" = "rcrowley"
    test "$PANBOTICON_BOT_USER" = "rbotley"
    test "$PANBOTICON_HUMAN_EMAIL" = "rcrowley@rcrowley.org"
    test "$PANBOTICON_HUMAN_SHELL" = "/bin/zsh"
    test "$PANBOTICON_BOT_SHELL" = "/bin/bash"
)

# TODO test the -c option, too
