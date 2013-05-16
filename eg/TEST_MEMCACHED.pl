use strict;
use utf8;
use Test::TCP;

my $server = Test::TCP->new(
    code => sub {
        my $port = shift;
        exec '/usr/bin/memcached', '-p', $port;
        die $!;
    }
);
('127.0.0.1:' . $server->port, $server);
