use strict;
use warnings;

use Module::Build qw( );

my $build = Module::Build->new(
   module_name => 'LWP::Protocol::Coro::http',
   dist_author => 'Eric Brine <ikegami@adaelis.com>',
   license     => 'CC0_1_0',
   configure_requires => {
      'Module::Build' => 0,
   },
   build_requires => {
      'Test::More' => 0,
   },
   requires => {
      'AnyEvent::HTTP' => 2.0,
      'Coro::Channel'  => 0,
      'HTTP::Response' => 0,
      'LWP::Protocol'  => 0,
      'version'        => 0,
   },
   add_to_cleanup => [ 'LWP-Protocol-Coro-http-*' ],
);

$build->create_build_script();
