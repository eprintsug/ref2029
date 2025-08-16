package EPrints::Plugin::Screen::EPrint::REF2029;

our @ISA = ( 'EPrints::Plugin::Screen::EPrint' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{actions} = [qw/ create_selection request_review remove_review /];

    $self->{appears} = [
        {
            place => "eprint_view_tabs",
            position => 4000,
        },
    ];

    # avoid issues with multiple archives under <v3.3.13
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
    my $review_ds = $session->dataset( "ref2029_review" );

    my $reviewer = $session->param( "reviewer" );
    my $email = $session->param( "email" );

    my $review = EPrints::DataObj::REF2029_Review->create_from_data(
        $session,
        {
            selectionid => $session->param( "selection" ),
            reviewer => $reviewer,
            email => $email,
            status => "review_pending",   
        },
        $review_ds
    );

    # review has successfully been created, we can email the reviewer
    if( $review )
    {
           
    }

    $self->{processor}->{screenid} = "EPrint::View";
}

sub allow_remove_review { shift->can_be_viewed }

sub action_remove_review
{
    my( $self ) = @_;

    my $session = $self->{session};
    my $review_ds = $session->dataset( "ref2029_review" );

    my $review_id = $session->param( "review" );
    my $review = $review_ds->dataobj( $review_id );
    if( defined $review ) 
    {
        $review->remove;
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
    $div->appendChild( my $request_div = $xml->create_element( "div", class => "ref2029_request_review" ) );
    my $form = $request_div->appendChild( $self->render_form( "request_review" ) );
 
    my $review_ds = $repo->dataset( "ref2029_review" );
    my $reviewer_field = $review_ds->field( "reviewer" );
    my $email_field = $review_ds->field( "email" );

    $form->appendChild( my $reviewer_label = $xml->create_element( "label" ) );
    $reviewer_label->appendChild( my $reviewer_span = $xml->create_element( "span" ) );
    $reviewer_span->appendChild( $reviewer_field->render_name );
    $reviewer_label->appendChild( $reviewer_field->render_input_field(
        $repo,
        $self->{processor}->{data},
    ) );
 

    $form->appendChild( my $email_label = $xml->create_element( "label" ) );
    $email_label->appendChild( my $email_span = $xml->create_element( "span" ) );
    $email_span->appendChild( $email_field->render_name );
    $email_label->appendChild( $email_field->render_input_field(
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
        $div->appendChild( $self->render_review( $review ) );
    }

    return $div;
}

sub render_review
{
    my( $self, $review ) = @_;

    my $repo = $self->{repository};
    my $xml = $repo->xml;
    my $xhtml = $repo->xhtml;

    my $status = "";
    $status = $review->value( "status" ) if $review->is_set( "status" );

    my $review_div = $xml->create_element( "div", class => "ref2029_selection_review review_$status" );
    $review_div->appendChild( $review->render_citation );

    $review_div->appendChild( my $review_actions = $xml->create_element( "div", class => "ref2029_review_actions" ) );

    my $form = $review_actions->appendChild( $self->render_form( "remove_review" ) );
    $form->appendChild( $repo->render_hidden_field( "review", $review->id ) );
    $form->appendChild( $repo->render_action_buttons(
        remove_review => $self->phrase( "action_remove_review" ),
     ) );

    return $review_div;
}
1;
