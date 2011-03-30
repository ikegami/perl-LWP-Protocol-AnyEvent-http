#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

BEGIN { require_ok( 'LWP::Protocol::Coro::http' ); }

diag( "Testing LWP::Protocol::Coro::http $LWP::Protocol::Coro::http::VERSION, Perl $]" );
