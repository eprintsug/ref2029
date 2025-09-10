# Enable the Reports
$c->{plugins}{"Screen::Report::UoA"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::A01"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::A02"}{params}{disable} = 0;

$c->{plugins}{"Screen::Report::REF2029AddSelection"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::REF2029AddSelection"}{params}{custom} = 1;

$c->{search}->{ref2029_add_selection} = $c->{search}->{advanced};

# group by options
$c->{ref2029_add_selection}->{groupfields} = [ qw(
    divisions
    subjects
    type
    date;res=year;reverse_order=1
)];

# sort options for sorting within each group
$c->{ref2029_add_selection}->{sortfields} = {
    "byname" => "creators_name/-date/title",
    "byyear" => "-date/creators_name/title",
    "bytitle" => "title/creators_name/-date",
    "bydivision" => "divisions/creators_name/-date",
};

# export field options
$c->{ref2029_add_selection}->{exportfields} = {
    ref2029_add_selection=> [ qw(
        eprintid
        title
    )],
};

$c->{ref2029_add_selection}->{export_plugins} = [ qw( Export::Report::CSV Export::Report::HTML Export::Report::JSON )];
