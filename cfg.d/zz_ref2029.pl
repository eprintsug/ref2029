# Turn on the plugin
$c->{ref2029_enabled} = 1;

# Enabled the Screens
$c->{plugins}{"Screen::REF2029"}{params}{disable} = 0;
$c->{plugins}{"Screen::EPrint::REF2029"}{params}{disable} = 0;
$c->{plugins}{"Screen::REF2029::BenchmarkEdit"}{params}{disable} = 0;
$c->{plugins}{"Screen::REF2029::SelectionEdit"}{params}{disable} = 0;
$c->{plugins}{"Screen::REF2029_Review::Respond"}{params}{disable} = 0;
$c->{plugins}{"Screen::REF2029_Review::Acknowledge"}{params}{disable} = 0;

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

# REF2029 Reviews
use EPrints::DataObj::REF2029_Review;
$c->{datasets}->{ref2029_review} = {
    class => "EPrints::DataObj::REF2029_Review",
    sqlname => "ref2029_review",
};
