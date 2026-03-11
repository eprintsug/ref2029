package EPrints::Plugin::Screen::REF2029_Review;

use EPrints::Plugin::Screen;

@ISA = ( 'EPrints::Plugin::Screen' );

use strict;

### Abstract screen for implementing shared can_be_viewed

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new(%params);

    return $self;
}

sub can_be_viewed
{
    my( $self ) = @_;

    return 0 unless( $self->{session}->config( 'ref2029_enabled' ) && defined $self->{session}->current_user );
 
    return 0 unless $self->{session}->current_user->is_set( "ref2029_uoa_champion" );

    if( defined $self->{processor}->{review} )
    {
        my $selection = $self->{processor}->{review}->get_parent;
        
        return 0 unless defined $selection;

        if( !$self->{session}->current_user->ref2029_uoa_in_scope( $selection->value( "uoa" ) ) )
        {
            return 0;
        }
    }
    return 1;
}

sub properties_from
{
    my( $self ) = @_;

    my $dataset = $self->{processor}->{dataset} = $self->{session}->dataset( "ref2029_review" );

    my $reviewid = $self->{session}->param( "reviewid" );
    $self->{processor}->{reviewid} = $reviewid;
    $self->{processor}->{review} = $dataset->dataobj( $reviewid );

    if( !defined $self->{processor}->{review} )
    {
        $self->{processor}->{screenid} = "Error";
        $self->{processor}->add_message( "error",
            $self->html_phrase(
                "no_such_review",
                id => $self->{session}->make_text(
                    $self->{processor}->{reviewid}
                ) 
            )
        );
        return;
    }

    my $eprintid = $self->{processor}->{review}->get_parent->value( "eprintid" );
    $self->{processor}->{eprintid} = $eprintid;
}

1;
