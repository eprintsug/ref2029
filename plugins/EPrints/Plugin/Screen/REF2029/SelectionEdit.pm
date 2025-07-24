package EPrints::Plugin::Screen::REF2029::SelectionEdit;

use EPrints::Plugin::Screen;

@ISA = ( 'EPrints::Plugin::Screen' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{actions} = [qw/ stop save /];

    $self->{appears} = [
        {
            place => "ref2029_eprint_actions",
            position => 100,
        }
    ],

    return $self;
}

sub can_be_viewed
{
    my( $self ) = @_;

    return 0 unless( $self->{session}->config( 'ref2029_enabled' ) && defined $self->{session}->current_user );

    return 0 if !$self->{session}->current_user->has_role( 'admin' );

    return 1;
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

    return "REF2029";
}

sub render_title
{
    my( $self ) = @_;

    my $selection = $self->{processor}->{selection};

    return $self->html_phrase( 'title' ) unless( defined $selection );

    return $self->html_phrase( 'selection_title', title => $selection->render_value( 'title' ) );
}

sub render
{
    my( $self ) = @_;

    my $form = $self->render_form;

    $form->appendChild( $self->render_buttons );
    $form->appendChild( $self->workflow->render );
    $form->appendChild( $self->render_buttons );

    return $form;
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
            item => $self->{processor}->{selection},
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

sub properties_from
{
    my( $self ) = @_;

    my $dataset = $self->{processor}->{dataset} = $self->{session}->dataset( "ref2029_selection" );

    my $selectionid = $self->{session}->param( "selectionid" );
    $self->{processor}->{selectionid} = $selectionid;
    $self->{processor}->{selection} = $dataset->dataobj( $selectionid );

    if( !defined $self->{processor}->{selection} )
    {
        $self->{processor}->{screenid} = "Error";
        $self->{processor}->add_message( "error",
            $self->html_phrase(
                "no_such_selection",
                id => $self->{session}->make_text(
                    $self->{processor}->{selectionid}
                ) 
            )
        );
        return;
    }
}

sub redirect_to_me_url
{
    my( $self ) = @_;

    return $self->SUPER::redirect_to_me_url."&selectionid=".$self->{processor}->{selectionid};
}

sub hidden_bits
{
    my( $self ) = @_;

    return(
        $self->SUPER::hidden_bits,
        selectionid => $self->{processor}->{selectionid},
    );
}

1;
