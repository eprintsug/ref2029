package EPrints::Plugin::Screen::Report::UoA::Z;

use EPrints::Plugin::Screen::Report::UoA;
our @ISA = ( 'EPrints::Plugin::Screen::Report::UoA' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new( %params );

    $self->{report} = 'ref2029_selection-Z';

    $self->{uoa} = 'ref2029_z';

    return $self;
}

1;
