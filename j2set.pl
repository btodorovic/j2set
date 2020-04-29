#!/usr/bin/perl
#
# j2set.pl - Converts JUNOS bracket-style configuration into "display set" style
# Author   - Berislav Todorovic <btodorovic@juniper.net>
#

if ($ARGV[0]) {
    open ($input_fh, "<$ARGV[0]") || die "Could not open file $ARGV[0] for reading\n";
} else {
    print STDERR "No input file specified, expecting configuration from <STDIN>\n";
    $input_fh = STDIN;
}

while (<$input_fh>) {
    s/\r//g;
    s/^\s+//g;
    push (@lines, $_);
}

### - First - handle annotations  - e.g. /* Annotation */
$ann=0;
foreach (@lines) {
    if (/\/\*/ && /\*\//) {
	s/\/\*.*\*\///g;
        push (@chars, split(//));
	$ann=0;
	next;
    } elsif (/\/\*/) {
	s/\/\*.*$//g;
        push (@chars, split(//));
	$ann=1;
	next;
    } elsif (/\*\// && $ann) {
	s/^.*\*\///g;
        push (@chars, split(//));
	$ann=0;
	next;
    } elsif (!$ann) {
        push (@chars, split(//));
    }
}

### - Handle the rest
my $quote=0;		### Used to track quoted strings, to avoid excluding quoted strings
my $comment=0;		### Handle comments
$buffer=$prevchar='';
foreach (@chars) {
    if (/\n/) {
	$comment = 0;
	next;
    }    
    if (/\#/ && !$quote) {
	$comment = 1;
	next;
    }
    if ($comment) {
	next;
    }    
    if (/\"/) {
	$quote = !$quote;
        $buffer .= $_;
	next;
    }
    if (/\s/ && ($prevchar =~ /\s/) && !$quote) {
	next;
    }
    if (/\{/ && !$quote) {
	push (@config, $buffer);
	$buffer = '';
	next;
    }
    if (/\}/ && !$quote) {
	pop (@config);
	next;
    }
    if (/\;/ && !$quote) {
	print "set ";
	foreach $level (@config) {
	    print $level;
	}
	print "$buffer\n";
	$buffer = '';
	next;
    }
    $buffer .= $_;
    $prevchar = $_;
}
print "\n";
