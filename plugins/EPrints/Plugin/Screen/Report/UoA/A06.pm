package EPrints::Plugin::Screen::Report::UoA::A06;

use EPrints::Plugin::Screen::Report::UoA;
our @ISA = ( 'EPrints::Plugin::Screen::Report::UoA' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new( %params );

    $self->{report} = 'ref2029_selection-A06';

    $self->{uoa} = 'ref2029_a6';

    return $self;
}

1;
