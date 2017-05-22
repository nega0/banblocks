# banblocks
[![Build Status](https://travis-ci.org/nega0/banblocks.svg?branch=master)](https://travis-ci.org/nega0/banblocks)

`banblocks` is a small utillity that generates IPTables entries from a
list of IP address. It uses your system's `whois` command to find the
encompasing netblock for each IP, determines if that netblock is
currently banned, and assuming it is not, outputs an IPTables entry on
stdout. You then have to **manually** add that entry to your
firewall.

**`banblocks` does not automatically add entries to your firewall.**
You must do that yourself.

## Usage
Typical use is something like:
```
$ sudo iptables -nL > /tmp/tables
$ dmesg| grep ABL |cut -d= -f5 |cut -d\  -f1 |./banblocks -v -i eth0 -f /tmp/tables
Skipping xxx.xxx.xxx.xxx (already fits in a banned block)...
iptables -A TEMP_BLOCK -i eth0 -s yyy.yyy.0.0/12 -j DROP
iptables -A TEMP_BLOCK -i eth0 -s zzz.zzz.zzz.0/17 -j DROP
$ rm /tmp/tables
$ sudo iptables -A TEMP_BLOCK -i eth0 -s yyy.yyy.0.0/12 -j DROP
$
```

## Arguments

`banblocks` currently requires 2 arguments:
  + -i *interface*  - the network interface to use in iptables entry
  + -f file         - a file containing the current chain for the bans. Currently this chain is named "TEMP_BLOCK".

Additionally, two optional arguments are available
  + -h - a short help/usage statement
  + -v - add verbosity. Currently the outputs the "Skipping... " line in the above example.
