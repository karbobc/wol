#!/system/bin/sh
# shellcheck disable=SC1091,SC2034,SC3046

source /data/adb/wol/settings.sh

events="$1"
monitor_dir="$2"
monitor_file="$3"

service_control() {
  if [ "${monitor_file}" = "disable" ]; then
    if [ "${events}" = "d" ]; then
      "${WOL_SERVICE}" start >"${WOL_LOG_FILE}" 2>&1
    elif [ "${events}" = "n" ]; then
      "${WOL_SERVICE}" stop >>"${WOL_LOG_FILE}" 2>&1
    fi
  fi
}

service_control
