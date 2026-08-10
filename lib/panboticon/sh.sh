set -e

sh_q() {
    _SH_Q_TMP="$(mktemp)"
    set +e
    "$@" >"$_SH_Q_TMP" 2>&1
    _SH_Q_STATUS="$?"
    set -e
    if [ "$_SH_Q_STATUS" -ne 0 ]
    then
        cat "$_SH_Q_TMP" >&2
        rm -f "$_SH_Q_TMP"
        return "$_SH_Q_STATUS"
    fi
    rm -f "$_SH_Q_TMP"
}
