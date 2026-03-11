package EPrints::Plugin::Screen::Report::UoA::D27;

use EPrints::Plugin::Screen::Report::UoA;
our @ISA = ( 'EPrints::Plugin::Screen::Report::UoA' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new( %params );

    $self->{report} = 'ref2029_selection-D27';

    $self->{uoa} = 'ref2029_d27';

    return $self;
}

1;
