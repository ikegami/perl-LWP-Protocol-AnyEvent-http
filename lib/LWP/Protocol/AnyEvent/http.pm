
package LWP::Protocol::AnyEvent::http;

use strict;
use warnings;

use version; our $VERSION = qv('v1.0.2');

use AnyEvent       qw( );
use AnyEvent::HTTP qw( http_request );
use HTTP::Response qw( );
use LWP::Protocol  qw( );

our @ISA = 'LWP::Protocol';

LWP::Protocol::implementor($_, __PACKAGE__) for qw( http https );


sub _set_response_headers {
   my ($response, $headers) = @_;

   my %headers = %$headers;

   $response->protocol( "HTTP/".delete($headers{ HTTPVersion }) )
      if $headers{ HTTPVersion };
   $response->code(             delete($headers{ Status      }) );
   $response->message(          delete($headers{ Reason      }) );

   # Uppercase headers are pseudo headers added by AnyEvent::HTTP.
   delete($headers{$_}) for grep /^[A-Z]/, keys(%headers);

   if (exists($headers->{'set-cookie'})) {
      # Set-Cookie headers are very non-standard.
      # They cannot be safely joined.
      # Try to undo their joining for HTTP::Cookies.
      $headers{'set-cookie'} = [
         split(/,(?=\s*\w+\s*(?:[=,;]|\z))/, $headers{'set-cookie'})
      ];
   }

   $response->push_header(%headers);
}


sub request {
   my ($self, $request, $proxy, $arg, $size, $timeout) = @_;

   #TODO Obey $proxy

   my $method  = $request->method();
   my $url     = $request->uri();
   my %headers;  $request->headers()->scan(sub { $headers{$_[0]} = $_[1]; });
   my $body    = $request->content_ref();

   # The status code will be replaced.
   my $response = HTTP::Response->new(599, 'Internal Server Error');
   $response->request($request);

   my $headers_avail = AnyEvent->condvar();
   my $data_avail    = AnyEvent->condvar();
   my @data_queue;

   my %handle_opts;
   $handle_opts{read_size}     = $size if defined($size);
   $handle_opts{max_read_size} = $size if defined($size);

   my %opts = ( handle_params => \%handle_opts );
   $opts{body}    = $$body   if defined($body);
   $opts{timeout} = $timeout if defined($timeout);

   # Let LWP handle redirects and cookies.
   my $guard = http_request(
      $method => $url,
      headers => \%headers,
      %opts,
      recurse => 0,
      on_header => sub {
         #my ($headers) = @_;
         _set_response_headers($response, $_[0]);
         $headers_avail->send();
         return 1;
      },
      on_body => sub {
         #my ($chunk, $headers) = @_;
         push @data_queue, \$_[0];
         $data_avail->send();
         return 1;
      },
      sub { # On completion
         # On successful completion: @_ = ('',     $headers)
         # On error:                 @_ = (undef,  $headers)

         # It is possible for the request to complete without
         # calling the header callback in the event of error.
         # It is also possible the Status to change as the
         # result of an error. This handles these events.
         _set_response_headers($response, $_[1]);
         $headers_avail->send();

         push @data_queue, \'';
         $data_avail->send();
      },
   );
   
   # We need to wait for the headers so the response code
   # is set up properly. LWP::Protocol decides on ->is_success
   # whether to call the :content_cb or not.
   $headers_avail->recv();

   return $self->collect($arg, $response, sub {
      if (!@data_queue) {
         # Wait for more data to arrive
         $data_avail->recv();
         
         # Re-prime our channel, in case there is more.
         $data_avail = AnyEvent->condvar();
      };
      
      return shift(@data_queue);
   });
}


1;


__END__

=head1 NAME

LWP::Protocol::AnyEvent::http - Event loop friendly HTTP and HTTPS backend for LWP


=head1 VERSION

Version 1.0.2


=head1 SYNOPSIS

    # Make HTTP and HTTPS requests friendly to event loops.
    use LWP::Protocol::AnyEvent::http;

    # Or LWP::Simple, WWW::Mechanize, etc
    use LWP::UserAgent;

    # A reason to want LWP friendly to event loops.
    use Coro qw( async );

    my $ua = LWP::UserAgent->new();
    $ua->protocols_allowed([qw( http https )]);  # Playing it safe.

    for my $url (@urls) {
        async { process( $ua->get($url) ) };
    }

=head1 DESCRIPTION

L<LWP> performs a number of blocking calls when trying
to process requests. This makes it unfriendly to event-driven
systems and cooperative multitasking system such as L<Coro>.

This module makes LWP more friendly to these systems
by plugging in an HTTP and HTTPS protocol implementor
powered by L<AnyEvent> and L<AnyEvent::HTTP>.

This module is known to work with L<Coro>. Please let
me (C<< <ikegami@adaelis.com> >>) know where else this
is of use so I can add tests and add a mention.

All LWP features and configuration options should still be
available when using this module.


=head1 SEE ALSO

=over 4

=item * L<Coro>

An excellent cooperative multitasking library assisted by this module.

=item * L<AnyEvent>, L<AnyEvent::HTTP>

Powers this module.

=item * L<LWP::Simple>, L<LWP::UserAgent>, L<WWW::Mechanize>

Affected by this module.

=item * L<Coro::LWP>

An alternative to this module for users of L<Coro>. Intrusive, which results
in problems in some unrelated code. Doesn't support HTTPS. Supports FTP and NTTP.

=item * L<AnyEvent::HTTP::LWP::UserAgent>

An alternative to this module. Doesn't help code that uses L<LWP::Simple> or L<LWP::UserAgent> directly.

=back


=head1 KNOWN BUGS

=head2 Ignores proxy settings

I haven't gotten around to implementing proxy support.


=head1 BUGS

Please report any bugs or feature requests to C<bug-LWP-Protocol-AnyEvent-http at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=LWP-Protocol-AnyEvent-http>.
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc LWP::Protocol::AnyEvent::http

You can also look for information at:

=over 4

=item * Search CPAN

L<http://search.cpan.org/dist/LWP-Protocol-AnyEvent-http>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=LWP-Protocol-AnyEvent-http>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/LWP-Protocol-AnyEvent-http>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/LWP-Protocol-AnyEvent-http>

=back


=head1 AUTHOR

Eric Brine, C<< <ikegami@adaelis.com> >>

Max Maischein, C<< <corion@cpan.org> >>


=head1 COPYRIGHT & LICENSE

No rights reserved.

The author has dedicated the work to the Commons by waiving all of his
or her rights to the work worldwide under copyright law and all related or
neighboring legal rights he or she had in the work, to the extent allowable by
law.

Works under CC0 do not require attribution. When citing the work, you should
not imply endorsement by the author.


=cut
