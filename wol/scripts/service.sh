#!/system/bin/sh
# shellcheck disable=SC1091,SC3034,SC3046

source /data/adb/box/settings.sh

status() {
  pid=$(<"${WOL_PID}" 2>/dev/null)
  log info "wol service is running with PID: ${pid}."
  return 0
}

start() {
  if [ -n "$(busybox pidof "${WOL_BIN}")" ]; then
    return 0
  fi
  if [ ! -f "${WOL_BIN}" ]; then
    log error "No such file: ${WOL_BIN}."
    return 1
  fi
  # Backup wol log file
  if [ -f "${WOL_LOG_FILE}" ]; then
    mv -f "${WOL_LOG_FILE}" "${WOL_LOG_FILE}.bak"
    log info "Backup log file to ${WOL_LOG_FILE}.bak"
  fi
  # Running in backgroud
  nohup "${WOL_BIN}" "${WOL_BIN_ARGS}" >"${WOL_LOG_FILE}" 2>&1 &
  # Save the process ID to the pid file
  pid=$!
  echo ${pid} >"${WOL_PID}"
  sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[ ⏲ ${NOW} | ✔ wol service is running!!! ] /g" "${MOD_PROP}"
}

stop() {
  # Check if the binary is running using pgrep
  if busybox pgrep "${WOL_BIN}" >/dev/null; then
    # Use `busybox pkill` to kill the binary with signal 15, otherwise use `killall`.
    if busybox pkill -15 "${WOL_BIN}" >/dev/null 2>&1; then
      # Do nothing if busybox pkill is successful
      :
    else
      killall -15 "${WOL_BIN}" >/dev/null 2>&1 || kill -15 "$(busybox pidof "${WOL_BIN}")" >/dev/null 2>&1
    fi
  fi
  [ ! -f "${WOL_PID}" ] || rm -f "${WOL_PID}"
  sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[ ⏲ ${NOW} | ✘ wol shutting down, service is stopped!!! ] /g" "${MOD_PROP}"
}
