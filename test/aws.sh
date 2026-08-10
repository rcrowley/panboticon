set -e

. "$(dirname "$0")/test.sh"

(
    PANBOTICON_CONFIG="$(dirname "$0")/config.json"
    . "$PANBOTICON_LIB/configure.sh"
    . "$PANBOTICON_LIB/aws.sh"
    aws_vpc_subnet
    set -x
    test "$PANBOTICON_REGION" = "us-west-2"
    test "$PANBOTICON_AZ" = "usw2-az3"
    test "$PANBOTICON_VPC_ID" = "vpc-d2264baa"
    test "$PANBOTICON_SUBNET_ID" = "subnet-e270bebf"
)

set +e
(
    set -e
    PANBOTICON_CONFIG="$(dirname "$0")/config.json"
    PANBOTICON_REGION="us-east-1" # mismatch; error
    . "$PANBOTICON_LIB/configure.sh"
    . "$PANBOTICON_LIB/aws.sh"
    #aws_vpc_subnet
)
STATUS="$?"
set -e -x
test "$STATUS" -eq 1
set +x

(
    PANBOTICON_REGION="us-west-2" # let it choose randomly
    PANBOTICON_VPC_ID="vpc-d2264baa"
    PANBOTICON_INSTANCE_PROFILE="test"
    PANBOTICON_INSTANCE_TYPE="t4g.nano"
    . "$PANBOTICON_LIB/configure.sh"
    . "$PANBOTICON_LIB/aws.sh"
    aws_vpc_subnet
    set -x
    test "$PANBOTICON_REGION" = "us-west-2"
    test "$PANBOTICON_VPC_ID" = "vpc-d2264baa"
    test "$PANBOTICON_SUBNET_ID" = "subnet-1462233f" -o "$PANBOTICON_SUBNET_ID" = "subnet-197e8161" -o "$PANBOTICON_SUBNET_ID" = "subnet-360a127d" -o "$PANBOTICON_SUBNET_ID" = "subnet-e270bebf"
)
