package EPrints::DataObj::REF2029_Selection;

our @ISA = qw( EPrints::DataObj::SubObject );

use strict;
use Data::Dumper;

# The new method can simply return the constructor of the super class (Dataset)
sub new
{
    return shift->SUPER::new( @_ );
}

sub get_control_url
{
    my( $self ) = @_;

    return $self->{session}->get_repository->get_conf( "perl_url" ).
        "/users/home?screen=REF2029_Selection::Edit&selectionid=".
        $self->id;
}


sub get_dataset_id
{
    my ($self) = @_;
    return "ref2029_selection";
}

sub get_parent_dataset_id
{
    "eprint";
}

sub get_parent_id
{
    my( $self ) = @_;

    return $self->get_value( "eprintid" );
}

sub get_system_field_info
{
    my( $class ) = @_;

    return
    (
        { name => "ref2029_selectionid", type => "counter", required => 1, import => 0, show_in_html => 0, can_clone => 0, sql_counter => "ref2029_selectionid" },

        { name => "eprintid", type => "itemref", datasetid => "eprint", required => 1 },

        { name => "benchmarkid", type => "itemref", datasetid => 'ref2029_benchmark', required => 1, },
    );       
}

sub commit
{
    my( $self, $force ) = @_;

    # this will call set_ref2029_selection_automatic_fields
    $self->update_triggers();

    if( scalar( keys %{$self->{changed}} ) == 0 )
    {
        # don't do anything if there isn't anything to do
        return( 1 ) unless $force;
    }

    return $self->SUPER::commit( $force );
}

sub create_from_data
{
    my( $class, $session, $data, $dataset ) = @_;

    my $self = $class->SUPER::create_from_data( $session, $data, $dataset );

    return undef unless defined $self;

    # this will call set_ref2029_selection_automatic_fields
    $self->update_triggers();

    $self->SUPER::commit();

    return $self;
}

sub remove
{
    my( $self ) = @_;

    # Remove our subobjects, in this case any reviews
    foreach my $review ( @{($self->get_value( "reviews" ))} )
    {
        $review->remove;
    }

    my $success = $self->SUPER::remove();

    return $success;
}

# Validation checks
# 1) Does date fit within scope
# 2) Does type match eprint type?
# 3) HESA ID checksum??
# 4) OA compliance warning
# 5) num_co_authors match up with listed creators?
# 6) multi-weight number match up with correct number of reserves


sub search_by_eprintid
{
    my( $class, $session, $eprintid ) = @_;

    return $session->dataset( $class->get_dataset_id )->search(
        filters => [{
            meta_fields => [qw( eprintid )],
            value => $eprintid,
            match => "EX",
        }],
        custom_order => "-ref2029_selectionid",
    );
}
