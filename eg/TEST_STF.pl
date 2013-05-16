#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use Test::STF::MockServer;

$ENV{TEST_STF} ||= do {
    my $stf = Test::STF::MockServer->new();
    Harriet->save_guard($stf);
    $stf->url;
}
