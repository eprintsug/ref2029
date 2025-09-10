package EPrints::DataObj::REF2029_Review;

our @ISA = qw( EPrints::DataObj::SubObject );

use strict;
use Data::Dumper;

# The new method can simply return the constructor of the super class (Dataset)
sub new
{
    return shift->SUPER::new( @_ );
}

sub get_dataset_id
{
    my ($self) = @_;
    return "ref2029_review";
}

sub get_parent_dataset_id
{
    "ref2029_selection";
}

sub get_parent_id
{
    my( $self ) = @_;

    return $self->get_value( "selectionid" );
}

sub get_system_field_info
{
    my( $class ) = @_;

    return
    (
        { name => "ref2029_reviewid", type => "counter", required => 1, import => 0, show_in_html => 0, can_clone => 0, sql_counter => "ref2029_reviewid" },

        { name => "selectionid", type => "itemref", datasetid => 'ref2029_selection', required => 1, },

        { name => "reviewer", type => "text", required => 0, },

        { name => "email", type => "email", required => 0, },

        { name => "review", type => "longtext", required => 0 },

        { name => "rating", type => "set", options => [0, 1, 2, 3, 4], required => 0 },

        { name => "pin", type => "text", required => 0 },

        { name => "status", type => "set", multiple => 0, required => 0, options=>[
            'complete',
            'error',
            'review_pending',
            ]
        },
    );       
}

# PIN functionality borrowed from Request DataObj
sub review_with_pin
{
    my( $repo, $pin ) = @_;

    my $dataset = $repo->dataset( 'ref2029_review' );

    my $searchexp = EPrints::Search->new(
                     satisfy_all => 1,
                     session => $repo,
                     dataset => $dataset,
                    );

    $searchexp->add_field( $dataset->get_field( 'pin' ),
               $pin,
               'EQ',
               'ALL'
             );

    my $results = $searchexp->perform_search;

    return $results->item( 0 );
}

sub new_from_data
{
    my( $class, $session, $data, $dataset ) = @_;

    $dataset = $dataset || undef;

    my $dataobj = $class->SUPER::new_from_data( $session, $data, $dataset );

    $dataobj->set_pin;

    return $dataobj;
}

sub set_pin
{
    my( $self ) = @_;
    # Generate a random unique pin by using a random string prefixed
    # by the (unique and sequential) request ID
    my $pin = $self->get_id() . EPrints::Utils::generate_token(22);
    $self->set_value( 'pin', $pin );
    return $pin;
}

sub get_review_link
{
    my( $self ) = @_;
    my $repository = $self->{session}->get_repository;
    return $repository->config("http_cgiurl")."/ref2029/review?pin=".$self->value( "pin" );
}
