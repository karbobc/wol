#!/system/bin/sh
# shellcheck disable=SC2034

SKIPUNZIP=1

WOL_DIR="/data/adb/wol"
WOL_BIN_DIR="$WOL_DIR/bin"
WOL_CONF_DIR="$WOL_DIR/conf"
WOL_SCRIPTS_DIR="$WOL_DIR/scripts"

if [ "$BOOTMODE" != true ]; then
  abort "-----------------------------------------------------------"
  ui_print "! Please install in Magisk/KernelSU/APatch Manager"
  ui_print "! Install from recovery is NOT supported"
  abort "-----------------------------------------------------------"
elif [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10670 ]; then
  abort "-----------------------------------------------------------"
  ui_print "! Please update your KernelSU and KernelSU Manager"
  abort "-----------------------------------------------------------"
fi

service_dir="/data/adb/service.d"
if [ "$KSU" = "true" ]; then
  ui_print "- kernelSU version: $KSU_VER ($KSU_VER_CODE)"
  [ "$KSU_VER_CODE" -lt 10683 ] && service_dir="/data/adb/ksu/service.d"
elif [ "$APATCH" = "true" ]; then
  APATCH_VER=$(cat "/data/adb/ap/version")
  ui_print "- APatch version: $APATCH_VER"
else
  ui_print "- Magisk version: $MAGISK_VER ($MAGISK_VER_CODE)"
fi

case $ARCH in
arm64) WOL_ARCH="arm64" ;;
x64) WOL_ARCH="x86_64" ;;
*)
  ui_print "Unsupported architecture: $ARCH"
  abort
  ;;
esac
ui_print "- Detected architecture: $WOL_ARCH"

ui_print "- Extracting module files"
unzip -qqo "$ZIPFILE" -x "META-INF/*" "wol/*" -d "$MODPATH"

if [ -d "$WOL_DIR" ]; then
  ui_print "- Cleaning up old files"
  rm -rf "$WOL_DIR"
fi

ui_print "- Creating directories"
mkdir -p "$service_dir" "$WOL_DIR" "$WOL_BIN_DIR" "$WOL_CONF_DIR" "$WOL_SCRIPTS_DIR"

ui_print "- Extracting scripts"
unzip -qqjo "$ZIPFILE" "wol/settings.sh" -d "$WOL_DIR"
unzip -qqjo "$ZIPFILE" "wol/bin/*" -d "$WOL_BIN_DIR"
unzip -qqjo "$ZIPFILE" "wol/conf/*" -d "$WOL_CONF_DIR"
unzip -qqjo "$ZIPFILE" "wol/scripts/*" -d "$WOL_SCRIPTS_DIR"

ui_print "- Setting permissions"
set_perm_recursive ${WOL_BIN_DIR} 0 0 0755 0755
set_perm_recursive ${WOL_SCRIPTS_DIR} 0 0 0755 0755
set_perm "${MODPATH}/service.sh" 0 0 0755
set_perm "${MODPATH}/uninstall.sh" 0 0 0755

if [ ! -f "${service_dir}/wol_service.sh" ]; then
  # Offer to move module scripts to general scripts.
  ui_print "-----------------------------------------------------------"
  ui_print "- Do you want to move Module Scripts to General Scripts ?"
  ui_print "- This option allows you to toggle the 'tailscaled' service"
  ui_print "  on or off by enabling or disabling modules."
  ui_print "- Your service directory is :"
  ui_print "  '${service_dir}'."
  ui_print "- Because the Developer Guides mentioned:"
  ui_print "  Modules should NOT add general scripts during installation."
  ui_print "- I offer this option to you."
  ui_print "- You have 10 seconds to make a selection. Default is [Yes]."
  ui_print "- [ Vol UP(+): Yes ]"
  ui_print "- [ Vol DOWN(-): No ]"
  start_time=$(date +%s)
  while true; do
    current_time=$(date +%s)
    time_delta=$((current_time - start_time))
    if [ ${time_delta} -ge 10 ]; then
      ui_print "- Time's up! Proceeding with default option [Yes]."
      ui_print "- Move Module Scripts to General Scripts."
      mv -f "${MODPATH}/service.sh" "${service_dir}/wol_service.sh"
      break
    fi
    getevent -lc 1 2>&1 | grep KEY_VOLUME >"${TMPDIR}/events"
    if <"${TMPDIR}/events" grep -q KEY_VOLUMEUP; then
      ui_print "- [Yes] Move Module Scripts to General Scripts."
      mv -f "${MODPATH}/service.sh" "${service_dir}/wol_service.sh"
      break
    elif <"${TMPDIR}/events" grep -q KEY_VOLUMEDOWN; then
      ui_print "- [No] Skip and keep using Module Scripts."
      break
    fi
  done
else
  ui_print "- Move General Scripts."
  mv -f "${MODPATH}/service.sh" "${service_dir}/wol_service.sh"
fi

ui_print "- Installation is complete, reboot your device."
