use 5.008001;
use strictures;

package Test::Roo::Role;
# ABSTRACT: Composable role for Test::Roo
our $VERSION = '0.002'; # VERSION

use Test::Roo (); # no imports!

sub import {
    my ( $class, @args ) = @_;
    my $caller = caller;
    {
        no strict 'refs';
        *{ $caller . "::test" } = *Test::Roo::test;
    }
    strictures->import; # do this for Moo, since we load Moo in eval
    eval qq{ package $caller; use Test::More; use Moo::Role };
    die $@ if $@;
}

1;


# vim: ts=4 sts=4 sw=4 et:

__END__

=pod

=head1 NAME

Test::Roo::Role - Composable role for Test::Roo

=head1 VERSION

version 0.002

=head1 SYNOPSIS

A testing role:

    # t/lib/MyTestRole.pm
    package MyTestRole;
    use Test::Roo::Role; # loads Moo::Role and Test::More

    requires 'class';

    test 'object creation' => sub {
        my $self = shift;
        require_ok( $self->class );
        my $obj  = new_ok( $self->class );
    };

    1;

=head1 DESCRIPTION

This module defines test behaviors as a L<Moo::Role>.

=for Pod::Coverage method_names_here

=head1 USAGE

Importing L<Test::Roo::Role> also loads L<Moo::Role> (which gives you L<strictures> with
fatal warnings and other goodies) and L<Test::More>.

If you have to call C<plan skip_all>, do it in the main body of your code, not
in a test or modifier.

=head2 Creating and requiring fixtures

You can create fixtures with normal Moo syntax.  You can even make them lazy
if you want and require the composing class to provide the builder:

    has fixture => (
        is => 'lazy'
    );

    requires '_build_fixture';

Because this is a L<Moo::Role>, you can require any method you like, not
just builders.

See L<Moo::Role> and L<Role::Tiny> for everything you can do with roles.

=head2 Setup and teardown

You can add method modifiers around the C<setup> and C<teardown> methods
and these will be run before and after all tests (respectively).

    before  setup     => sub { ... };

    after   teardown  => sub { ... };

The order that modifiers will be called will depend on the timing of role
composition.

You can even call test functions in these, for example, to confirm
that something has been set up or cleaned up.

=head2 Imported functions

=head3 test

    test $label => sub { ... };

The C<test> function adds a subtest.  The code reference will be called with
the test object as its only argument.

Tests are run in the order declared, so the order of tests from roles will
depend on when they are composed relative to other test declarations.

=head1 AUTHOR

David Golden <dagolden@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by David Golden.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut
