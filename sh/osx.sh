
# set window background from hex color
# usage: set_bg "#006600"
function set_bg {
  # get rgb
  local r=$(echo $1 | cut -c 2-3)
  local g=$(echo $1 | cut -c 4-5)
  local b=$(echo $1 | cut -c 6-7)

  # convert to decimal
  r=$(8bit_to_16bit $(hex2dec $r))
  g=$(8bit_to_16bit $(hex2dec $g))
  b=$(8bit_to_16bit $(hex2dec $b))

  osascript -e "tell application \"Terminal\" to set background color of window 1 to {$r, $g, $b}"
}

# set window background color from 16bit rgb
# usage: set_bg_16bit 13107 13107 13107
function set_bg_16bit {
  osascript -e "tell application \"Terminal\" to set background color of window 1 to {$1, $2, $3}"
}

function reset_bg {
  # "tungsten" colored pencil in terminal color pallet
  set_bg_16bit 13107 13107 13107
}

# convert hex number to decimal
function hex2dec {
  echo $((16#$1))
}

# convert 8bit decimal to 16bit
function 8bit_to_16bit {
  echo $(($1 * 256 + $1))
}
