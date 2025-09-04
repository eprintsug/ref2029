package EPrints::Plugin::Screen::Report::UoA;

use EPrints::Plugin::Screen::Report;
our @ISA = ( 'EPrints::Plugin::Screen::Report' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new( %params );

    $self->{datasetid} = 'ref2029_selection';
    $self->{searchdatasetid} = 'ref2029_selection';
    #$self->{custom_order} = '-title/creators_name';
    $self->{appears} = [];
    $self->{report} = 'ref2029_selection';
    #$self->{sconf} = 'ref2029_selection_report';
    $self->{export_conf} = 'ref2029_selection_report';
    $self->{disable} = 1;
    #$self->{sort_conf} = 'hefce_report';
    #$self->{group_conf} = 'hefce_report';
    
    $self->{labels} = {
        outputs => "Selections"
    };

    
    $self->{show_compliance} = 0;

    return $self;
}

sub can_be_viewed
{
    my( $self ) = @_;

    return 0 if( !$self->SUPER::can_be_viewed );

    return $self->allow( 'report/hefce_oa' );
}

sub ajax_ref2029_selection
{
    my( $self ) = @_;

    my $repo = $self->repository;

    my $json = { data => [] };

    $repo->dataset( "ref2029_selection" )
    ->list( [$repo->param( "ref2029_selection" )] )
    ->map(sub {
        (undef, undef, my $selection) = @_;
        return if !defined $selection; # odd

        my $frag = $selection->render_citation( "report" );
        push @{$json->{data}}, {
            datasetid => $selection->dataset->id,
            dataobjid => $selection->id,
            summary => EPrints::XML::to_string( $frag ),
#           grouping => sprintf( "%s", $selection->value( SOME_FIELD ) ),
            problems => [ $self->validate_dataobj( $selection ) ],
#            state => $self->get_state( $selection ),
            bullets => [ $self->bullet_points( $selection ) ],
        };
    });

    print $self->to_json( $json );
}

sub validate_dataobj
{
    my( $self, $selection ) = @_;

    my $repo = $self->{repository};

    my @problems;

    if( !$selection->is_set( "rating" ) || ( $selection->is_set( "rating" ) && $selection->value( "rating" ) eq "NONE" ) )
    {
        push @problems, $repo->phrase( "ref2029_selection:test:no_score" );
    }

    my $reviews = $selection->value( "reviews" );
    foreach my $review ( @{ $selection->value( "reviews" )} )
    {
        if( $review->value( "status" ) eq "review_pending" )
        {
            push @problems, $repo->phrase( "ref2029_selection:test:pending_review", name => $review->render_value( "reviewer" ) );
        }
    }

    return @problems;
}

sub bullet_points
{
    my( $self, $selection ) = @_;

    my $repo = $self->{repository};

    my @bullets;

    

    return @bullets;
}

1;

