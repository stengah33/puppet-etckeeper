(* Test for etckeeperconf lens *)
module Test_etckeeperconf =

  let eth_static = "# Intel Corporation PRO/100 VE Network Connection
DEVICE=eth0
BOOTPROTO=static
BROADCAST=172.31.0.255
HWADDR=ab:cd:ef:12:34:56
export IPADDR=172.31.0.31
#DHCP_HOSTNAME=host.example.com
NETMASK=255.255.255.0
NETWORK=172.31.0.0
unset ONBOOT
"
  let empty_val = "EMPTY=\nDEVICE=eth0\n"

  let key_brack = "SOME_KEY[1]=\nDEVICE=eth0\n"

  test Etckeeperconf.lns get eth_static =
    { "#comment" = "Intel Corporation PRO/100 VE Network Connection" }
    { "DEVICE" = "eth0" }
    { "BOOTPROTO" = "static" }
    { "BROADCAST" = "172.31.0.255" }
    { "HWADDR" = "ab:cd:ef:12:34:56" }
    { "IPADDR" = "172.31.0.31"
        { "export" } }
    { "#comment" = "DHCP_HOSTNAME=host.example.com" }
    { "NETMASK" = "255.255.255.0" }
    { "NETWORK" = "172.31.0.0" }
    { "@unset"   = "ONBOOT" }

  test Etckeeperconf.lns put eth_static after
      set "BOOTPROTO" "dhcp" ;
      rm "IPADDR" ;
      rm "BROADCAST" ;
      rm "NETMASK" ;
      rm "NETWORK"
  = "# Intel Corporation PRO/100 VE Network Connection
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=ab:cd:ef:12:34:56
#DHCP_HOSTNAME=host.example.com
unset ONBOOT
"
  test Etckeeperconf.lns get empty_val =
    { "EMPTY" = "" } { "DEVICE" = "eth0" }

  test Etckeeperconf.lns get key_brack =
    { "SOME_KEY[1]" = "" } { "DEVICE" = "eth0" }

  test Etckeeperconf.lns get "smartd_opts=\"-q never\"\n" =
    { "smartd_opts" = "-q never" }

  test Etckeeperconf.lns get "var=val  \n" = { "var" = "val" }

  test Etckeeperconf.lns get ". /etc/java/java.conf\n" =
    { ".source" = "/etc/java/java.conf" }

  (* Quoted strings and other oddities *)
  test Etckeeperconf.lns get "var=\"foo 'bar'\"\n" =
    { "var" = "foo 'bar'" }

  test Etckeeperconf.lns get "var=\"eth0\"\n" =
    { "var" = "eth0" }

  test Etckeeperconf.lns get "var='eth0'\n" =
    { "var" = "eth0" }

  test Etckeeperconf.lns get "var='Some \"funny\" value'\n" =
    { "var" = "Some \"funny\" value" }

  test Etckeeperconf.lns get "var=\"\\\"\"\n" =
    { "var" = "\\\"" }

  test Etckeeperconf.lns get "var=\\\"\n" =
    { "var" = "\\\"" }

  test Etckeeperconf.lns get "var=ab#c\n" =
    { "var" = "ab#c" }

  (* We don't handle backticks *)
  test Etckeeperconf.lns get
      "var=`grep nameserver /etc/resolv.conf | head -1`\n" = *

  (* We don't handle comments at the end of a line yet *)
  test Etckeeperconf.lns get "var=ab #c\n" = *

  (* Bug 109: allow a bare export *)
  test Etckeeperconf.lns get "export FOO\n" =
  { "@export" = "FOO" }

  (* Check we put quotes in when changes require them *)
  test Etckeeperconf.lns put "var=\"v\"\n" after rm "/foo" =
    "var=\"v\"\n"

  test Etckeeperconf.lns put "var=v\n" after set "/var" "v w"=
    "var=\"v w\"\n"

  test Etckeeperconf.lns put "var='v'\n" after set "/var" "v w"=
    "var='v w'\n"

  test Etckeeperconf.lns put "var=v\n" after set "/var" "v'w"=
    "var=\"v'w\"\n"

  test Etckeeperconf.lns put "var=v\n" after set "/var" "v\"w"=
    "var='v\"w'\n"

(* Local Variables: *)
(* mode: caml       *)
(* End:             *)
