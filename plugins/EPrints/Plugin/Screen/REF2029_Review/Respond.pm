=head1 NAME

EPrints::Plugin::Screen::REF2029_Review::Respond

=cut


package EPrints::Plugin::Screen::REF2029_Review::Respond;

use EPrints::Plugin::Screen;

@ISA = ( 'EPrints::Plugin::Screen' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{actions} = [qw/ save /];

    return $self;
}

sub properties_from
{
    my( $self ) = @_;
    
    # have we just submitted a review?
    if( $self->{processor}->{review_submitted} )
    {
        return;
    }

    # get the pin and associated review 
    $self->{processor}->{reviewpin} = $self->{session}->param( "pin" );
    $self->{processor}->{review} = EPrints::DataObj::REF2029_Review::review_with_pin( $self->{session}, $self->{processor}->{reviewpin} );

    # no review, no screen!
    if( !defined $self->{processor}->{review} )
    {
        &_properties_error;
        return;
    }

    # set reviewid
    $self->{processor}->{reviewid} = $self->{processor}->{review}->id;
}

sub _properties_error
{
    my( $self ) = @_;

    $self->{processor}->{screenid} = "Error";
    $self->{processor}->add_message( "error", $self->{session}->html_phrase( "general:bad_param" ) );
}

sub allow_save
{
    my( $self ) = @_;

    return 1 if defined $self->{processor}->{review} && $self->{processor}->{review}->is_set( "pin" );

    return 0;
}

sub action_save
{
    my( $self ) = @_;

    $self->workflow->update_from_form( $self->{processor} );
    $self->uncache_workflow;
    
    # now we've saved the review, remove the pin
    $self->{processor}->{review}->set_value( "pin", undef );
    $self->{processor}->{review}->set_value( "status", "complete" );
    $self->{processor}->{review}->commit;

    $self->{processor}->{screenid} = $self->screen_after_flow;
}

sub screen_after_flow
{
    my( $self ) = @_;

    return "REF2029_Review::Acknowledge";
}

sub render
{
    my( $self ) = @_;

    my $repo = $self->{repository};

    my $page = $repo->xml->create_element( "div", class => "ref2029_review_respond" );

    if( $self->{processor}->{review_submitted} )
    {
        $page->appendChild( $self->html_phrase( "review_submission" ) );
        return $page;
    }

    # Introduction / Help
    
    # EPrint Citation and link to EPrint

    # Form
    my $form = $self->render_form;
    $form->appendChild( $self->workflow->render );
    $form->appendChild( $self->render_buttons );

    $page->appendChild( $form );

    return $page
}

sub render_buttons
{
    my( $self ) = @_;

    my %buttons = ( _order=>[], _class=>"ep_form_button_bar" );

    push @{$buttons{_order}}, "save";
    $buttons{save} = $self->phrase( "save" );

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

sub hidden_bits
{
    my( $self ) = @_;

    return(
        $self->SUPER::hidden_bits,
        reviewid => $self->{processor}->{reviewid},
        pin => $self->{processor}->{review}->value( "pin" ),
    );
}
