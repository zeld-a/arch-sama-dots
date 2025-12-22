#!/bin/bash

WAL_COLORS="${HOME}/.cache/wal/colors.json"
TEMPLATE="${HOME}/.config/zed/templates/default.json.template"
ZED_THEMES_DIR="${HOME}/.config/zed/themes"
THEME_FILE="$ZED_THEMES_DIR/custom-theme.json"

# Abort if missing colors.json
if [[ ! -f "${WAL_COLORS}" ]]; then
    echo "error: wal colourscheme file not found at ${WAL_COLORS}"
    exit 1
fi

# Abort if missing template
if [[ ! -f "${TEMPLATE}" ]]; then
    echo "error: template file not found at ${TEMPLATE}"
    exit 1
fi

# Theme directory check
mkdir -p "${ZED_THEMES_DIR}"

# Extract wal colors into environment variables
eval "$(jq -r '
  .special as $special |
  .colors as $colors |
  "export background=\($special.background)
   export foreground=\($special.foreground)
   export cursor=\($special.cursor)
   export color0=\($colors.color0)
   export color1=\($colors.color1)
   export color2=\($colors.color2)
   export color3=\($colors.color3)
   export color4=\($colors.color4)
   export color5=\($colors.color5)
   export color6=\($colors.color6)
   export color7=\($colors.color7)
   export color8=\($colors.color8)
   export color9=\($colors.color9)
   export color10=\($colors.color10)
   export color11=\($colors.color11)
   export color12=\($colors.color12)
   export color13=\($colors.color13)
   export color14=\($colors.color14)
   export color15=\($colors.color15)"
  ' "${WAL_COLORS}")"

export schema='$schema'
  
# Generate theme
envsubst < "${TEMPLATE}" > "${THEME_FILE}"