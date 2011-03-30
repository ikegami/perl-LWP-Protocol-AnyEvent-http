#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

BEGIN { require_ok( 'LWP::Protocol::AnyEvent::http' ); }

diag( "Testing LWP::Protocol::AnyEvent::http $LWP::Protocol::AnyEvent::http::VERSION, Perl $]" );
diag "AnyEvent backend: " . AnyEvent::detect;
for (sort keys %INC) {
    s/\.pm$//;
    s!/!::!g;
    diag join " - ", $_, $_->VERSION || '<unknown>';
};
