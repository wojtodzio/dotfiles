# Native display settings by DDC using ddcctl tool
# https://github.com/kfix/ddcctl

alias first_monitor="ddcctl -d 2"
alias second_monitor="ddcctl -d 3"
both_monitors() {
  local brightness="$1"
  local contrast="$2"

  first_monitor -b $brightness -c $contrast
  second_monitor -b $brightness -c $contrast
}

alias monitors_normal_settings='both_monitors 15 60'
alias monitors_curtains='both_monitors 40 35'
alias monitors_higher_contrast='both_monitors 15 80'
alias monitors_higher_brightness='both_monitors 30 60'
alias monitors_equal='both_monitors 50 50'
