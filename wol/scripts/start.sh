#!/system/bin/sh
# shellcheck disable=SC1091,SC2207,SC3030,SC3046,SC3054

source /data/adb/wol/settings.sh

start_service() {
  if [ ! -f "${MOD_DIR}/disable" ]; then
    "${WOL_SCRIPTS_DIR}/service.sh" start >>/dev/null 2>&1
  fi
}

start_inotifyd() {
  pids=($(busybox pidof inotifyd))
  for pid in "${pids[@]}"; do
    if grep -q "box.inotify" "/proc/${pid}/cmdline"; then
      kill -9 "${pid}"
    fi
  done
  inotifyd "${WOL_SCRIPTS_DIR}/inotify.sh" "${MOD_DIR}" >>/dev/null 2>&1 &
}

mkdir -p "${WOL_RUN_DIR}"
start_service
start_inotifyd
