package EPrints::Plugin::Screen::REF2029_Selection::Remove;

use EPrints::Plugin::Screen::REF2029_Selection;

@ISA = ( 'EPrints::Plugin::Screen::REF2029_Selection' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{actions} = [qw/ remove cancel /];

    $self->{appears} = [
        {
            place => "ref2029_eprint_actions",
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
        selectionid => $self->{processor}->{selection}->id,
    );
}

sub render
{
    my( $self ) = @_;

    my $div = $self->{session}->make_element( "div", class=>"ep_block" );

    $div->appendChild( $self->html_phrase("sure_delete",
        title=>$self->{processor}->{selection}->render_description() ) );

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

    $self->{processor}->{screenid} = "EPrint::View";
}

sub allow_remove
{
    my( $self ) = @_;

    return $self->can_be_viewed;
}

sub action_remove
{
    my( $self ) = @_;

    if( !$self->{processor}->{selection}->remove )
    {
        $self->{processor}->add_message( "message", $self->html_phrase( "item_not_removed" ) );
        $self->{processor}->{screenid} = $self->view_screen;
        return;
    }

    $self->{processor}->add_message( "message", $self->html_phrase( "item_removed" ) );

    $self->{processor}->{screenid} = "EPrint::View";
}

1;
