use strict;
use warnings;

use Module::Build qw( );

my $build = Module::Build->new(
   module_name => 'LWP::Protocol::AnyEvent::http',
   dist_author => 'Eric Brine <ikegami@adaelis.com>',
   license     => 'CC0_1_0',
   configure_requires => {
      'Module::Build' => 0,
   },
   build_requires => {
      'Test::More' => 0,
   },
   requires => {
      'AnyEvent'       => 0,
      'AnyEvent::HTTP' => 2.0,
      'HTTP::Response' => 0,
      'LWP::Protocol'  => 5.827, # earlier versions might work but
                                 # LWP::Simple will not always use LWP::Protocol
                                 # but use its own hand-rolled implementation
                                 # Also, chunked responses seem to get sent
                                 # properly only at this version or higher
      'version'        => 0,
   },
   add_to_cleanup => [ 'LWP-Protocol-AnyEvent-http-*' ],
);

$build->create_build_script();
