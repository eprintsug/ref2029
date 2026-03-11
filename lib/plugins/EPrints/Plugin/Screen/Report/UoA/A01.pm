package EPrints::Plugin::Screen::Report::UoA::A01;

use EPrints::Plugin::Screen::Report::UoA;
our @ISA = ( 'EPrints::Plugin::Screen::Report::UoA' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new( %params );

    $self->{report} = 'ref2029_selection-A01';

    $self->{uoa} = 'ref2029_a1';

    return $self;
}

1;

