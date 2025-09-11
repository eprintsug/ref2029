# REF Support Type mapping (borrowed from REF Support)
$c->{'ref2029'}->{map_eprint_type} = sub {
    my( $eprint ) = @_;

    my $type = $eprint->value( 'type' ) or return;

    if( $type eq 'book' )
    {
        return 'B' if !$eprint->is_set( 'creators' );   # Edited book
        return 'A';                                     # Authored book
    }

    return 'M' if $type eq 'exhibition';
    return 'C' if $type eq 'book_section';              # Chapter in book
    return 'D' if $type eq 'article';                   # Journal article
    return 'E' if $type eq 'conference_item';           # Conference contribution
    return 'F' if $type eq 'patent';                    # Patent / published patent application
    return 'I' if $type eq 'performance';               # Performance
    return 'J' if $type eq 'composition';               # Composition
    return 'L' if $type eq 'artefact';                  # Artefact
    return 'Q' if $type eq 'video';                     # Digital or visual media
    return 'T' if $type eq 'other';                     # Other

    return undef;
};


$c->{set_ref2029_selection_automatic_fields} = sub
{
    my( $selection ) = @_;

    my $session = $selection->{session};

    # Benchmark
    if( !$selection->is_set( "benchmarkid" ) )
    {
        my $benchmark = EPrints::DataObj::REF2029_Benchmark->active( $session );
        $selection->set_value( "benchmarkid", $benchmark->id ) if defined $benchmark;
    }

    # get the eprint this selection is about
    my $eprint_field = $selection->dataset->field( "eprintid" );
    my $eprint = $eprint_field->get_item( $session, $selection->value( "eprintid" ) );

    # Title
    if( !$selection->is_set( "title" ) && $eprint->is_set( "title" ) )
    {
        $selection->set_value( "title", $eprint->value( "title" ) );
    }

    # Abstract
    if( !$selection->is_set( "abstract" ) && $eprint->is_set( "abstract" ) )
    {
        $selection->set_value( "abstract", $eprint->value( "abstract" ) );
    }

    # Date
    if( !$selection->is_set( "date" ) && $eprint->is_set( "date" ) )
    {
        $selection->set_value( "date", $eprint->value( "date" ) );
    }

    # Type
    unless( $selection->is_set( 'type' ) )
    {
        $selection->set_value( 'type', $session->call( [ 'ref2029', 'map_eprint_type' ], $eprint ) );
    }

    # DOI
    if( !$selection->is_set( "doi" ) && $eprint->is_set( "id_number" ) )
    {
        $selection->set_value( "doi", $eprint->value( "id_number" ) );
    }
}
