package EPrints::Plugin::Screen::EPrint::REF2029;

our @ISA = ( 'EPrints::Plugin::Screen::EPrint' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{actions} = [qw/ create_selection request_review /];

    $self->{appears} = [
        {
            place => "eprint_view_tabs",
            position => 4000,
        },
    ];

    #avoid issues with multiple archives under <v3.3.13
    $self->{disable} = 1;

    return $self;
}

sub can_be_viewed
{
    my( $self ) = @_;

    return 0 unless( $self->{session}->config( 'ref2029_enabled' ) && defined $self->{session}->current_user );

    return 0 if !$self->{session}->current_user->has_role( 'admin' );
    
    return $self->allow( "eprint/hefce_oa" );
}

sub allow_create_selection { shift->can_be_viewed }

sub action_create_selection
{
    my( $self ) = @_;

    # create the new selection, then redirect to edit screen
    my $selection_ds = $self->{session}->dataset( "ref2029_selection" );
    my $selection = $selection_ds->dataobj_class->create_from_data(
        $self->{session},
        {
            eprintid => $self->{processor}->{eprint}->id,
            title => $self->{processor}->{eprint}->value( "title" ),
        }
    );

    $self->{processor}->{selectionid} = $selection->id;
    $self->{processor}->{screenid} = "REF2029::SelectionEdit";
}

sub allow_request_review { shift->can_be_viewed }

sub action_request_review
{
    my( $self ) = @_;

    my $session = $self->{session};
    my $eprint =  $self->{processor}->{eprint};
    my $review_ds = $session->dataset( "ref2029_review" );

    my $email = $session->param( "email" );

    my $review = EPrints::DataObj::REF2029_Review->create_from_data(
        $session,
        {
            selectionid => $session->param( "selection" ),
            email => $email,    
        },
        $review_ds
    );

    # review has successfully been created, we can email the reviewer
    if( $review )
    {
           
    }

    $self->{processor}->{screenid} = "EPrint::View";
}

sub render
{
    my( $self ) = @_;
    my $repo = $self->{repository};
    my $page = $repo->xml->create_element( "div", class => "ref2029_eprint_tab" ); # wrapper

    my $eprint = $self->{processor}->{eprint};

    # Selections
    my $selections = EPrints::DataObj::REF2029_Selection->search_by_eprintid( $repo, $eprint->id );
    if( $selections->count == 0 )
    {
        $page->appendChild( $self->render_new_selection );
    }
    else
    {
        $page->appendChild( $self->render_selections( $selections ) );
    }

    return $page;
}
    
sub render_new_selection
{
    my( $self ) = @_;
   
    my $repo = $self->{repository};
    my $xml = $repo->xml;
    my $xhtml = $repo->xhtml;

    my $div = $xml->create_element( "div", class => "ep_block ep_sr_component create_selection" );

    $div->appendChild( $self->html_phrase( "eprint_not_selected" ) );

    my $form = $div->appendChild( $self->render_form( "create_selection" ) );
    $form->appendChild( $repo->render_action_buttons(
        create_selection => $repo->phrase( "Plugin/Screen/EPrint/REF2029:action_create_selection" ),
    ) );

    return $div;
}

sub render_selections
{
    my( $self, $selections ) = @_;

    my $repo = $self->{repository};
    my $xml = $repo->xml;
    my $xhtml = $repo->xhtml;

    my $div = $xml->create_element( "div", class => "ep_block ep_sr_component eprint_selections" );

    $div->appendChild( $self->html_phrase( "eprint_selected" ) );

    $selections->map(sub {
        my ($session, undef, $selection) = @_;

        $div->appendChild( my $selection_div = $xml->create_element( "div", class => "ref2029_selection" ) );

        # Overview
        $selection_div->appendChild( my $overview_div = $xml->create_element( "div", class => "ref2029_selection_overview" ) );
        $overview_div->appendChild( $selection->render_citation( "default" ) );

        $overview_div->appendChild( $self->render_action_list_bar(
            "ref2029_eprint_actions", {
                selectionid => $selection->id,
            }
        ) );

        # Reviews
        $selection_div->appendChild( $self->render_reviews( $selection ) );
    });

    return $div;
}

sub render_reviews
{
    my( $self, $selection ) = @_;
    
    my $repo = $self->{repository};
    my $xml = $repo->xml;
    my $xhtml = $repo->xhtml;

    my $div = $xml->create_element( "div", class => "ep_block ep_sr_component ref2029_selection_reviews" );

    # heading
    $div->appendChild( my $review_heading = $xml->create_element( "h3" ) );
    $review_heading->appendChild( $self->html_phrase( "selection_reviews" ) );

    # request review
    my $form = $div->appendChild( $self->render_form( "request_review" ) );
    $form->appendChild( EPrints::MetaField->new(
            name => "email",
            type => "email",
            repository => $repo,
        )->render_input_field(
            $repo,
            $self->{processor}->{data},
        ) );

    $form->appendChild( $repo->render_hidden_field( "selection", $selection->id ) );

    $form->appendChild( $repo->render_action_buttons(
        request_review => $self->phrase( "action_request" ),
    ) );

    # and now display the reviews
    foreach my $review ( @{$selection->value( "reviews" )} )
    {
        my $status = "";
        $status = $review->value( "status" ) if $review->is_set( "status" );

        $div->appendChild( my $review_div = $xml->create_element( "div", class => "ref2029_selection_review review_$status" ) );
        $review_div->appendChild( $review->render_citation );
    }

    return $div;


}

1;
