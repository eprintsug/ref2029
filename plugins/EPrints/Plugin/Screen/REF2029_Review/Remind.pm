package EPrints::Plugin::Screen::REF2029_Review::Remind;

use EPrints::Plugin::Screen::REF2029_Review;

@ISA = ( 'EPrints::Plugin::Screen::REF2029_Review' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{actions} = [qw/ remind cancel /];

    $self->{appears} = [
        {
            place => "ref2029_review_pending_actions",
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

    $div->appendChild( $self->html_phrase("sure_remind",
        title=>$self->{processor}->{review}->render_description() ) );

    my %buttons = (
        cancel => $self->{session}->phrase(
                "lib/submissionform:action_cancel" ),
        remind => $self->{session}->phrase(
                "lib/submissionform:action_remind" ),
        _order => [ "remove", "remind" ]
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

sub allow_remind
{
    my( $self ) = @_;

    return $self->can_be_viewed;
}

sub action_remind
{
    my( $self ) = @_;

    my $session = $self->{session};

    my $review = $self->{processor}->{review};
    my $selection = $review->get_parent;
    my $eprint = $selection->get_parent;

    my $mail = $session->make_element( "mail" );
    $mail->appendChild( $session->html_phrase(
        "ref2029/remind_review:body",
        eprint_citation => $eprint->render_citation_link,
        review_link => $session->render_link( $review->get_review_link ),
    ) );

    my $result = EPrints::Email::send_mail(
        session => $session,
        langid => $session->get_langid,
        to_name => $review->value( "reviewer" ),
        to_email => $review->value( "email" ),
        subject => $session->phrase( "ref2029/remind_review:subject" ),
        message => $mail,
        sig => $session->html_phrase( "mail_sig" ),
    );

    if( !$result )
    {
        $self->{processor}->add_message( "error", $session->html_phrase( "ref2029/remind_review:email_failed" ) );
    }
    else
    {
        $self->{processor}->add_message( "message", $session->html_phrase( "ref2029/remind_review:email_success" ) );
    }

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
