#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Helper Functions
# Auto-persist hyprpaper wallpaper
setwall() {
    local WALL="$1"
    local CONF="$HOME/.config/hypr/hyprpaper.conf"

    # Check if the file exists
    if [[ ! -f "$WALL" ]]; then
        echo "Error: File '$WALL' does not exist."
        return 1
    fi

    # Preload and set wallpaper
    {
    hyprctl hyprpaper preload "$WALL" & wal -i "$WALL"
    hyprctl hyprpaper wallpaper ",$WALL" & ~/.config/waybar/scripts/launch.sh & ~/.config/zed/scripts/generate-theme.sh
    hyprctl hyprpaper unload unused
    } >/dev/null 2>&1
    
    # Update hyprpaper.conf to persist the wallpaper
    mkdir -p "$(dirname "$CONF")"
    cat > "$CONF" <<EOF
preload = $WALL
wallpaper = ,$WALL
EOF

    echo "Wallpaper set to $WALL"
}



# Visual
if [[ "$TERM_PROGRAM" != zed && -z "$ZED_TERM" ]]; then
	fastfetch
fi

eval "$(starship init bash)"

# Aliases & Exports
export PATH=$HOME/.local/bin:$PATH
export HYPRSHOT_DIR=~/Pictures
