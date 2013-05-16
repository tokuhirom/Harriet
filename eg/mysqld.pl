#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;

use Test::mysqld;

$ENV{TEST_MYSQL} ||= do {
    my $mysqld = Test::mysqld->new(
        my_cnf => {
            'skip-networking' => '', # no TCP socket
        }
    ) or die $Test::mysqld::errstr;
    $HARRIET_GUARDS::MYSQLD = $mysqld;
    $mysqld->dsn;
};

