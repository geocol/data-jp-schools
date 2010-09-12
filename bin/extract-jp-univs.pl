#!/usr/bin/perl
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->subdir ('lib')->stringify;
use lib glob file (__FILE__)->dir->parent->subdir ('modules/*/lib');
use utf8;
use Wikipedia::Ja::Schools;
use JSON;
binmode STDERR, ':utf8';

my $root_d = file (__FILE__)->dir->parent;
my $data_d = $root_d->subdir ('data');

my $current_d = $data_d->subdir ('schools')->subdir ('univ');
$current_d->mkpath;

{
  my $f = $current_d->file ('junior-colleges.json');
  my $file = $f->openw;
  
  my $s = Wikipedia::Ja::Schools->new;
  $s->load_text_from_cache (q[日本の短期大学一覧]);
  $s->parse_text;
  my $data = $s->as_hashref;
  print $file JSON->new->pretty->canonical->utf8->encode ($data);
}

{
  my $f = $current_d->file ('univs.json');
  my $file = $f->openw;
  
  my $all_data;
  {
    my $s = Wikipedia::Ja::Schools->new;
    $s->load_text_from_cache (q[東日本の大学一覧]);
    $s->parse_text;
    my $data = $s->as_hashref;
    $all_data = $data;
  }
  {
    my $s = Wikipedia::Ja::Schools->new;
    $s->load_text_from_cache (q[西日本の大学一覧]);
    $s->parse_text;
    my $data = $s->as_hashref;
    $all_data = {%$all_data, %$data};
  }

  print $file JSON->new->pretty->canonical->utf8->encode ($all_data);
}

__END__

=head1 AUTHOR

Wakaba <w@suika.fam.cx>.

=head1 LICENSE

Copyright 2010 Wakaba <w@suika.fam.cx>.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
