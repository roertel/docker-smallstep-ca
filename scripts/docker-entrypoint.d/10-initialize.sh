#!/bin/bash
# vim:sw=4:ts=4:et:ai

set -e

ME=$(basename "$0")

initialize() {
    local -A parms

    # Pick some reasonable defaults for the minimum required arguments
    [ -z "${STEP_NAME:-}"        ] && parms[name]="${HOSTNAME}"
    [ -z "${STEP_DNS:-}"         ] && parms[dns]+="${HOSTNAME}"
    [ -z "${STEP_ADDRESS:-}"     ] && parms[address]+="localhost:9000"
    [ -z "${STEP_PROVISIONER:-}" ] && parms[provisioner]+="admin"

    # Load configuration from $CONFIGFILE, if defined
    if [ -e "${STEP_INIT_CONFIGFILE}" ]; then
        while IFS='=' read -r key value; do
            parms[$key]=$value
        done < "${STEP_INIT_CONFIGFILE}"

    # ...or from /step-config, if present
    elif [ -e "/step-config" ]; then
        while IFS='=' read -r key value; do
            parms[$key]=$value
        done < "${STEP_INIT_CONFIGFILE}"
    fi

    # Autogenerate password if asked
    if [ -n "${STEP_GENPASS:-}" ] || [ -f "${STEP_PASSWORD_FILE}"]; then
        if [ -z "${STEP_GENPASS:-}" ]; then
            echo >&3 "$ME: Password file not present or not defined."
        fi

        echo >&3 "$ME: Generating random password."
        mkdir -p $(dirname "${PWDPATH}")
        tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1 > "${PWDPATH}"
        parms[password-file]="${PWDPATH}"
    fi

    # overlay with step_ environment variables
    for VAR in $(set | grep "^STEP_"); do
        # Split into name & value
        IFS='=' read -ra temp <<< "$VAR"
        local name="${temp[0]}"

        name=${name:5}   # Strip STEP_ from the name
        name=${name//_/-} # Convert underscores to dashes
        name=${name,,}    # lowercase everything

        parms["${name}"]="${temp[1]}"
    done

    echo >&3 "$ME: Initializing Step CA..."

    # Assemble the command line from the associative array of parameters
    local cmdline=""
    for key in ${!parms[@]}; do
        # Add the parameter
        cmdline+=" --$key"

        # Add the value, if specified
        [ -n "${parms[$key]}" ] && cmdline+="=${parms[$key]}"
    done

    echo >&3 "$ME: Executing 'step ca init" "${cmdline}'"
    step ca init ${cmdline}
}

if [ ! -f "${CONFIGPATH:-}" ]; then
    initialize "$@"
    echo >&3 "$ME: Configuration complete; ready for start up."
else
    echo >&3 "$ME: No configuration necessary."
fi

exit 0
