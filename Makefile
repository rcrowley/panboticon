export PANBOTICON_PREFIX = .
export PANBOTICON_BIN = bin
export PANBOTICON_LIB = lib/panboticon
export PANBOTICON_LIBEXEC = libexec/panboticon

prefix = /usr/local

all: lib/panboticon/availability-zones.txt

clean:

install:
	find ${PANBOTICON_BIN} ${PANBOTICON_LIB} ${PANBOTICON_LIBEXEC} -type d | xargs -I _ mkdir -p ${prefix}/_
	find ${PANBOTICON_BIN} ${PANBOTICON_LIB} ${PANBOTICON_LIBEXEC} -not -name \*.sw[opx] -type f | xargs -I _ cp _ ${prefix}/_

test:
	find test -name \*.sh -type f | xargs -n 1 -t sh

uninstall:
	find ${PANBOTICON_BIN} ${PANBOTICON_LIB} ${PANBOTICON_LIBEXEC} -not -name \*.sw[opx] -type f | xargs -I _ rm -f ${prefix}/_
	find ${PANBOTICON_BIN} ${PANBOTICON_LIB} ${PANBOTICON_LIBEXEC} -type d | xargs -I _ rmdir -p ${prefix}/_

.PHONY: all clean install test uninstall

lib/panboticon/availability-zones.txt:
	aws ec2 describe-regions | jq -e -r '.Regions[].RegionName' | xargs -n 1 aws ec2 describe-availability-zones --region | jq -e -r '.AvailabilityZones[] | "\(.RegionName) \(.ZoneName) \(.ZoneId)"' >$@
