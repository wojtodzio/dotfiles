# Start / Stop VPN EC2 server instance
vpn_server() {
  case "$1" in
    status) local command="describe-instance-status" ;;
    start)  local command="start-instances" ;;
    stop)   local command="stop-instances" ;;
    *)      echo "Bad command; usage: vpn_server start / stop / status"; return 1 ;;
  esac

  aws ec2 "$command" --instance-ids "$VPN_INSTANCE_ID" --region "$VPN_INSTANCE_REGION"
}

# Connect / disconnect with VPN server
vpn_connection() {
  # connect_to_vpn and disconnect_vpn are executables located in ~/bin
  case "$1" in
    start)  connect_to_vpn ;;
    stop)   disconnect_vpn ;;
    *)      echo "Bad command; usage: vpn_connection start / stop"; return 1 ;;
  esac
}

# Start VPN server and connect to it / Stop VPN server and disconnect
vpn() {
  case "$1" in
    start)  vpn_server start    && vpn_connect_till_up ;;
    stop)   vpn_connection stop && vpn_server stop ;;
    *)      echo "Bad command; usage: vpn start / stop"; return 1 ;;
  esac
}

vpn_server_down() {
  inline_global_ruby <<'END'
    ruby -r json -e "puts JSON.parse('$(vpn_server status)')['InstanceStatuses'].empty?"
END
}

vpn_connect_till_up() {
  # Wait for EC2 to change state
  while [ "$(vpn_server_down)" = true ]; do
    sleep 0.5
  done
  # Give server a few seconds to initialize (cheap servers takes some time to start)
  sleep 8
  vpn_connection start
}
