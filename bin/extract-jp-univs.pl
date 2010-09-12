#!/usr/bin/perl
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->subdir ('lib')->stringify;
use lib glob file (__FILE__)->dir->parent->subdir ('modules/*/lib');
use utf8;
use MediaWikiXML::PageExtractor;
use Wikipedia::Ja::Schools;
use JSON;
binmode STDERR, ':utf8';

my $root_d = file (__FILE__)->dir->parent;
my $data_d = $root_d->subdir ('data');

my $current_d = $data_d->subdir ('schools')->subdir ('univ');
$current_d->mkpath;

{
  my $f = $current_d->file ('special-univs.json');
  my $file = $f->openw;
  
  my $p = MediaWikiXML::PageExtractor->get_text_from_cache (q[大学校]) or die;
  if ($p =~ /\n\{\|.+?学位を取得できる大学校一覧(.+?)\n\|\}\n/s) {
    my $table = $1;
    my $data = {};
    for (split /\n/, $table) {
      if (/\[\[(\S*大学校)\]\]/) {
        my $name = $1;
        my $props = {
        ## Source: Wikipedia
          '防衛大学校' => {
            abbr_name => '防衛大',
            location_area => '神奈川県',
          },
          '防衛医科大学校' => {
            abbr_name => '防衛医大',
            location_area => '埼玉県',
          },
          '海上保安大学校' => {
            abbr_name => '海保大',
            location_area => '広島県',
          },
          '気象大学校' => {
            abbr_name => '気大校',
            location_area => '千葉県',
          },
          '国立看護大学校' => {
            location_area => '東京都',
          },
          '水産大学校' => {
            abbr_name => '水大校',
            location_area => '山口県',
          },
          '職業能力開発総合大学校' => {
            abbr_name => '職業大',
            location_area => '神奈川県',
          },
        }->{$name} || {};
        $data->{$name} = $props;      }
    }
    print $file JSON->new->pretty->canonical->utf8->encode ($data);
  }
}

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
