# Turn on the plugin
$c->{ref2029_enabled} = 1;

# Enabled the Screens
$c->{plugins}{"Screen::REF2029"}{params}{disable} = 0;
$c->{plugins}{"Screen::EPrint::REF2029"}{params}{disable} = 0;
$c->{plugins}{"Screen::REF2029::BenchmarkEdit"}{params}{disable} = 0;
$c->{plugins}{"Screen::REF2029::SelectionEdit"}{params}{disable} = 0;
$c->{plugins}{"Screen::REF2029_Review::Respond"}{params}{disable} = 0;

# REF2029 Benchmarks
use EPrints::DataObj::REF2029_Benchmark;
$c->{datasets}->{ref2029_benchmark} = {
    class => "EPrints::DataObj::REF2029_Benchmark",
    sqlname => "ref2029_benchmark",
};

# REF2029 Selections
use EPrints::DataObj::REF2029_Selection;
$c->{datasets}->{ref2029_selection} = {
    class => "EPrints::DataObj::REF2029_Selection",
    sqlname => "ref2029_selection",
};

# REF2029 Selection Fields
$c->add_dataset_field( 'ref2029_selection', { name => "date", type => "date", required => 1, }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "type", type => "set", options=>[qw( A B C D E F G H I J K L M N O P Q R S T U V )], required => 1 }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "title", type => "text", required => 1, }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "hesa", type => "id", required => 1, }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "doi", type => "id", required => 0, }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "former_staff", type => "boolean", required => 1, }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "pre_pub_link", type => "boolean", required => 1, }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "open_access", type => "set", options=>[qw( oa ex non_compliant )], required => 1, }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "uoa", type => "subject", top => "ref2029_uoas" , required => 1, render_path => 0 }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "xref", type => "subject", top => "ref2029_uoas" , required => 1, }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "research_group", type => "text", required => 0, }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "research_specialism", type => "longtext", required => 0, }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "num_co_authors", type => "int", required => 0, }, reuse => 1 );

##### Requires further clarification for Research England #####
#$c->add_dataset_field( 'ref2029_selection', { name => "disc_flags", type => ??? }, reuse => 1 );

$c->add_dataset_field( 'ref2029_selection', { name => "abstract", type => "longtext", required => 0 }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "pending_pub", type => "boolean", required => 1 }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "multi_weight", type => "int", required => 0 }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "reserves", type => "itemref", datasetid => 'ref2029_selection', multiple => 1, required => 0 }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "supplementary_url", type => "url", required => 0 }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "confidential", type => "longtext", required => 0 }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "reviews", type => "subobject", datasetid => 'ref2029_review', multiple => 1, dataobj_fieldname => 'selectionid', dataset_fieldname => '' }, reuse => 1 );
$c->add_dataset_field( 'ref2029_selection', { name => "rating", type => "set", required => 1, input_rows => 1, options => [qw( NONE 0 1 2 3 4 )] }, reuse => 1 );


# REF2029 Reviews
use EPrints::DataObj::REF2029_Review;
$c->{datasets}->{ref2029_review} = {
    class => "EPrints::DataObj::REF2029_Review",
    sqlname => "ref2029_review",
};

# New User Fields
$c->add_dataset_field( 'user', { name => 'ref2029_uoa', type => 'subject', top => 'ref2029_uoas' }, reuse => 1 );

$c->add_dataset_field( 'user', { name => 'ref2029_uoa_champion', type => 'subject', top => 'ref2029_uoas', multiple => 1 }, reuse => 1 );


# Extra User Functionality
{
    package EPrints::DataObj::User;

    # Permission to use UoA?
    sub ref2029_uoa_in_scope
    {
        my( $self, $uoa ) = @_;
       
        my @user_uoas = @{$self->value( "ref2029_uoa_champion" )};
        if( grep { $uoa eq $_ } @user_uoas )
        {
            return 1;
        }
        else
        {
            return 0;
        }

    }
}
