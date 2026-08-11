set -e

. "$(dirname "$0")/test.sh"

TMP="$(mktemp -d)"
trap "rm -f -r \"$TMP\"" EXIT

. "$PANBOTICON_LIB/sh.sh"

(
    STATUS="$(
        sh_q sh -c 'echo "hi"; true' >"$TMP/hi-true.stdout" 2>"$TMP/hi-true.stderr" &&
        echo 0 ||
        echo 1
    )"
    set -x
    test "$STATUS" -eq 0
    diff -u "$TMP/hi-true.stdout" - <<EOF
EOF
    diff -u "$TMP/hi-true.stderr" - <<EOF
EOF
)

(
    STATUS="$(
        sh_q sh -c 'echo "hi"; false' >"$TMP/hi-false.stdout" 2>"$TMP/hi-false.stderr" &&
        echo 0 ||
        echo 1
    )"
    set -x
    test "$STATUS" -eq 1
    diff -u "$TMP/hi-false.stdout" - <<EOF
EOF
    diff -u "$TMP/hi-false.stderr" - <<EOF

hi
EOF
)
