#!/usr/bin/env perl
# -*- mode: cperl -*-

use Test::More;
use File::Temp qw/tempfile/;
#use Smart::Comments;
use feature qw(say);
use warnings;
use strict;

## #

subtest 'load program' => sub {
  require_ok( './banblocks' );
};

subtest 'test innards' => sub {
  ok( defined &run, '&run subroutine is defined' );
  ok( defined &already_banned, '&already_banned is defined' );
  ok( defined &get_block, '&get_block is defined' );
  ok( defined &init_ban_blocks, '&init_ban_blocks is defined' );
  ok( defined &trim, '&trim is defined' );
};

subtest 'testing &init_ban_blocks' => sub {
  my $c = << 'HERE';
Chain TEMP_BLOCK (1 references)
target     prot opt source               destination
DROP       all  --  180.212.0.0/15       0.0.0.0/0
HERE
  my ($fh, $file) = tempfile();
  print $fh $c;
  ok(init_ban_blocks($file), 'initialize banned blocks');
  close $fh;
};

subtest 'testing &already_banned' => sub {
  our $ar;
  $ar = ();
  push @{$ar}, ('180.212.0.0/15');
  ### ar: $ar
  ok(already_banned('180.212.198.171'), 'already banned');
};

subtest 'testing &get_block' => sub {
  my $whois = undef;
  foreach my $w (split /:/, $ENV{'PATH'}) {
    next unless (-X "$w/whois");
    $whois="$w/whois";
    last;
  }
  if($whois) {
    ok(get_block('180.212.198.171'), 'do whois');
  }
};

subtest 'testing &trim' => sub {
  is(trim(' a'),  'a', "whitespace at beginning of string");
  is(trim('a '),  'a', "           at end of string");
  is(trim(' a '), 'a', "           at both");
};

done_testing();
