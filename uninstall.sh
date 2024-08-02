#!/system/bin/sh

SERVICE_FILE="/data/adb/service.d/wol_service.sh"
KSU_SERVICE_DIR="/data/adb/ksu/service.d/wol_service.sh"
[ ! -f "$SERVICE_FILE" ] || rm -f "$SERVICE_FILE"
[ ! -f "$KSU_SERVICE_DIR" ] || rm -f "$KSU_SERVICE_DIR"
[ ! -d "/data/adb/wol" ] || rm -rf /data/adb/wol
