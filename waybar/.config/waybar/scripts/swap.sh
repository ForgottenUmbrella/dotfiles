#!/bin/sh
# Output amount of swap used as JSON.

math_free=$(free | grep '^Swap')
text_free=$(free -h | grep '^Swap')

used=$(echo "$math_free" | awk '{print $3}')
text_used=$(echo "$text_free" | awk '{print $3}')

total=$(echo "$math_free" | awk '{print $2}')
text_total=$(echo "$text_free" | awk '{print $2}')

percentage=$(echo "scale=2; $used/$total * 100" | bc)
text_percentage="$text_used/$text_total"

text="$text_used"
alt="$text_percentage"
tooltip="$text_used of swap used out of $text_total"
if [ "$(echo "$percentage > 50" | bc)" = 1 ]
then
    class='alert'
else
    class='fg'
fi

printf '{"text": "%s", "alt": "%s", "tooltip": "%s", "class": "%s", "percentage": %s}' \
       "$text" "$alt" "$tooltip" "$class" "$percentage"
