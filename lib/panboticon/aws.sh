set -e

aws sts get-caller-identity >"/dev/null" 2>&1 || aws sso login >&2

if [ "$PANBOTICON_REGION" -a "$PANBOTICON_AZ" ]
then
    if [ "$(grep -E "\\b$PANBOTICON_AZ\\b" "$PANBOTICON_LIB/availability-zones.txt" | awk '{print $1}')" != "$PANBOTICON_REGION" ]
    then
        echo "PANBOTICON_AZ must be in PANBOTICON_REGION." >&2
        exit 1
    fi
elif [ -z "$PANBOTICON_REGION" -a "$PANBOTICON_AZ" ]
then
    PANBOTICON_REGION="$(grep -E "\\b$PANBOTICON_AZ\\b" "$PANBOTICON_LIB/availability-zones.txt" | awk '{print $1}')"
fi
if [ -z "$PANBOTICON_REGION" ]
then
    echo "At least one of PANBOTICON_REGION or PANBOTICON_AZ must be set in the configuration file, environment, or -r or -z options." >&2
    exit 1
fi
export AWS_REGION="$PANBOTICON_REGION"

PANBOTICON_AWS_ARCH="x86_64" PANBOTICON_UBUNTU_ARCH="amd64"
if echo "$PANBOTICON_INSTANCE_TYPE" | cut -d "." -f 1 | grep -q "[0-9]g"
then PANBOTICON_AWS_ARCH="arm64" PANBOTICON_UBUNTU_ARCH="arm64"
fi
export PANBOTICON_AWS_ARCH PANBOTICON_UBUNTU_ARCH

aws_vpc_subnet() {
    if [ -z "$PANBOTICON_VPC_ID" ]
    then
        echo "PANBOTICON_VPC_ID must be set in the configuration file, environment, or -v option." >&2
        exit 1
    fi # or we could choose the default VPC but I hate default VPCs

    if [ -z "$PANBOTICON_SUBNET_ID" -a "$PANBOTICON_AZ" ]
    then
        case "$PANBOTICON_AZ" in
            *[0-9]) AZ_FILTER_NAME="availability-zone-id";;
            *[a-z]) AZ_FILTER_NAME="availability-zone";;
        esac
        PANBOTICON_SUBNET_ID="$(
            aws ec2 describe-subnets --filters \
                Name="$AZ_FILTER_NAME",Values="$PANBOTICON_AZ" \
                Name="map-public-ip-on-launch",Values="true" \
                Name="vpc-id",Values="$PANBOTICON_VPC_ID" |
            jq -e -r '.Subnets[].SubnetId' |
            sort -R |
            head -n 1
        )"
    elif [ -z "$PANBOTICON_SUBNET_ID" -a -z "$PANBOTICON_AZ" ]
    then
        PANBOTICON_SUBNET_ID="$(
            aws ec2 describe-subnets --filters \
                Name="map-public-ip-on-launch",Values="true" \
                Name="vpc-id",Values="$PANBOTICON_VPC_ID" |
            jq -e -r '.Subnets[].SubnetId' |
            sort -R |
            head -n 1
        )"
    fi
    if [ -z "$PANBOTICON_SUBNET_ID" ]
    then
        echo "PANBOTICON_SUBNET_ID must be set, either directly in the configuration file or environment, via PANBOTICON_AZ in the configuration file, environment, or -z option, or via random selection of a public subnet in PANBOTICON_VPC_ID." >&2
        exit 1
    fi
}

aws_duplicates_ok() {
    ERR="$(mktemp -p "$TMP")"
    if ! aws "$@" --cli-error-format "json" 2>"$ERR"
    then
        if ! jq -e -r '.Code' <"$ERR" | grep -F -q "Duplicate"
        then
            cat "$ERR" >&2
            false
        fi
    fi
}
