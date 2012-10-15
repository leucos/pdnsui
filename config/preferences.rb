module PDNSui
  URL="https://github.com/leucos/pdnsui/"
  VERSION=`git describe --always --tag`
  NOTIFY_COMMAND="pdns_control notify-host $domain $ns"
end

