package EPrints::Plugin::Screen::Report::UoA::A05;

use EPrints::Plugin::Screen::Report::UoA;
our @ISA = ( 'EPrints::Plugin::Screen::Report::UoA' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new( %params );

    $self->{report} = 'ref2029_selection-A05';

    $self->{uoa} = 'ref2029_a5';

    return $self;
}

1;
