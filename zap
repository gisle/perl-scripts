#!/local/bin/perl
'di';
'ig00';

# Interactive process killer.
# $Id$

# $Log$
# Revision 1.2  1990-11-06 13:22:04  aas
# checked in with -k by aas at 1992/07/30 13:29:01
#
# Revision 1.2  90/11/06  13:22:04  aas
# Real manual page now included with the script.
# 
# Revision 1.1  90/11/06  12:44:27  aas
# Zap doesn't get confused about wrapping PIDs. New option -f
# 
# Revision 1.0  90/09/27  14:53:49  aas
# Initial revision
# 
# 

# First index in arrays is set to 1
$[ = 1;

# If you know a better way to obtain the signal names; please let me
# know. I think that the signal names ougth to be predefined in the
# assosiative array %SIG. They are not (at least in the version of
# perl that I use).
@sigs = split(/[ \t\n]+/,`/bin/kill -l`);

# Parse commandline arguments.
$prog = substr($0,rindex($0,'/')+1,14);	 # remove path from program name

$sig = "SIGTERM";		         # set $sig to default; signal 14
while (($_ = shift) && s/^-//) {         # are there any command line arguments
   tr/a-z/A-Z/;                          # convert to upper case
   if (/^(\d+)$/ && defined($sigs[$1])){ # the signal is specified as a number
       $sig = "SIG" . $sigs[$1];
   }				         # the signal name is used?
   elsif (/^(SIG)?/ && grep($' eq $_,@sigs)) {
       $sig = $_;
       $sig = "SIG" . $sig unless ($sig =~ /^SIG/);
   }
   elsif (/^F$/) {
       $forced_killing = 'true';
   }
   else {
      print STDERR "Usage: $prog [-f] [-<signal>] [pattern]\n";
      exit;
   }
}
$pattern = $_;
print STDERR "$prog: additional patterns ignored\n" if (shift);

# Then process the list produced by the ps(1) command
($ps_pid = open(ps,"ps -xgc|")) || die "Can't run ps(1)";
while (<ps>) {
   next if (length($pattern) && !/$pattern/);
   if (/(\d+).*\b(.+)$/ && $1 != $$ && $1 != $ps_pid) {
       printf " kill %s$1 ($2)", $sig ne "SIGTERM" ? "-$sig,":"";
       unless ($forced_killing) {
	   print " ? "; $answer = <STDIN>;
           chop $answer; $answer =~ tr/A-Z/a-z/;
       } else { print "\n"; }
       if ($forced_killing || $answer eq "y" || $answer eq "yes" ) {
             kill $sig,$1;
       }
   }
}


###########################################################################
	# These next few lines are legal in both Perl and nroff.

.00;			# finish .ig
 
'di			\" finish diversion--previous line must be blank
.nr nl 0-1		\" fake up transition to first page again
.nr % 0			\" start at page 1
';<<'.ex'; #__END__ #### From here on it's a standard manual page #########
.TH ZAP 1 "October 1990"
.SH NAME
zap \- interactive process killer
.SH SYNOPSIS
.B zap
[
.B \-f
] [
.B \-signo
|
.B \-signame
] [
.B pattern
]
.SH DESCRIPTION
.B Zap
is an extended kill command. 
The user is
interactively asked about killing the processes that match the
.I pattern.
If she answers 'y' or 'yes' the process is
killed. 
If a signal name or number preceded by
.RB ` \- '
is given as argument, that signal is sent instead of
.SB SIGTERM
(terminate, 15).

.SH OPTIONS
.TP 5
.B \-f
Force processes to be killed without asking for confirmation. The effect
of this option is the same as answering 'yes' to all questions.
.SH SEE ALSO
.BR perl (1),
.BR kill (1),
.BR yes (1)
.SH BUGS
None :-)
.SH AUTHOR
Gisle Aas, Norwegian Computing Center (NR), Oslo, Norway.
<Gisle.Aas@nr.no>
.ex
