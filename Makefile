export PANBOTICON_PREFIX = .
export PANBOTICON_BIN = bin
export PANBOTICON_LIB = lib/panboticon
export PANBOTICON_LIBEXEC = libexec/panboticon

all:

clean:

install:

test:
	find test -name \*.sh -type f | xargs -n 1 -t sh

.PHONY: all clean install test

lib/panboticon/availability-zones.txt:
	aws ec2 describe-regions | jq -e -r '.Regions[].RegionName' | xargs -n 1 aws ec2 describe-availability-zones --region | jq -e -r '.AvailabilityZones[] | "\(.RegionName) \(.ZoneName) \(.ZoneId)"' >$@
