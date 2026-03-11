package EPrints::Plugin::Screen::REF2029_Review::Remove;

use EPrints::Plugin::Screen::REF2029_Review;

@ISA = ( 'EPrints::Plugin::Screen::REF2029_Review' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{actions} = [qw/ remove cancel /];

    $self->{appears} = [
        {
            place => "ref2029_review_admin_actions",
            position => 101,
        }
    ],

    return $self;
}

sub hidden_bits
{
    my( $self ) = @_;

    return(
        $self->SUPER::hidden_bits,
        reviewid => $self->{processor}->{review}->id,
    );
}

sub render
{
    my( $self ) = @_;

    my $div = $self->{session}->make_element( "div", class=>"ep_block" );

    $div->appendChild( $self->html_phrase("sure_delete",
        title=>$self->{processor}->{review}->render_description() ) );

    my %buttons = (
        cancel => $self->{session}->phrase(
                "lib/submissionform:action_cancel" ),
        remove => $self->{session}->phrase(
                "lib/submissionform:action_remove" ),
        _order => [ "remove", "cancel" ]
    );

    my $form= $self->render_form;
    $form->appendChild(
        $self->{session}->render_action_buttons(
            %buttons ) );
    $div->appendChild( $form );

    return( $div );
}

sub allow_cancel
{
    my( $self ) = @_;

    return $self->can_be_viewed;
}

sub action_cancel
{
    my( $self ) = @_;

    if( $self->allow( "eprint/view" ) )
    {
        $self->{processor}->{screenid} = "EPrint::View";
    }
    else
    {
        $self->{processor}->{screenid} = "EPrint::REF2029";
    }
}

sub allow_remove
{
    my( $self ) = @_;

    return $self->can_be_viewed;
}

sub action_remove
{
    my( $self ) = @_;

    if( !$self->{processor}->{review}->remove )
    {
        $self->{processor}->add_message( "message", $self->html_phrase( "item_not_removed" ) );
        $self->{processor}->{screenid} = $self->view_screen;
        return;
    }

    $self->{processor}->add_message( "message", $self->html_phrase( "item_removed" ) );

    if( $self->allow( "eprint/view" ) )
    {
        $self->{processor}->{screenid} = "EPrint::View";
    }
    else
    {
        $self->{processor}->{screenid} = "EPrint::REF2029";
    }
}

1;
