package EPrints::Plugin::Screen::REF2029_Review::Edit;

use EPrints::Plugin::Screen::REF2029_Review;

@ISA = ( 'EPrints::Plugin::Screen::REF2029_Review' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{actions} = [qw/ stop save /];

    $self->{appears} = [
        {
            place => "ref2029_review_admin_actions",
            position => 100,
        }
    ],

    return $self;
}

sub from
{
    my( $self ) = @_;

    if( defined $self->{processor}->{internal} )
    {
        my $from_ok = $self->workflow->update_from_form( $self->{processor},undef,1 );
        $self->uncache_workflow;
        return unless $from_ok;
    }

    $self->EPrints::Plugin::Screen::from;
}

sub allow_stop
{
    my( $self ) = @_;

    return $self->can_be_viewed;
}

sub action_stop
{
    my( $self ) = @_;

    $self->{processor}->{screenid} = $self->screen_after_flow;
}

sub allow_save
{
    my( $self ) = @_;

    return $self->can_be_viewed;
}

sub action_save
{
    my( $self ) = @_;

    $self->workflow->update_from_form( $self->{processor} );
    $self->uncache_workflow;

    $self->{processor}->{screenid} = $self->screen_after_flow;

    # TODO: Display warnings???
}

sub screen_after_flow
{
    my( $self ) = @_;

    if( $self->allow( "eprint/view" ) )
    {
        return "EPrint::View";
    }
    else
    {
        return "EPrint::REF2029";
    }
}

sub render_title
{
    my( $self ) = @_;

    my $review = $self->{processor}->{review};
    
    return $self->html_phrase( 'title' ) unless( defined $review );

    my $selection = $review->get_parent;

    return $self->html_phrase( 'review_title', title => $selection->render_value( 'title' ) );
}

sub render
{
    my( $self ) = @_;

    my $repo = $self->{repository};
    my $xml = $repo->xml;
    my $frag = $xml->create_document_fragment;

    # Form
    $frag->appendChild( my $form = $self->render_form );

    $form->appendChild( $self->render_buttons );
    $form->appendChild( $self->workflow->render );
    $form->appendChild( $self->render_buttons );

    return $frag;
}

sub render_buttons
{
    my( $self ) = @_;

    my %buttons = ( _order=>[], _class=>"ep_form_button_bar" );

    if( defined $self->workflow->get_prev_stage_id )
    {
        push @{$buttons{_order}}, "prev";
        $buttons{prev} = $self->phrase( "prev" );
    }

    push @{$buttons{_order}}, "stop", "save";
    $buttons{stop} = $self->phrase( "stop" );
    $buttons{save} = $self->phrase( "save" );

    if( defined $self->workflow->get_next_stage_id )
    {
        push @{$buttons{_order}}, "next";
        $buttons{next} = $self->phrase( "next" );
    }
    return $self->{session}->render_action_buttons( %buttons );
}

sub workflow
{
    my( $self, $staff ) = @_;

    my $cache_id = "workflow";
    $cache_id.= "_staff" if( $staff );

    my $session =  $self->{session};
    if( !defined $self->{processor}->{$cache_id} )
    {
        my %opts = (
            item => $self->{processor}->{review},
            session => $self->{session}
        );
        
        $opts{STAFF_ONLY} = [$staff ? "TRUE" : "FALSE","BOOLEAN"];
        $self->{processor}->{$cache_id} = EPrints::Workflow->new(
            $self->{session},
            "default",
            %opts 
        );
    }

    return $self->{processor}->{$cache_id};
}

sub uncache_workflow
{
    my( $self ) = @_;
    delete $self->{processor}->{workflow};
    delete $self->{processor}->{workflow_staff};
}

sub redirect_to_me_url
{
    my( $self ) = @_;

    return $self->SUPER::redirect_to_me_url."&reviewid=".$self->{processor}->{reviewid};
}

sub hidden_bits
{
    my( $self ) = @_;

    return(
        $self->SUPER::hidden_bits,
        reviewid => $self->{processor}->{reviewid},
    );
}

1;
