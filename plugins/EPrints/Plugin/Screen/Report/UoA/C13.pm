package EPrints::Plugin::Screen::Report::UoA::C13;

use EPrints::Plugin::Screen::Report::UoA;
our @ISA = ( 'EPrints::Plugin::Screen::Report::UoA' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new( %params );

    $self->{report} = 'ref2029_selection-C13';

    $self->{uoa} = 'ref2029_c13';

    return $self;
}

1;
