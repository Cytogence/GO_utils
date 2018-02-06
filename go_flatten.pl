#!/usr/bin/perl

use warnings;
use strict;
use POSIX;
use utf8;

my ($file) = @ARGV;

die "No annotation file provided.\n" if not defined $file;

open( my $fh, "<", $file) or die "Unable to open $file\n";

my @filedata = <$fh>;
close($fh);

my %annotation = ();

for my $line (@filedata) {
	# check if line starts with !, and skip
	if (substr($line, 0, 1) eq '!') {
		next;
	}

	my @col = split '\t', $line;

	if ( exists $annotation{$col[2]}{annotation} ) {
		if (not $col[4] ~~ @{ $annotation{$col[2]}{GO} }) {
			push @{ $annotation{$col[2]}{GO} }, $col[4];
			print "Appended entry for $col[2] and $col[4]...\n";
		}
	} else {
		$annotation{$col[2]}{annotation} = $col[9];
		$annotation{$col[2]}{GO} = [ $col[4] ];
		print "Added new entry for $col[2] and $col[4]...\n";
	}
}

my @genes = keys %annotation;

my $outfile = $file.".flattened";

open($fh, ">", $outfile) or die "Unable to open $outfile\n";

my $count = 0;
my $total = scalar(@genes);

for my $gene (@genes) {

	my $per=ceil(($count/$total)*100); 
	print "\033[JStatus: ${per}% Completed."."\033[G";

	my $annot = $annotation{$gene}{annotation};
	my @GOs = @{ $annotation{$gene}{GO} };

	my $buff = "$gene\t$annot\t";

	for my $go (@GOs) {
		$buff.="$go\t";
	}
	
	chop $buff;

	print $fh "$buff\n";

	$count++;
}

print "\nComplete!\n";

close($fh);

