#!/system/bin/sh
# This service later will moved to General Scripts for enabling and disabling
# wol service when default state is disabled.

# wait for boot to complete
while [ "$(getprop sys.boot_completed)" != 1 ]; do
  sleep 1
done

# ensure boot has actually completed & network is ready
sleep 5

# start service
/data/adb/wol/scripts/start.sh
