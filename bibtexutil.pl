#!/usr/bin/perl -w

use Text::BibTeX;
use Config::IniFiles;

#  print "The value is " . $cfg->val( 'Section', 'Parameter' ) . "."

#bibtexutil config

$num_args = $#ARGV + 1;
if ($num_args == 0) {
  print "\nUsage: bibtexutil.pl <options> COMMAND <command-parameter> <filter>\n";
  print "         bibtexutil.pl help\n";
  print "         bibtexutil.pl help <command>\n";
  exit;
}

if (lc($ARGV[0]) eq "help") {
    if($num_args == 1) {
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

if (-e "~/.bibtexutil/config.ini") {
    my $cfg = Config::IniFiles->new( -file => "~/.bibtexutil/config.ini" );

} 
else {
    
}

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

