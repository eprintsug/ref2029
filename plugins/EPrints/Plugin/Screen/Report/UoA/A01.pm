package EPrints::Plugin::Screen::Report::UoA::A01;

use EPrints::Plugin::Screen::Report::UoA;
our @ISA = ( 'EPrints::Plugin::Screen::Report::UoA' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new( %params );

    $self->{report} = 'ref2029_selection-A01';

    return $self;
}

sub items
{
    my( $self ) = @_;

    my $selection_ds = $self->repository->dataset( "ref2029_selection" );
    
    my $search_exp = EPrints::Search->new(
        session => $self->repository,
        satisfy_all => 1,
        dataset => $selection_ds,
    );

    $search_exp->add_field(
        fields => [ $selection_ds->field( 'uoa' ) ],
        value => 'ref2029_a1',
        match => "EX",
    );

    my $list = $search_exp->perform_search;

    return $list;
}

1;

