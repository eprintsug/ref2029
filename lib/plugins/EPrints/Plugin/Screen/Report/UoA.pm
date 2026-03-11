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

    return 0 unless( $self->{session}->config( 'ref2029_enabled' ) && defined $self->{session}->current_user );

    return 0 unless $self->{session}->current_user->is_set( "ref2029_uoa_champion" );

    return 0 unless defined $self->{uoa};

    # do we have permission for this UoA   
    if( $self->{session}->current_user->ref2029_uoa_in_scope( $self->{uoa} ) )
    {
        return 1;
    }
    else
    {
        return 0;
    }

    return 1;
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
        value => $self->{uoa},
        match => "EX",
    );

    my $list = $search_exp->perform_search;

    return $list;
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

    # Selection link
    my $selection_link = $repo->render_link( $selection->get_control_url, "_blank" );
    $selection_link->appendChild( $repo->make_text( "Edit Selection" ) );
    push @bullets, $selection_link;

    # Mediated Score
    if( $selection->is_set( "rating" ) && $selection->value( "rating" ) ne "NONE" )
    {
        push @bullets, $repo->phrase( "ref2029_selection:bullet:score", score => $selection->render_value( "rating" ) );
    }

    # Reviews
    if( $selection->is_set( "reviews" ) )
    {
        foreach my $review ( @{$selection->value( "reviews" )} )
        {
            if( $review->value( "status" ) eq "complete" )
            {
                push @bullets, $repo->phrase( "ref2029_selection:bullet:complete_review", name => $review->render_value( "reviewer" ), score => $review->render_value( "rating" ) ); 
            }
        }
    }

    return @bullets;
}

1;

