#!/bin/sh
# vim:sw=4:ts=4:et:ai

set -e

if [ -z "${QUIET:-}" ]; then
    exec 3>&1
else
    exec 3>/dev/null
fi

if [ "$1" = "step-ca" ]; then
    if /usr/bin/find "/docker-entrypoint.d/" -mindepth 1 -maxdepth 1 -type f \
        -print -quit 2>/dev/null | read v; then

        echo >&3 "$0: performing initialization"

        echo >&3 "$0: Looking for scripts"
        find "/docker-entrypoint.d/" -follow -type f -print | sort -n \
            | while read -r f; do

            case "$f" in
                *.sh)
                    if [ -x "$f" ]; then
                        echo >&3 "$0: Launching $f";
                        "$f"
                    else
                        # warn on shell scripts without exec bit
                        echo >&3 "$0: Ignoring $f, not executable";
                    fi
                    ;;
                *) echo >&3 "$0: Ignoring $f";;
            esac
        done

        echo >&3 "$0: Configuration complete; ready for start up"
    else
        echo >&3 "$0: No initialization files found; skipping configuration"
    fi
fi

echo >&3 "$0: Starting CA"
eval exec "$@"
