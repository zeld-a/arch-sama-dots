#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '


# Visual
pyfiglet -s -f small_slant $(fastfetch -s os --format json | jq -r '.[0].result.name') && fastfetch -l none
eval "$(starship init bash)"

# Aliases & Exports
export PATH=$HOME/.local/bin:$PATH
export HYPRSHOT_DIR=~/Pictures
