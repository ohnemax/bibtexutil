#!/usr/bin/perl -w

use Text::BibTeX;
use Config::IniFiles;
use Getopt::Long;

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
# && / || for separation + brackets


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

