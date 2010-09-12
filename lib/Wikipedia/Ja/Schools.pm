package Wikipedia::Ja::Schools;
use strict;
use warnings;
use utf8;
our $VERSION = '1.0';

sub new ($;%) {
  my $class = shift;
  my $self = bless {

  }, $class;
  return $self;
} # new

sub load_text_from_cache ($$) {
  my ($self, $title) = @_;
  require MediaWikiXML::PageExtractor;
  my $text = MediaWikiXML::PageExtractor->get_text_from_cache ($title);
  if (defined $text) {
    $self->{title} = $title;
    $self->{text} = $text;
  } else {
    die "Page |$title| not found in the cache";
  }
} # load_text_from_cache

sub title ($) {
  return $_[0]->{title};
} # title

sub parse_text ($) {
  my $self = shift;
  my $text = $self->{text} or die "text is not loaded yet";
  my $mode = 'schools';
  my $headings = [];
  for my $t (split /\n/, $text) {
    if ($t =~ /^\*+\s*(.+)/) {
      next unless $mode;
      my $name = $1;
      my $wikipedia_name = $name;
      next if $name =~ /^(?:北学区は、|第I+類は|なお、)/;
      if ($name =~ /^\s*'''(.+?)'''/) {
        $wikipedia_name = $name = $1;
      }
      if ($name =~ /^\s*(\S+) - /) {
        $wikipedia_name = $name = $1;
      }
      if ($name =~ /^\s*\[\[([^\|\]]+?)\|([^\|\]]*?)\]\]/) {
        $name = $2;
        $wikipedia_name = $1;
      }
      if ($name =~ /^\s*\[\[([^\|\]]+?)\]\]([^\[]+キャンパス)/) {
        $name = $1 . $2;
        $wikipedia_name = $1;
      }
      if ($name =~ /^\s*\[\[([^\|\]]+?)\]\]/) {
        $wikipedia_name = $name = $1;
      }
      s/｛.*?｝// for $name;
      s/（.*?）// for $name;
      s/\s*\((.*?キャンパス)\)/$1/ for $name;
      next if $name =~ /^.{2,3}学区$/;
      my $props = {};
      for (grep {$_} @$headings) {
        if (/^([国都道府県公市区町村私]立)高等学校$/) {
          $props->{owner_type} = $1;
          if ($props->{owner_type} eq '公立') {
            if ($name =~ /([県市区町村]立)/) {
              $props->{owner_type} = $1;
            }
          }
        } elsif (/(?:学区|通学圏)$/) {
          $props->{school_area} = $_;
        } elsif (/[市郡区町村]$/) {
          $props->{location_area} = $_;
        } elsif (/^(?:
          (?:市町村|府|組合)立高等学校|
          その他(?:の専門学科高校)?|
          (?:地区|県内)全域から受験可能な学校|普通科高等学校|分校|専門(?:高校|学科)|
          工業・工科高校|
          [商農]業高校|
          国際・科学高校|
          閉校・募集停止|
          総合学科|
          クリエイティブスクール|
          .*単位制|
          .*支庁
        )$/x) {
          #
        } else {
          push @{$props->{misc} ||= []}, $_;
        }
      }
      if ($name eq '早稲田実業学校') {
        my $title = $self->title;
        $name = '早稲田大学系属' . $name;
        if ($title =~ /高等学校/) {
          $name .= '高等部';
        } elsif ($title =~ /中学校/) {
          $name .= '中等部';
        } elsif ($title =~ /小学校/) {
          $name .= '初等部';
        }
      }
      $props->{wikipedia_name} = $wikipedia_name if $name ne $wikipedia_name;

      my $v_mode;
      if ($name =~ /中等教育学校[^校]*$/) {
        $v_mode = 'high_schools';
      } elsif ($name =~ /高等学校[^校]*(?:分校|校舎|東京校)?$|高等(?:科|部|学院)$/) {
        $v_mode = 'senior_high_schools';
      } else {
        $v_mode = 'misc_schools';
      }
      $self->{$v_mode}->{$name} = $props;
    } elsif ($t =~ /^(=+)\s*(.+?)\s*=+\s*$/) {
      my $level = length $1;
      my $name = $2;
      $name =~ s/\[\[(.*?)\]\]/$1/g;
      s/（.*?）// for $name;
      $headings = [@$headings[0..($level - 1)], $name];
      splice @$headings, $level + 1, $#$headings - $level - 1, ();
      undef $mode if $name =~ /関連|外部|リンク/;
    }
  }
} # parse_text

sub as_hashref ($) {
  my $self = shift;
  my $r = {};
  for (qw(high_schools senior_high_schools misc_schools)) {
    $r->{$_} = $self->{$_} if $self->{$_};
  }
  return $r;
} # as_hashref

1;
