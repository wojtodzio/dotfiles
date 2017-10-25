# Network related

alias external_ip='dig +short myip.opendns.com @resolver1.opendns.com'
alias internal_ip='ipconfig getifaddr en0'

alias ping8='ping 8.8.8.8'

## Get saved password of WIFI which you have connected to in the past
wifi_password () {
  local ssid="$1"

  security find-generic-password -D "AirPort network password" -a "$ssid" -gw
}
wifi_join() {
  local ssid="$1"
  local password="$2"

  networksetup -setairportnetwork en0 "$ssid" "$password"
}
alias wifi_history='defaults read /Library/Preferences/SystemConfiguration/com.apple.airport.preferences | grep LastConnected -A 7'
alias current_wifi_ssid='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I \
                          | sed -e "s/^  *SSID: //p" -e d'
alias wifi_scan='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s'
