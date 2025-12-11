package EPrints::Plugin::Screen::Report::UoA::D30;

use EPrints::Plugin::Screen::Report::UoA;
our @ISA = ( 'EPrints::Plugin::Screen::Report::UoA' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new( %params );

    $self->{report} = 'ref2029_selection-D30';

    $self->{uoa} = 'ref2029_d30';

    return $self;
}

1;
