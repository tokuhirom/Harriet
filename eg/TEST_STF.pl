#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use Test::STF::MockServer;

my $stf = Test::STF::MockServer->new();
return ($stf->url, $stf);
