package EPrints::Plugin::Screen::Report::REF2029AddSelection;

use EPrints::Plugin::Screen::Report;
our @ISA = ( 'EPrints::Plugin::Screen::Report' );

use strict;

sub new
{
        my( $class, %params ) = @_;

        my $self = $class->SUPER::new( %params );

        $self->{datasetid} = 'eprint';
        $self->{report} = 'ref2029_add_selection';
        $self->{searchdatasetid} = 'archive';
        $self->{sconf} = 'ref2029_add_selection';
        $self->{export_conf} = 'ref2029_add_selection';
        $self->{appears} = [];
        $self->{show_compliance} = 0;

        return $self;
}

sub can_be_viewed
{
    my( $self ) = @_;

    return 0 if( !$self->SUPER::can_be_viewed );

    return 0 unless( $self->{session}->config( 'ref2029_enabled' ) && defined $self->{session}->current_user );

    return 0 unless $self->{session}->current_user->is_set( "ref2029_uoa_champion" );

    return 1;
}

sub properties_from
{
    my( $self ) = @_;

    my $repo = $self->repository;
    $self->SUPER::properties_from;

    my $user = $repo->current_user;

    $self->{processor}->{user_uoas} = $user->value( "ref2029_uoa_champion" );
}

sub render
{
    my( $self ) = @_;

    my $repo = $self->repository;
    my $chunk = $self->SUPER::render();

    $chunk->appendChild( $repo->make_javascript( <<JS ) );
Event.observe(window, 'load', function() {
    var buttons = document.querySelectorAll("input[type=button][name=new_selection]");
    buttons.forEach(function(btn) {
        btn.addEventListener('click', function() {
                
            // get eprintid from hidden sibling input element
            var div = this.parentNode;
            var eprintid = div.querySelector("input[type=hidden]");
 
            // get the UoA from dropdown
            var uoa_select = div.querySelector("select[name=uoa]");

            // update the user record
            new Ajax.Request( '/cgi/ref2029/add_selection', {
                parameters: "eprintid="+eprintid.value+"&uoa="+uoa_select.value,
                method: "POST",
                onSuccess: function(response) {
                    // Update the UI to show the new option
                    // This seems a bit clumsy, maybe there should be a more universal Ajax
                    // approach to showing an eprint's selections
                    var new_item = response.responseText;
                    
                    // add the selection to the list
                    var ul = div.parentNode.parentNode;
                    var new_li = document.createElement("li");
                    new_li.innerHTML =  new_item.trim();
                    ul.insertBefore( new_li, ul.children[ul.children.length-1] );

                    // and remove the option from the selection list
                    for (var i = uoa_select.length - 1; i >= 0; i--)
                    {
                        if(uoa_select.options[i].value == uoa_select.value)
                        {
                            uoa_select.remove(i);
                        }
                    }

                    // no more options, hide this whole element
                    if( uoa_select.length == 0 )
                    {
                        div.style.display = 'none';
                    }
                },
                onFailure: function() {
                    error_div = div.querySelector("div.ref2029_new_selection_error");
                    error_div.innerHTML += 'Error adding REF selection';
                    error_div.style.display = 'block';
                },
            });
        });
    });
});
JS

    return $chunk;
}

sub apply_filters
{
    my( $self ) = @_;

    my $ds = $self->repository->dataset( 'eprint' );
    my $date = $ds->field( 'date' );
    $self->{processor}->{search}->add_field( fields => $date,
        value => '2021-01-',
        match => 'IN',
    );
    my $date_type= $ds->field( 'date_type' );
    $self->{processor}->{search}->add_field( fields => $date_type,
        value => 'published',
        match => 'EX',
    );

}

sub ajax_eprint
{
    my( $self ) = @_;

    my $repo = $self->repository;

    my $json = { data => [] };
    $repo->dataset( "eprint" )
        ->list( [$repo->param( "eprint" )] )
        ->map(sub {
            (undef, undef, my $eprint) = @_;

            return if !defined $eprint; # odd

            my $frag = $eprint->render_citation_link_staff;
            push @{$json->{data}}, {
                datasetid => $eprint->dataset->base_id,
                dataobjid => $eprint->id,
                summary => EPrints::XML::to_string( $frag ),
                #grouping => sprintf( "%s", $user->value( SOME_FIELD ) ),
                problems => [ $self->validate_dataobj( $eprint ) ],
                bullets => [ $self->bullet_points( $eprint ) ],
            };
        });
    print $self->to_json( $json );
}

sub validate_dataobj
{
    my( $self, $eprint ) = @_;

    my $repo = $self->{repository};

    my @problems;

    return @problems;
}


sub bullet_points
{
    my( $self, $eprint, $session ) = @_;

    my $repo = $self->{repository};

    my @bullets;

    # Existing selections
    my $selections = EPrints::DataObj::REF2029_Selection->search_by_eprintid( $repo, $eprint->id );
    my %existing_uoas;
    $selections->map(sub {
        my ($session, undef, $selection) = @_;
        $existing_uoas{$selection->value( "uoa" )} = 1;
        push @bullets, $selection->render_citation( "addselection_report" );
    });

    my @available_uoas = grep {not $existing_uoas{$_}} @{$self->{processor}->{user_uoas}};
 
    # Add new selection
    my $new_selection_frag = $repo->xml->create_document_fragment();
    my $new_selection_div = $new_selection_frag->appendChild( $repo->make_element( "div", class => "ref2029_new_selection_bullet" ) );  
    if( scalar @available_uoas > 0 )
    {
        my $new_selection_div = $new_selection_frag->appendChild( $repo->make_element( "div", class => "ref2029_new_selection_bullet" ) );  

        # UoA Dropdown
        $new_selection_div->appendChild( my $uoa_label = $repo->make_element( "label", for => "uoa" ) );
        $uoa_label->appendChild( $self->html_phrase( "uoa_for_selection" ) );

        my %labels;
        foreach my $uoa ( @available_uoas )
        {
            $labels{$uoa} = EPrints::DataObj::Subject->new( $repo, $uoa )->render_description;
        }
        $new_selection_div->appendChild($repo->render_option_list(
            name => 'uoa',
            values => \@available_uoas,
            labels => \%labels
        ) );

        # EPrint ID
        $new_selection_div->appendChild( $repo->render_hidden_field( "eprintid", $eprint->id ) );

        # Button
        my $new_selection_btn = $new_selection_div->appendChild( $repo->make_element( "input",
            class => "ep_form_action_button",
            type => "button",
            name => "new_selection",
            value => "Select for REF 2029",
        ) );

        $new_selection_div->appendChild( my $error_div = $repo->make_element( "div", class => "ref2029_new_selection_error" ) );
    }
    push @bullets, EPrints::XML::to_string( $new_selection_frag );


    return @bullets;
}
