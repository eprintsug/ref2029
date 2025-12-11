package EPrints::Plugin::Screen::Report::UoA::D32;

use EPrints::Plugin::Screen::Report::UoA;
our @ISA = ( 'EPrints::Plugin::Screen::Report::UoA' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new( %params );

    $self->{report} = 'ref2029_selection-D32';

    $self->{uoa} = 'ref2029_d32';

    return $self;
}

1;
