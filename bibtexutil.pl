#!/usr/bin/perl -w

use Text::BibTeX;
use Config::IniFiles;
use Getopt::Long;
#use Regexp::Grammars;

sub recursive_query {
    my $bibentry = shift;
    my $statement = shift;
    my $resy = 0;
    my $resx = 0;
    my $fieldvalue = "";

    if(exists $statement->{Op}) {
	$resx = recursive_query($bibentry, $statement->{condx});
	$resy = recursive_query($bibentry, $statement->{condy});
	if($statement->{Op} eq "and") {
	    return ($resx && $resy);
	}
	if($statement->{Op} eq "or") {
	    return ($resx || $resy);
	}
    }
    elsif(exists $statement->{Condition}) {
	if(exists $statement->{Sign} and $statement->{Sign} eq "!") {
	    return not recursive_query($bibentry, $statement->{Condition});	    
	}
	else {
	    return recursive_query($bibentry, $statement->{Condition});	    
	}
    }
    elsif(exists $statement->{Answer})
    {
	if(exists $statement->{Sign} and $statement->{Sign} eq "!") {
	    return not recursive_query($bibentry, $statement->{Answer});	    
	}
	else {
	    return recursive_query($bibentry, $statement->{Answer});	    
	}
    }
    else {
	if($entry->exists($statement->{field})) {
	    $fieldvalue = $entry->get($statement->{field});
	    $fieldvalue =~ s/^\s+//;
	    $fieldvalue =~ s/\s+$//;
	    $testvalue = $statement->{expression};
	    $testvalue =~ s/^\s+//;
	    $testvalue =~ s/\s+$//;

	    if($fieldvalue eq $testvalue) {
		return 1;
	    }
	    else {
		return 0;
	    }
	}
	else {
	    return 0;
	}
	return 1;
    }
}

my $version = "0.01";
#  print "The value is " . $cfg->val( 'Section', 'Parameter' ) . "."

#Arguments and Options to command

#Possible Commands and specific help
my %commands = (
    "extract" => 'Extract new .bib Library\n
Can be used with filters.
The path to the new .bib library file has to be given as additional parameter

Example:
bibtexutil.pl extract somefiles.bib filter "author=kuett"
',
    "copy-attachements" => 'Copy files attached to entries
',
    "field-rename" => '
',
    "field-delete" => '
',
    "field-add" => '
',
    "value-replace" => '
',
    "parse" => '
',
    "bibtex2biblatex" => '
',
    "biblatex2bitex" => '
',
    "configure" => '
'
    );

#Options first
GetOptions("version|v" => \$option_version, 
	   "d|directory=s" => \$option_bibfolder, 
	   "i|inputfile=s" => \$option_bibfilename
);

# version is easy to deal with...
if( $option_version ) {
    print $version, "\n";
    exit;
}

#Now remaining Arguments
$num_args = $#ARGV + 1;
if ($num_args == 0) {
    print "bibtexutil.pl Version: $version\n";
    print "Usage: bibtexutil.pl [<options>] COMMAND [<command-parameter>] [filter <filter-parameter>]\n";
    print "       bibtexutil.pl help\n";
    print "       bibtexutil.pl help <command>\n";
    exit;
}

if (lc($ARGV[0]) eq "help") {
    if($num_args == 1) {
	print "bibtexutil.pl Version: $version\n";
	print "Usage: bibtexutil.pl [<options>] COMMAND [<command-parameter>] [filter <filter-parameter>]\n";
	print "       bibtexutil.pl help\n";
	print "       bibtexutil.pl help <command>\n";
	print "\n";
	print "Possible Options\n";
	print "-i | --inputfile <filename>\tSpecify .bib file as inputfile.\n";
	print "-d | --directory <directory>\tSpecify directory that contains attached files.\n";
	print "-v | --version\t\t\tShow bibtexutil.pl version.\n";
	print "\n";
	print "Possible Commands\n";
	print "\n";
	print "extract\t\t\tExtract new .bib Library (*)\n";
	print "copy-attachements\tCopy files attached to entries (*)\n";
	print "field-rename\t\tRename field (*)\n";
	print "field-delete\t\tDelete field (and values!) (*)\n";
	print "field-add\t\tAdd field (*)\n";
	print "value-replace\t\tReplace specific value (*)\n";
	print "\n";
	print "parse\t\t\tParse file and check for syntax errors\n";
	print "bibtex2biblatex\t\tConvert file specification from Bibtex to Biblatex standard.\n";
	print "biblatex2bibtex\t\tConvert file specification from Biblatex to Bibtex standard.\n";
	print "\n";
	print "configure\t\tInteractive configuration for bibtexutil.pl\n";
	print "\n";
	print "\n";
	print "On filtering (commands with (*) can use filter):\n";
	print "After the keyword filter, conditions can be specified. The .bib 
file is filtered for these. Every condition has to be specified 
with <fieldname>=<value>.
<fieldname> is case-insensitive. <value> has only a single 
wildcard '*' which can stand anywhere and for any number of 
any character. It is possible to use a regular expression 
for the search, than <value> has to start and end with '/'. 
Conditions can be combined using the keyword 'and' and 'or'. 
Parenthesis ('(' and ')') may be used to order the logical 
expression.
ATTENTION: While not using parenthesis, expressions are read 
from the right side (e.g. 'year=2010 or year=2011 and author=kuett' 
is treated as 'year=2010 or (year=2011 and author=kuett)').\n";
	print "\n";

    }
    else {
	if(exists $commands { $ARGV[1] }) {
	    print "Help for ", $ARGV[1], "\n";
	    print $commands { $ARGV[1] };
	}
	else {
	    print "Command does not exist!\n";
	    print "Show list of commands with: bibtexutil.pl help\n";
	}
    }
    exit;
}

# get command + parameters
my @parameters;
my $command;

if($#ARGV + 1 != 0) {
    $command = $ARGV[0];
    if(exists $commands { $command }) {
	while($parameter = shift @ARGV) {
	    if($parameter eq "filter") {
		$filterkeyword = 1;
		last;
	    }
	    push(@parameters, $parameter);
	}
    }
    else {
	print "Error: Command " . $command . " does not exist.\n";
	print "Show list of commands with: bibtexutil.pl help\n";
	exit;
    }
}

# get filter
if($#ARGV + 1 != 0) {
    $filter_string = "";
    while($part = shift @ARGV) {
	$filter_string .= " " . $part;
    }
    $filterpresent = 1;
    $filter_string =~ s/^ //;
}
else {
    if($filterkeyword) {
	print "Error: If you use the keyword 'filter' you should give some filter parameters!\n";
	print "Help for filter is given with: bibtexutil.pl help\n";
	exit;
    }
    $filter_string = "";
    $filterpresent = 0;
}

# and / or for separation + brackets, ! is working as well
# CAREFUL: Wrong recursion...

my $filter_parser = do {
    use Regexp::Grammars;
    qr{
        <Answer>

        <rule: Answer>
            <condx=Term> <Op=(or|and)> <condy=Answer>
          | <MATCH=Term>

        <rule: Term>
            <MATCH=Condition>
          | <Sign=([!]?)> \( <Answer> \)
          | <Sign=([!]?)> <Condition>
          | \( <MATCH=Answer> \)

    <rule: Condition>
    <field>=<expression>

    <rule: field>
    [\w]+

    <rule: expression>
    [\.\*\\\s\w/]+

    <token: Literal>
        <MATCH=(  \w+=[\.\*\\\s\w]+  )>
    }xms;
};

if ($filter_string =~ $filter_parser) {
    $filter_array = \%/;
    use Data::Dumper 'Dumper';
#    print %{$filter_array} , "\n";
#    print $filter_array->{Answer}->{Op}, "\n";
    print Dumper @$filter_array{'Answer'};
}



#Configuration variables
my $bibfilename = "";
my $bibfolder = "";
my $bibfolderpresent = 0;
my $cfg;

# Read configuration from file, otherwise check for .bib file in current directory
if (-e $ENV{"HOME"} . "/.bibtexutil/config.ini") {
    $cfg = Config::IniFiles->new( -file => $ENV{"HOME"} . "/.bibtexutil/config.ini" );
    if($cfg->exists("bibtexutil", "bibfilename")) {
	$bibfilename = $cfg->val("bibtexutil", "bibfilename");
    }
    else {
	print "Error: Incomplete config file exists. Use 'bibtexutil.pl configure' or manual edit to fix it.\n";
	exit;
    }
    if($cfg->exists("bibtexutil", "bibfolder")) {
	$bibfolder = $cfg->val("bibtexutil", "bibfolder");
	$bibfolderpresent = 1;
    }
    else {
	$bibfolderpresent = 0;
    }
} 
else {
    #check for .bib file in current directory
}


# Overrule configuration by options (pre-set above)
if($option_bibfilename) {
    print $option_bibfilename, "\n";
}
if($option_bibfolder) {
    print $option_bibfolder, "\n";
}

$bibfile = new Text::BibTeX::File;
$bibfile->open($bibfilename, "r");

if($command eq 'extract') {
    if($#parameters != 1) {
	print "Error: extract needs specification of output .bib file as parameter.\n";
	exit;
    }
    else {
	$outputfilename = $parameters[1];
	$outputfile = new Text::BibTeX::File;
	if(-e $outputfilename) {
	    print "The specified output file already exists. Overwrite? (y/[n]): ";
	    $yesno = <>;
	    chomp $yesno;
	    if ($yesno eq "") {
		$yesno = "n";
	    }
	    while(($yesno ne "y") and ($yesno ne "n")) {
		print "Please answer 'y' for yes or 'n' for no: ";
		$yesno = <>;
		chomp $yesno;
		if($yesno eq "") {
		    $yesno = "n";
		}
	    }
	    if($yesno eq "n") {
		exit;
	    }
	    else {
		$outputfile->open($outputfilename, "w");
	    }
	}
	else {
	    $outputfile->open($outputfilename, "w");
	}


	while ($entry = new Text::BibTeX::Entry $bibfile)
	{
	    next unless $entry->parse_ok;
	    if (recursive_query($entry, @$filter_array{'Answer'})) {
		$entry->write($outputfile);
		print "Match: " . $entry->key() . " has been extracted to outputfile.\n";
	    }
	}	

	$outputfile->close();
	print "extract\n"; 	
    }
}
elsif ($command eq 'field-rename') { 
    print "Not yet implemented\n";
    exit;
}
elsif ($command eq 'field-delete') { 
    print "Not yet implemented\n";
    exit;
}
elsif ($command eq 'field-add') { 
    print "Not yet implemented\n";
    exit;
}
elsif ($command eq 'value-replace') { 
    print "Not yet implemented\n";
    exit;
}
elsif ($command eq 'parse') { 
    print "Not yet implemented\n";
    exit;
}
elsif ($command eq 'bibtex2biblatex') { 
    print "Not yet implemented\n";
    exit;
}
elsif ($command eq 'biblatex2bibtex') { 
    print "Not yet implemented\n";
    exit;
}
elsif ($command eq 'configure') { 
    print "Configuration of bibtexutil will be written in ~/.bibtexutil/config.ini\n";
    if (-e $ENV{"HOME"} . "/.bibtexutil/config.ini") {
	print "It seems that there is a file already. The following questions let you change values\n";
    }
    print "\n";
    print "Default .bib inputfile [" . $bibfilename . "]: ";
    $newfilename = <>;
    chomp $newfilename;
    if($newfilename eq "") {
	$newfilename = $bibfilename;
    }
    while(!(-e $newfilename)) {
	print "Error: No file exists with the given filename.\n";
	print "Default .bib inputfile [" . $bibfilename . "] :";
	$newfilename = <>;
	chomp $newfilename;
	if($newfilename eq "") {
	    $newfilename = $bibfilename;
	}
    }
    $yesno = "";
    while(($yesno ne "y") and ($yesno ne "n")) {
	if($bibfolderpresent == 1) {
	    $yesno = "([y]/n)";
	    $defaultanswer = "y";
	}
	else {
	    $yesno = "(y/[n])";
	    $defaultanswer = "n";
	}
	print "Do you want to add an directory with attached files? " . $yesno . ": ";
	$yesno = <>;
	chomp $yesno;
	if($yesno eq "") {
	    $yesno = $defaultanswer;
	}
    }
    if($yesno eq "y") {
	print "Default path for attached files [" . $bibfolder . "]: ";
	$newfolder = <>;
	chomp $newfolder;
	if($newfolder eq "") {
	    $newfolder = $bibfolder;
	}
	while(!(-e $newfolder)) {
	    print "Error: No folder exists with the given path.\n";
	    print "Default path for attached files [" . $bibfolder . "]: ";
	    $newfolder = <>;
	    chomp $newfolder;
	    if($newfolder eq "") {
		$newfolder = $bibfolder;
	    }
	}
	$bibfolderpresent = 1;
    }
    else {
	print "No path for attached files needs to be selected\n";
	$bibfolderpresent = 0;
    }
    $bibfilename = $newfilename;
    $bibfolder = $newfolder;
    if (-e $ENV{"HOME"} . "/.bibtexutil/config.ini") {
	$cfg = Config::IniFiles->new( -file => $ENV{"HOME"} . "/.bibtexutil/config.ini" );
	if($cfg->exists("bibtexutil", "bibfolder") && $bibfolderpresent == 0) {
	    $cfg->delval("bibtexutil", "bibfolder");
	}
	if($bibfolderpresent == 1 && !$cfg->exists("bibtexutil", "bibfolder")) {
	    $cfg->newval("bibtexutil", "bibfolder", $bibfolder);
	}
	if($bibfolderpresent == 1) {
	    $cfg->setval("bibtexutil", "bibfolder", $bibfolder);
	}
	$cfg->setval("bibtexutil", "bibfilename", $bibfilename);
	$cfg->RewriteConfig();
    }
    else {
	if(!(-e $ENV{"HOME"} . "/.bibtexutil/")) {
	    mkdir $ENV{"HOME"} . "/.bibtexutil";
	}
	$cfg = Config::IniFiles->new(  );	
	$cfg->SetFileName($ENV{"HOME"} . "/.bibtexutil/config.ini");
	$cfg->newval("bibtexutil", "bibfilename", $bibfilename);
	if($bibfolderpresent == 1) {
	    $cfg->newval("bibtexutil", "bibfolder", $bibfolder);
	}
	$cfg->WriteConfig($ENV{"HOME"} . "/.bibtexutil/config.ini") || die "write not possible";
    }

    print "New configuration settings have been written to file.\n";
    exit;
}

$bibfile->close();

