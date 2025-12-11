package EPrints::Plugin::Screen::Report::UoA::B09;

use EPrints::Plugin::Screen::Report::UoA;
our @ISA = ( 'EPrints::Plugin::Screen::Report::UoA' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new( %params );

    $self->{report} = 'ref2029_selection-B09';

    $self->{uoa} = 'ref2029_b9';

    return $self;
}

1;
