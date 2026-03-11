package EPrints::DataObj::REF2029_Benchmark;

our @ISA = qw( EPrints::DataObj );

use strict;
use Data::Dumper;

# The new method can simply return the constructor of the super class (Dataset)
sub new
{
    return shift->SUPER::new( @_ );
}

sub get_system_field_info
{
    my( $class ) = @_;

    return
    (
        { name => "ref2029_benchmarkid", type => "counter", required => 1, import => 0, show_in_html => 0, can_clone => 0, sql_counter => "ref2029_benchmarkid" },

        { name => "title", type => "text", required => 1, },

        { name => "status", type => "set", options => [qw(active inactive)], required => 1, },
    );       
}

sub get_dataset_id
{
    my ($self) = @_;
    return "ref2029_benchmark";
}

=item my $benchmark = EPrints::DataObj::REF2029_Benchmark->active( $session );

Returns the active Benchmark

=cut
sub active
{
    my( $class, $repo ) = @_;

    return $repo->dataset( $class->get_dataset_id )->search(
        filters => [
            { meta_fields => [qw( status )], value => "active", },
        ])->item( 0 );
}
