#!/usr/bin/perl -w

use Text::BibTeX;
use Config::IniFiles;
use Getopt::Long;
use Regexp::Grammars;

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
	   "d|directory=s" => \$option_filedirectory, 
	   "i|inputfile=s" => \$option_bibtexfile
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

# get filter

while(shift @ARGV ne "filter") {}

$filter_string = "";
while($part = shift @ARGV) {
    $filter_string .= " " . $part;
}

print $filter_string, "\n";
# and / or for separation + brackets, ! is working as well
# CAREFUL: Wrong recursion...

my $filter_parser = qr{ 
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
    [\.\*\\\s\w]+

    <token: Literal>
        <MATCH=(  \w+=[\.\*\\\s\w]+  )>
    }xms;

if ($filter_string =~ $filter_parser) {
    print "haha\n";
    use Data::Dumper 'Dumper';
    print Dumper \%/;
}


# Read configuration from file, otherwise check for .bib file in current directory
if (-e "~/.bibtexutil/config.ini") {
    my $cfg = Config::IniFiles->new( -file => "~/.bibtexutil/config.ini" );

} 
else {
    #check for .bib file in current directory
}

# Overrule configuration by options (pre-set above)
if($option_bibtexfile) {
    print $option_bibtexfile, "\n";
}
if($option_filedirectory) {
    print $option_filedirectory, "\n";
}

# Open Bibtexfile
my $bibfilename = "/home/darkarchon/Documents/Texte/kuett_bibliography.bib";

$bibfile = new Text::BibTeX::File $bibfilename;

while ($entry = new Text::BibTeX::Entry $bibfile)
{
    next unless $entry->parse_ok;
    
    next unless $entry->exists('ranking');

    if($entry->get('ranking') eq "rank3") {
	print $entry->get('author'), "\n";
	
    }

}

