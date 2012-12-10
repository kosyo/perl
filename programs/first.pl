#!/usr/bin/perl -w

use strict;

my $message = "Hello, world! We're using Perl.";

print "Content-type:text/html\n\n";

print <<HTMLSTOP
<html>
<head>
<title>My First Web-Based Perl Script</title>
</head>
<body>
<h1>$message</h1>
HTML output in Perl is really easy.
</body>
</html>
HTMLSTOP
