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

sub get_system_field_info
{
    my( $class ) = @_;

    return
    (
        { name => "ref2029_reviewid", type => "counter", required => 1, import => 0, show_in_html => 0, can_clone => 0, sql_counter => "ref2029_reviewid" },

        { name => "selectionid", type => "itemref", datasetid => 'ref2029_selection', required => 1, },

        { name => "reviewer", type => "name", required => 0, },

        { name => "email", type => "email", required => 0, },

        { name => "review", type => "text", required => 0 },

        { name => "rating", type => "set", options => [0, 1, 2, 3, 4], required => 0 },

        { name => "pin", type => "text", required => 0 },
    );       
}


