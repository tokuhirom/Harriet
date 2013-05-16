package Harriet;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

# Storage for the guard objects.
our @GUARDS;

sub new {
    my ($class, $dir) = @_;
    bless {dir => $dir}, $class;
}

sub load {
    my ($self, $name) = @_;

    # Do not load $name.pl if the variable was already set.
    unless ($ENV{$name}) {
        my $file = "$self->{dir}/${name}.pl";

        my ($retval, @guards) = do $file;
        if ($@) {
            die "[Harriet] Couldn't parse $file: $@\n";
        }
        unless ($retval) {
            die "[Harriet] Cannot get value from $file.\n";
        }
        push @GUARDS, @guards;
        $ENV{$name} = $retval;
    }
    return $ENV{$name};
}

sub load_all {
    my ($self) = @_;

    my %result;

    opendir my $dh, $self->{dir}
        or die "[Harriet] Cannot open '$self->{dir}' as directory: $!\n";
    while (my $file = readdir($dh)) {
        next unless $file =~ /^(.*)\.pl$/;
        my $name = $1;
        my $val = $self->load($name);
        $result{$name} = $val;
    }
    return %result;
}

sub variables_as_string {
    my ($self, %vars) = @_;
    for my $key (sort keys %vars) {
        printf "export %s=%s\n", $key, $vars{$key};
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

Harriet - Daemon manager for testing

=head1 SYNOPSIS

    use Harriet;

    my $harriet = Harriet->new('t/harriet/');
    my $stf_url = $harriet->load('TEST_STF');

=head1 DESCRIPTION

In some case, test code requires daemons like memcached, STF, or groonga.
If you are running these daemons for each test scripts, it eats lots of time.

Then, you need to keep the processes under the test suite.

Harriet solves this issue.

Harriet loads all daemons when starting L<prove>. And set the daemon's end point to the environment variable.
And run the test cases. Test script can use the daemon process (You need to clear the data if you need.).

=head1 TUTORIAL

=head2 Writing harriet script

harriet script is just a perl script has C<.pl> extension. Example code is here:

    # t/harriet/TEST_MEMCACHED.pl
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
    return ('127.0.0.1:' . $server->port, $server);

This code runs memcached. It returns memcached's end point information and guard object. Harriet keeps guard objects while perl process lives.

(Guard object is optional.)

=head2 Load harriet script

    use Harriet;

    my $harriet = Harriet->new('t/harriet');
    my $memcached_endpoint = $harriet->load('TEST_MEMCACHED');

This script loads end point of memcached daemon. If there is C<$ENV{TEST_MEMCACHED}> varaible, just return it.
Otherwise, harriet loads harriet script named 't/harriet/TEST_MEMCACHED.pl' and it returns the return value of the script.

=head2 Save daemon process under the prove

    # .proverc
    -PHarriet=t/harriet/

L<App::Prove::Plugin::Harriet> loads harriet scripts under the C<t/harriet/>, and set these to environment variables.

This plugin starts daemons before running test cases!

=head1 LICENSE

Copyright (C) tokuhirom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokuhirom E<lt>tokuhirom@gmail.comE<gt>

=cut

