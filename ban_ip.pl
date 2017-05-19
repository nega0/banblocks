#!/usr/bin/perl -w -- -*- mode: cperl -*-

package Local::Modulino;

__PACKAGE__->run() unless caller();

use Smart::Comments;
use Net::CIDR;
use Getopt::Std;
use IPTables::Parse;
use warnings;
use strict;

our $ar;  ## FIXME: global variable

## Process cmdline options
sub run {
  $main::VERSION = '0.9';
  $Getopt::Std::STANDARD_HELP_VERSION = 1;
  our ($opt_f, $opt_i, $opt_v, $opt_h);

  sub main::HELP_MESSAGE {
    my $fh = shift;
    my $hd =  << "HERE";
Usage: $0 -i <interface> -f <rules file>

The following single-character options are accepted:
	-f <rules file>		A file containing the current iptables rules
	-i <interface>		Interface name to write the rules for
	-v			Verbose. Show IPs that get skipped because
				they're already banned.

HERE
    if ($fh) {
      print $fh $hd;
    } else {
      print STDOUT $hd;
    }
  };

  getopts('h:f:i:v');
  if (!defined($opt_h) or ($opt_h eq 'elp')) {
    main::HELP_MESSAGE();
  }
  die "[*] -i is a required option.\n[*] I need to know what interface to write rules for,"
    unless $opt_i;
  die "[*] -f is a required option.\n[*] I need to read existing rules from a file,"
    unless $opt_f;

  ## let's get to work
  $ar = init_ban_blocks($opt_f);
  ### $ar: ref($ar)
  ### $ar

  my $new_bans = [];
  while (<>) {
    chomp;
    next if(!$_);
    my $ip = $_;
    if (already_banned($ip)) {
      print "Skipping $ip (already fits in a banned block)...\n" if $opt_v;
      next;
    }

    my $block = get_block($ip);
    ### $block
    if (not $block) {
      warn "Errors fetching whois info for $ip: $!";
      next;
    }

    push @{$ar}, $block;
    push @{$new_bans},   $block;
  }

  foreach my $b (@{$new_bans}) {
    #printf "iptables -A TEMP_BLOCK -i $if -s $r -j DROP -m comment --comment '$d'\n";
    printf "iptables -A TEMP_BLOCK -i $opt_i -s $b -j DROP\n";
  }

}                               ## sub run

sub get_block {
  my $ip = shift;
  ### fetching whois for $ip...
  my @w = grep {/^inetnum|NetRange|\[Network Number\]|^IPv4 Address|^descr/} `whois $ip 2>/dev/null`;
  chomp @w;
  ### @w: @w
  if ($#w+1) {
    my ($e, $r) = split /:|[]]/x, shift @w;
    if ($r =~ /[)]/x) { ## KRNIC adds f.e. (/11) to the end of its ^IPv4 lines
      $r =~ s/\s+\S*$//x;
    }
    ### $r: $r
    return Net::CIDR::cidrvalidate(Net::CIDR::range2cidr(trim($r)));
  }
  return;
}

sub trim {
  return $_[0] =~ s/^\s+|\s+$//rgx;
}

sub already_banned {
  ### $_: $_
  my $ip = Net::CIDR::cidrvalidate(shift);
  ### $ip: $ip
  ### @{$ar}: @{$ar}
  die "[*] Not a valid $ip: $!" unless $ip;
  return Net::CIDR::cidrlookup($ip, @{$ar}) ? 1 : 0;
}

sub init_ban_blocks {
  my $file = shift;
  ### $file: $file

  my $ipt_obj = new IPTables::Parse()
    or die '[*] Could not acquire IPTables::Parse object';

  my $table = 'filter';
  my $chain = 'TEMP_BLOCK';

  my ($ipt_hr, $rv) = $ipt_obj->chain_rules($table, $chain, $file);
  ### $ipt_hr: ref($ipt_hr)
  ### $rv
  my $ban_blocks = [];
  foreach my $i (@{$ipt_hr}) {
    push @{$ban_blocks}, Net::CIDR::cidrvalidate($i->{src}) if $i->{src};
  }

  ### $ban_blocks
  if (@{$ban_blocks}) {
    ### returning \$ban_blocks...
    return $ban_blocks;
  }
  ### returning void...
  return;
}
