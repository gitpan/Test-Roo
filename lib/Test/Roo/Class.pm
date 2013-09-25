use 5.008001;
use strictures;

package Test::Roo::Class;
# ABSTRACT: Base class for Test::Roo test classes
our $VERSION = '1.002'; # VERSION

use Moo;
use MooX::Types::MooseLike::Base qw/Str/;
use Test::More 0.96 import => [qw/subtest/];

#--------------------------------------------------------------------------#
# attributes
#--------------------------------------------------------------------------#


has description => (
    is      => 'rw',
    isa     => Str,
    lazy    => 1,
    builder => 1,
);

sub _build_description {
    my $class = ref $_[0];
    return "testing with $class";
}

#--------------------------------------------------------------------------#
# class or object methods
#--------------------------------------------------------------------------#


sub run_tests {
    my $self = shift;
    # get hashref from end of args
    # if any args are left, it must be description
    my ( $desc, $args );
    $args = pop if @_ && ref $_[-1] eq 'HASH';
    $desc = shift;

    # create an object if needed and possibly update description
    $self = $self->new( $args || {} )
      if !ref $self;
    $self->description($desc)
      if defined $desc;

    # execute tests wrapped in a subtest
    subtest $self->description => sub {
        $self->setup;
        $self->_do_tests;
        $self->teardown;
    };
}

#--------------------------------------------------------------------------#
# private methods and stubs
#--------------------------------------------------------------------------#


sub setup { }


sub each_test {
    my ( $self, $code ) = @_;
    $code->($self);
}


sub teardown { }

# anchor for tests as method modifiers
sub _do_tests { }

1;


# vim: ts=4 sts=4 sw=4 et:

__END__

=pod

=encoding utf-8

=head1 NAME

Test::Roo::Class - Base class for Test::Roo test classes

=head1 VERSION

version 1.002

=head1 DESCRIPTION

This module is the base class for L<Test::Roo> test classes.  It provides
methods to run tests and anchor modifiers.  Generally, you should not extend
this class yourself, but use L<Test::Roo> to do so instead.

=head1 ATTRIBUTES

=head2 description

A description for a subtest block wrapping all tests by the object.  It is a
'lazy' attribute.  Test classes may implement their own C<_build_description>
method to create a description from object attributes.  Otherwise, the default
is "testing with CLASS".

=head1 METHODS

=head2 run_tests

    # as a class method
    $class->run_tests();
    $class->run_tests($description);
    $class->run_tests($init_args);
    $class->run_tests($description $init_args);

    # as an object method
    $self->run_tests();
    $self->run_tests($description);

If called as a class method, this creates a test object using an optional hash
reference of initialization arguments.

When called as an object method, or after an object has been generated, this
method sets an optional description and runs tests.  It will call the C<setup>
method (triggering any method modifiers), will run all tests (triggering any
method modifiers on C<each_test>) and will call the C<teardown> method
(triggering any method modifiers).

If a description is provided, it will override any initialized or generated
C<description> attribute.

The setup, tests and teardown will be executed in a L<Test::More> subtest
block.

=head2 setup

This is an empty method used to anchor method modifiers.  It should not
be overridden by subclasses.

=head2 each_test

This method wraps the code references set by the C<test> function
from L<Test::Roo> or L<Test::Roo::Role> in a L<Test::More> subtest block.

It may also be used to anchor modifiers that should run before or after
each test block, though this can lead to brittle design as modifiers
will globally affect every test block, including composed ones.

=head2 teardown

This is an empty method used to anchor method modifiers.  It should not
be overridden by subclasses.

=for Pod::Coverage each_test setup teardown

=head1 AUTHOR

David Golden <dagolden@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by David Golden.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut
