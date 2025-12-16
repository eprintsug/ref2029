package EPrints::Plugin::Screen::REF2029;

# Abstract Class, exports some useful methods for rendering roles etc

use EPrints::Plugin::Screen;
@ISA = ( 'EPrints::Plugin::Screen' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{actions} = [qw/ create_benchmark /];

    $self->{appears} = [
        {
            place => "key_tools",
            position => 1095,
        },
    ];

    return $self;
}

sub can_be_viewed
{
    my( $self ) = @_;

    return 0 unless( $self->{session}->config( 'ref2029_enabled' ) && defined $self->{session}->current_user );

    # admins can view
    return 1 if !$self->{session}->current_user->has_role( 'admin' );
        
    # UoA Champions can View
    return 1 if $self->{session}->current_user->is_set( "ref2029_uoa_champion" );

    return 0;
}

sub allow_create_benchmark 
{
    my( $self ) = @_;

     return 0 unless( $self->{session}->config( 'ref2029_enabled' ) && defined $self->{session}->current_user );

    # admins can view
    return 1 if !$self->{session}->current_user->has_role( 'admin' );
   
    return 0;
}

sub action_create_benchmark
{
    my( $self ) = @_;

    # create the new benchmark, then redirect to edit screen
    my $benchmark_ds = $self->{session}->dataset( "ref2029_benchmark" );
    my $benchmark = $benchmark_ds->dataobj_class->create_from_data(
        $self->{session},
    );      

    $self->{processor}->{benchmarkid} = $benchmark->id;
    $self->{processor}->{screenid} = "REF2029::BenchmarkEdit";
}

sub render
{
    my( $self ) = @_;

    my $repo = $self->{repository};
    my $xml = $repo->xml;
    my $xhtml = $repo->xhtml;

    my $frag = $xml->create_document_fragment;

    my $user = $self->{session}->current_user;

    # render benchmarks
    if( $user->has_role( 'admin' ) )
    {
        $frag->appendChild( $self->render_benchmarks );
    }

    # render user's reports
    if( $user->is_set( "ref2029_uoa_champion" ) )
    {
        $frag->appendChild( $self->render_reports( $user ) );
    }
    
    return $frag;
}

sub render_benchmarks
{
    my( $self ) = @_;

    my $repo = $self->{repository};
    my $xml = $repo->xml;
    my $xhtml = $repo->xhtml;

    my $div = $xml->create_element( "div", class => "ep_block ep_sr_component ref2029_benchmarks" );

    # title
    my $title = $xml->create_element( "h2", id => "benchmarks" );
    $title->appendChild( $self->html_phrase( "benchmarks" ) );
    $div->appendChild( $title );
   
    # currently selected benchmark
    

    # create benchmark
    my $form = $div->appendChild( $self->{processor}->screen->render_form( "create_benchmark" ) );
    $form->appendChild( $repo->render_action_buttons(
        create_benchmark => $repo->phrase( "Plugin/Screen/REF2029:action_create_benchmark" ),
    ) );
        
    # list other benchmarks
    my $benchmarks = $repo->dataset( "ref2029_benchmark" )->search;
    $benchmarks->map( sub {
        (undef, undef, my $benchmark ) = @_;

        my $status = $benchmark->value( "status" );

        $div->appendChild( my $benchmark_div = $xml->create_element( "div", class => "benchmark benchmark_$status" ) );
        $benchmark_div->appendChild( $benchmark->render_citation( "default" ) );

        
        $benchmark_div->appendChild( $self->render_action_list_bar(
            "benchmark_actions", {
                benchmarkid => $benchmark->id,
            }
        ) );
    } );
    
    return $div;
}

sub render_reports
{
    my( $self, $user ) = @_;

    my $repo = $self->{repository};
    my $xml = $repo->xml;
    my $xhtml = $repo->xhtml;

    my $div = $xml->create_element( "div", class => "ep_block ep_sr_component ref2029_reports" );

    # title
    my $title = $xml->create_element( "h2", id => "reports" );
    $title->appendChild( $self->html_phrase( "reports" ) );
    $div->appendChild( $title );
 
    # reports
    my @uoas = @{$user->value( "ref2029_uoa_champion" )};
    my @report_ids = $repo->plugin_list(
        type => "Screen",
    );
    
    $div->appendChild( my $ul = $xml->create_element( "ul" ) );
    foreach my $id ( @report_ids )
    {
        next if( $id !~ /^Screen::Report::UoA/ );
        my $r = $self->repository->plugin( "$id" );
        
        next if !grep { $r->{uoa} eq $_ } @uoas;

        $ul->appendChild( my $li = $xml->create_element( "li" ) );
        $li->appendChild( $r->render_action_link );

    }

    return $div;
}
