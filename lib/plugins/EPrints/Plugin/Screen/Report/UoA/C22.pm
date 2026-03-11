package EPrints::Plugin::Screen::Report::UoA::C22;

use EPrints::Plugin::Screen::Report::UoA;
our @ISA = ( 'EPrints::Plugin::Screen::Report::UoA' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new( %params );

    $self->{report} = 'ref2029_selection-C22';

    $self->{uoa} = 'ref2029_c22';

    return $self;
}

1;
