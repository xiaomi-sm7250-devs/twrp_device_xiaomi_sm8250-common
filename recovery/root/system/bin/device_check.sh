#!/sbin/sh

# The below variables shouldn't need to be changed
# unless you want to call the script something else
SCRIPTNAME="Device_Check"
LOGFILE=/tmp/recovery.log

# Set default log level
# 0 Errors only
# 1 Errors and Information
# 2 Errors, Information, and Debugging
__VERBOSE=1

# Exit codes:
# 0 Success
# 1 hardware value not found in boot header

# Function for logging to the recovery log
log_print()
{
	# 0 = Error; 1 = Information; 2 = Debugging
	case $1 in
		0)
			LOG_LEVEL="E"
			;;
		1)
			LOG_LEVEL="I"
			;;
		2)
			LOG_LEVEL="DEBUG"
			;;
		*)
			LOG_LEVEL="UNKNOWN"
			;;
	esac
	if [ $__VERBOSE -ge "$1" ]; then
		echo "$LOG_LEVEL:$SCRIPTNAME::$2" >> "$LOGFILE"
	fi
}

# remove_line <file> <line match string>
remove_line() {
  if grep -q "$2" $1; then
    local line=$(grep -n "$2" $1 | head -n1 | cut -d: -f1);
    sed -i "${line}d" $1;
  fi;
}

finish()
{
	log_print 2 "Script complete. Continuing TWRP boot."
	exit 0
}

# Variables
device=$(getprop ro.product.device)
fstab="/etc/twrp.flags"

log_print 2 "Running $SCRIPTNAME script for TWRP..."
log_print 2 "ro.product.device=$device"

# TODO: Adapt for xiaomi sm8250
exit 0

if [ "$device" = "I002D" ]; then
	log_print 2 "ZenFone 7/7 Pro detected. Removing ASUS Firmware support from twrp.flags..."
	remove_line $fstab "/asusfw"
	finish
elif [ "$device" = "I003D" ]; then
	log_print 2 "ROG Phone 3 detected. Removing SD Card support from twrp.flags..."
	remove_line $fstab "/external_sd"
	finish
else
	log_print 0 "Unknown Device. Exiting script."
	exit 1
fi
