#!/bin/sh

set -x

# Get the volume level
volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

# Check for mute state
if [[ "$volume" == *"[MUTED]" ]]; then
	text="Muted"
else
	text="Volume:"
fi

# Convert volume level to a percentage
volume=$(echo "$volume" | awk '{print $2}')
volume=$(echo "( $volume * 100 ) / 1" | bc)

# Send notification
notify-send -t 1000 -a 'wp-vol' -h "string:x-canonical-private-synchronous:volume" -h "int:value:${volume}" "${text} ${volume}%"
