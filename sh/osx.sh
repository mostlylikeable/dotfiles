#!/bin/bash

alias bg_ocean_blue="set_bg \"#1B57FF\""
alias bg_light_salmon4="set_bg \"#8b5742\""

function l_colors() {
  echo "  -- bg colors --
  bg_ocean_blue
  bg_light_salmon4"
}

# set window background from hex color
# usage:
#   set_bg "#006600"
#   set_bg "006600"
#   set_bg # set to black
function set_bg() {
  local input_no_hash=$(echo $1 | sed 's/^#\(.*\)/\1/')

  _df_log "set_bg: $local_no_hash"

  # get rgb
  local r=$(echo $input_no_hash | cut -c 1-2)
  local g=$(echo $input_no_hash | cut -c 3-4)
  local b=$(echo $input_no_hash | cut -c 5-6)

  r=$(hex2dec $r)
  g=$(hex2dec $g)
  b=$(hex2dec $b)

  set_bg_rbg $r $g $b
}

function set_bg_rbg() {
  local r=$1
  local g=$2
  local b=$3

  echo "set background rgb ${1},${2},${3}"

  # convert to decimal
  r=$(8bit_to_16bit $r)
  g=$(8bit_to_16bit $g)
  b=$(8bit_to_16bit $b)

  osascript -e "tell application \"Terminal\" to set background color of window 1 to {$r, $g, $b}"
}

# set window background color from 16bit rgb
# usage: set_bg_16bit 13107 13107 13107
function set_bg_16bit() {
  osascript -e "tell application \"Terminal\" to set background color of window 1 to {$1, $2, $3}"
}

function reset_bg() {
  # "tungsten" colored pencil in terminal color pallet
  set_bg_16bit 13107 13107 13107
}

# convert hex number to decimal
function hex2dec() {
  # echo $((16#$1))
  echo $((0x$1))
}

# convert 8bit decimal to 16bit
function 8bit_to_16bit() {
  echo $(($1 * 256 + $1))
}
