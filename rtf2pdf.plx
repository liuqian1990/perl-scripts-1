#!/usr/bin/perl -w

# script to run unrtf on a Rich Text File

# usage: 
#
# (c)2003 Brian Manning

# external modules
use Getopt::Std;
use strict;

# variables
my $DEBUG; # are we debugging?
my %opts; # command line options hash
my @filelist; # list of files, built with glob or a real list of files
my ($file, $newname); # a file from @filelist, new file name
my @splitname; # full path split up
my $unrtf="/usr/bin/unrtf";
my $read; # read in variable, not used for anything

	### begin script ###
	
	# get the command line switches
	&getopts("dhlCve:f:p:w:", \%opts);

	if ( exists $opts{h} ) {
		warn "Usage: rtf2pdf.plx [options]\n";
		warn "[options] consist of:\n";
		warn " -h show this help list\n";
		warn " -d Debug mode - Doesn't do anything destructive.  " . 
			"Automagically sets -v\n";
		warn " -v Verbose mode - extra noisy\n";
		warn " -w word to replace in the filename " . 
			" (cannot be combined with -f)\n";
		warn " -C be case sensitve in matching words to replace\n";
		warn " -f filename containing a list of files to parse/rename\n";
		warn " -e filename extension to match when not using a filelist\n";
		warn " -p path to files when not using a filelist\n";
		warn " -l just lowercase the filenames found with -e and -p\n";
		# exit out
		exit 0;
	} # if ( exists $opts{h} )
	
	# was a filename extension passed in?
	if ( exists $opts{e} && exists $opts{p} ) {	
		@filelist = <$opts{p}/*.$opts{e}>;
	} elsif ( exists $opts{f} ) {
		open (LIST, $opts{f});
		@filelist = <LIST>;
		close (LIST);
	} else {
		die "Please pass either a -f (list of files) or a -p (path) and " .
			"-e (extension)\nto filter a specific set of files";
	} # if ( exists $opts{e} && exists $opts{p} )

	foreach $file (@filelist) {
		chomp($file);
 		if ( $opts{d} || $opts{v} ) { warn "Stripping $file\n";}
		# split the full filename, this is so we don't do strange shit to the
		# path
		@splitname = split("/", $file);
		chomp(@splitname);
		# copy the old name over to $newname
		$newname = $splitname[-1];
		if ( $opts{d} || $opts{v} ) { warn "original filename is $newname\n";}
		# is there a file extension?
		if ( exists $opts{e} ) {
			#if ( ! exists $opts{w} ) { $opts{w} = "";}
			# are we just lowercasing the filename?
			if ( $opts{l} ) {
				$newname = lc($splitname[-1]);
			# no, we're case-sensitive matching on a pattern
			} elsif ( $opts{C} ) {
				$newname =~ s/$opts{w}//;
			# no, we're case-insensitve matching on a pattern
			} else {
				if ( exists $opts{w} ) { $newname =~ s/$opts{w}//i; }
			} # if ( $opts{C} )
		} # if ( exists $opts{e} )

		# replace the extension to match the output filename
		$newname =~ s/rtf$/pdf/gi;
		
		# do some other misc name munging
		$newname =~ s/&/-n-/g;
		$newname =~ s/ /_/g;
		$splitname[-1] = $newname;

		if ( $opts{v} || $opts{d} ) { 
			warn "renaming $file\nto " . join("/",@splitname);
		} # if ( $opts{v} )
		system("$unrtf -t ps $file | ps2pdf - $newname");
		if ( $opts{d} ) {
			warn "unrtf conversion complete; hit <ENTER> to continue\n";
			$read = <STDIN>;
		} # if ( $opts{d} )
	} # foreach
