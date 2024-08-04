#!/system/bin/sh
# shellcheck disable=SC2034

# Custom settings

# Set path environment for busybox
if ! command -v busybox >/dev/null 2>&1; then
  export PATH="/data/adb/magisk:/data/adb/ksu/bin:/data/adb/ap/bin:$PATH:/system/bin"
fi

# Take the current time
NOW=$(date +"%I:%M %P")

# Module configuration
MOD_DIR="/data/adb/modules/wol"
MOD_PROP="${MOD_DIR}/module.prop"

# Set wol basic configuration
WOL_DIR="/data/adb/wol"
WOL_BIN="${WOL_DIR}/bin/wol"
WOL_BIN_ARGS="--config=${WOL_DIR}/conf/wol.yml"
WOL_SCRIPTS_DIR="${WOL_DIR}/scripts"
WOL_RUN_DIR="${WOL_DIR}/run"
WOL_LOG_FILE="${WOL_RUN_DIR}/wol.log"
WOL_PID="${WOL_RUN_DIR}/wol.pid"
WOL_SERVICE="${WOL_SCRIPTS_DIR}/service.sh"
WOL_INOTIFY="${WOL_SCRIPTS_DIR}/inotify.sh"

# ANSI colours
ANSI_NORMAL="\033[0m"
ANSI_RED="\033[1;31m"
ANSI_GREEN="\033[1;32m"
ANSI_YELLOW="\033[1;33m"
ANSI_BLUE="\033[1;34m"

log() {
  # Selects the text color according to the parameters
  case $1 in
  info) color="${ANSI_BLUE}" ;;
  error) color="${ANSI_RED}" ;;
  warn) color="${ANSI_YELLOW}" ;;
  *) color="${ANSI_GREEN}" ;;
  esac
  # Add messages to time and parameters
  message="${NOW} [$1]: $2"
  if [ -t 1 ]; then
    # Prints messages to the console
    printf "%s%s%s" "${color}" "${message}" "${ANSI_NORMAL}"
  else
    # Print messages to a log file
    echo "${message}" >>"${WOL_LOG_FILE}" 2>&1
  fi
}
