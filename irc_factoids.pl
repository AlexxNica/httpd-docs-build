#!/usr/bin/perl
use XML::Simple;
use Getopt::Std;
use Data::Dumper;
use strict;

our ( $opt_m, $opt_v, $opt_f );
our $VERSION = '0.01';

getopts("fm:v:");
HELP_MESSAGE('The -m option is required.') unless $opt_m;

$opt_m =~ s/\.xml$//;
HELP_MESSAGE('File '. $opt_m . '.xml not found.') unless -f $opt_m . '.xml';

my $file = $opt_m . '.xml';

my $xs = XML::Simple->new();
my $xml = $xs->XMLin( $file );

print "forget $opt_m\n" if $opt_f;
print "$opt_m is " . 'http://httpd.apache.org/docs/' . ( $opt_v ? $opt_v : 'current' ) . '/mod/' . $opt_m .  '.html' . "\n\n";

my $directives = $xml->{directivesynopsis};

my %directives;
# Was there more than one?
if ( $directives->{name} ) { # There was only one
   %directives = ( $directives->{name} => $directives ); 
} else { # More than one
    %directives = defined( $xml->{directivesynopsis} ) ? %{ $xml->{directivesynopsis} } : () ;
}

foreach my $directive ( sort( keys %directives ) ) {

    my $d = $directives{$directive};

    my $desc = $d->{description}; 
    $desc =~ s/[\r\n]/ /gs;
    my $name = $directive . ( $opt_v ? " $opt_v" : '' );

    print "forget $name\n" if $opt_f;
    print "$name is ";
    print 'http://httpd.apache.org/docs/' . ( $opt_v ? $opt_v : 'current' ) . '/mod/' . $opt_m .  '.html#' . lc( $directive );
    if ( $desc ) {
        print " - " . $desc;
    }
    print "\n";


    print "forget $name default\n" if $opt_f;
    if ( $d->{default} ) {
        print "$name default is " . $d->{default} . "\n";
    } else {
        print "$name default is <reply>$name has no default value\n";
    }

    print "forget $name override\n" if $opt_f;
    if ( $d->{override} ) {
        print "$name override is <reply>$name may be used in an .htaccess file if AllowOverride is set to ".$d->{override}."\n";
    } else {
        print "$name override is <reply>$name may not be used in a .htaccess file\n";
    }

    print "forget $name context\n" if $opt_f;
    print "$name context is <reply>$name may be used in the following contexts: ";
    my $contexts = ref( $d->{contextlist}->{context} ) ?  $d->{contextlist}->{context} : [ $d->{contextlist}->{context} ];
    print ( join ', ', @{ $contexts } ) . "\n";
    print "\n\n";

}
print "\n";

sub HELP_MESSAGE {
    print shift;
    print STDERR qq~

Usage: 

cd manual/mod
$0 -m mod_rewrite

Outputs IRC factoids for the directives in this module, which can then
be fed to the IRC bot.

-m mod_foo - Run for mod_foo.

-v version - Generate URLs for this version. Defaults to "current"

-f Adds the 'forget' statements to make the bot forget the existing version of the factoid.

~;

    exit();
}


