#!/usr/bin/perl -w

use warnings;
use Regexp::Grammars;

my $text = '((((!((cond1) || (cond2) || (cond3)) && (cond4))) && (cond5)) <= (((cond6) || (cond7) || (cond8)) || (cond9)))';

my $text2 = "( asdf=asdf ( cond2 cond3 ))";

#$text2 = "asdf=awer";

my $grammar = qr{
<parent_pair> | <condition>

<rule: parent_pair>
\(  (?:  <parent_pair> | <condition> |  [^()] )*  \)

<rule: condition>
[^][(.*)]+

}xms;

    if ($text2 =~ $grammar) {
	use Data::Dumper;
	$Data::Dumper::Indent = 1;
	$Data::Dumper::Sortkeys = 1;
	print Dumper \%/;
    }

my $operator = qr{
    <operation>

    <rule: operation>
    (?: <condition>+ %<op> | <uop> <condition> )*

    <rule: op>
    or|and

    <rule: uop>
    \!

    <rule: condition>
    .*

    }xms;

my $text3 = "asdfas or asdfs";
    if ($text3 =~ $operator) {
	use Data::Dumper;
	$Data::Dumper::Indent = 1;
	$Data::Dumper::Sortkeys = 1;
	print Dumper \%/;
    }

my $calculator = qr{ 
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



    if ("(as and ( or 5)) or ( 5 and 7 )" =~ $calculator) {
        use Data::Dumper 'Dumper';
        warn Dumper \%/;
    }

print $ARGV[0], "\n";

    if ($ARGV[0] =~ $calculator) {
        use Data::Dumper 'Dumper';
        warn Dumper \%/;
    }
