package EPrints::DataObj::REF2029_Selection;

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
    return "ref2029_selection";
}

sub get_system_field_info
{
    my( $class ) = @_;

    return
    (
        { name => "ref2029_selectionid", type => "counter", required => 1, import => 0, show_in_html => 0, can_clone => 0, sql_counter => "ref2029_selectionid" },

        { name => "eprintid", type => "itemref", datasetid => "eprint", required => 1 },

        { name => "benchmarkid", type => "itemref", datasetid => 'ref2029_benchmark', required => 1, },

        { name => "date", type => "date", required => 1, },

        { name => "type", type => "set", options=>[qw( A B C D E F G H I J K L M N O P Q R S T U V )], required => 1 },

        { name => "title", type => "text", required => 1, },

        { name => "hesa", type => "id", required => 1, },

        { name => "doi", type => "id", required => 0, },

        { name => "former_staff", type => "boolean", required => 1, },

        { name => "pre_pub_link", type => "boolean", required => 1, },

        { name => "open_access", type => "set", options=>[qw( oa ex non_compliant )], required => 1, },

        { name => "xref", type => "subject", top => "ref2029_uoas" , required => 1, },

        { name => "research_group", type => "text", required => 0, },

        { name => "research_specialism", type => "longtext", required => 0, },

        { name => "num_co_authors", type => "int", required => 0, },

        ##### Requires further clarification for Research England #####
        #{ name => "disc_flags", type => ??? },

        { name => "abstract", type => "longtext", required => 0 },

        { name => "pending_pub", type => "boolean", required => 1 },

        { name => "multi_weight", type => "int", required => 0 },

        { name => "reserves", type => "itemref", datasetid => 'ref2029_selection', multiple => 1, required => 0 },
       
        { name => "supplementary_url", type => "url", required => 0 },

        { name => "confidential", type => "longtext", required => 0 },
    );       
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
