#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);
use LWP::Simple;
use YAML::Tiny;
use JSON;
use URI;
use utf8;

my $access_token = '-------------------------------------------------------------------------';
print "Content-type:text/html\n\n";

my $resp = graph_api('me/home', { access_token => $access_token });
for my $post (@{ $resp->{data} }) {
  print Dump($post);
}

graph_api('me/feed', {
  access_token => $access_token,
  message      => 'Hello World!',
  link         => 'http://applause-voice.com/wp-content/uploads/2011/04/1hello.jpg',
  picture      => 'http://applause-voice.com/wp-content/uploads/2011/04/1hello.jpg',
  name         => 'Hello World!',
  caption      => 'applause-voice.com/wp-content/uploads/2011/04/1hello.jpg',
  description  => 'Hello World!',
  method       => 'post'
});

exit 0;

sub graph_api {
  my $uri = new URI('https://graph.facebook.com/' . shift);
  $uri->query_form(shift);
  my $resp = get("$uri");
  return defined $resp ? decode_json($resp) : undef;
}
