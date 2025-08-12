=head1 NAME

EPrints::Plugin::Screen::REF2029_Review::Acknowledge

=cut


package EPrints::Plugin::Screen::REF2029_Review::Acknowledge;

use EPrints::Plugin::Screen;

@ISA = ( 'EPrints::Plugin::Screen' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new(%params);

    return $self;
}

sub render
{
    my( $self ) = @_;

    my $repo = $self->{repository};

    my $page = $repo->xml->create_element( "div", class => "ref2029_review_acknowledge" );
 
    $page->appendChild( $self->html_phrase( "review_submitted" ) );

    return $page
}
