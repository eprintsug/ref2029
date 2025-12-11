# Enable the Reports
$c->{plugins}{"Screen::Report::UoA"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::A01"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::A02"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::A03"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::A04"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::A05"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::A06"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::B07"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::B08"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::B09"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::B10"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::B11"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::B12"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::C13"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::C14"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::C15"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::C16"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::C17"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::C18"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::C19"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::C20"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::C21"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::C22"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::C23"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::C24"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::D25"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::D26"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::D27"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::D28"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::D29"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::D30"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::D31"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::D32"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::D33"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::D34"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::UoA::Z"}{params}{disable} = 0;

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
