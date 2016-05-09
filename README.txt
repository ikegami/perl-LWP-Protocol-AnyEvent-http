LWP-Protocol-AnyEvent-http

LWP performs a number of blocking calls when trying
to process requests. This makes it unfriendly to event-driven
systems and cooperative multitasking system such as Coro.

This module makes LWP more friendly to these systems
by plugging in an HTTP and HTTPS protocol implementor
powered by AnyEvent and AnyEvent::HTTP.

In short, it allows AnyEvent callbacks and Coro threads
to execute when LWP is blocked. (Please let me know
at <ikegami@adaelis.com> what other system this helps
so I can add tests and add a mention.)

All LWP features and configuration options should still be
available when using this module.


INSTALLATION

To install this module, run the following commands:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install


DEPENDENCIES

This module requires these other modules and libraries:

    Module::Build    (For installation only)
    Test::More       (For testing only)
    AnyEvent
    AnyEvent::HTTP
    HTTP::Response
    LWP::Protocol
    version


SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
perldoc command.

    perldoc LWP::Protocol::AnyEvent::http

You can also look for information at:

    RT, CPAN's request tracker
        http://rt.cpan.org/NoAuth/Bugs.html?Dist=LWP-Protocol-AnyEvent-http

    AnnoCPAN, Annotated CPAN documentation
        http://annocpan.org/dist/LWP-Protocol-AnyEvent-http

    CPAN Ratings
        http://cpanratings.perl.org/d/LWP-Protocol-AnyEvent-http

    Search CPAN
        http://search.cpan.org/dist/LWP-Protocol-AnyEvent-http


COPYRIGHT AND LICENCE

No rights reserved.

The author has dedicated the work to the Commons by waiving all of his
or her rights to the work worldwide under copyright law and all related or
neighboring legal rights he or she had in the work, to the extent allowable by
law.

Works under CC0 do not require attribution. When citing the work, you should
not imply endorsement by the author.
