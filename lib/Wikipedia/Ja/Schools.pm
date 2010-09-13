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
  my $prev_name;
  for my $t (split /\n/, $text) {
    if ($t =~ /^(\*+)\s*(.+)/) {
      next unless $mode;
      my $name = $2;
      my $level = length $1;
      my $wikipedia_name;
      next if $name =~ /^(?:北学区は、|第I+類は|なお、|..学区|近々|\[\[専門学科\]\]と|よって|以下、|「|平成\d+年|これ以外の|県内の|\d+年度|-->$|※)/;
      next if $name =~ /存在しない/;
      next if $name eq 'なし';
      $name =~ s/\x{200e}//g;
      $name =~ s/^\s*[^\[\]]+学[園院館]\[\[/\[\[/;
      $name =~ s/^\s*\[\[[^\[\]]+学[園院館]\]\]\[\[/\[\[/;
      $name =~ s/^\s*株式会社[^\[\]]+\[\[/\[\[/;
      if ($name =~ /^\s*'''(.+?)'''/) {
        $name = $1;
      }
      if ($name =~ /^\s*(\S+) - /) {
        $name = $1;
      }
      if ($name =~ /^\s*\[([^\|\]]+?)\]\[http:([^\|\]]*?)\]/) {
        $name = $1;
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
      $name =~ s/\[\[([^\|\[\]]+)\|([^\|\[\]]+)\]\]/$2/g;
      $name =~ s/\s+/ /g;
      $name =~ s/^ //;
      $name =~ s/ $//;
      if ($name =~ /^[^学校]+分(?:校|教?室)$|^[^学校]{2,3}校$|^高等部$|^[^学校]+高校分教室$|^小学部[^学校]+分教室$/ and $level > 1 and $prev_name) {
        $name = $prev_name . $name;
      } else {
        $prev_name = $name;
      }
      if ($name =~ /小学校・中学校・高等学校$|初等部・中等部・高等部$/) {
        my $title = $self->title;
        if ($title =~ /中学校/) {
          $name =~ s/小学校・中学校・高等学校$/中学校/;
          $name =~ s/初等部・中等部・高等部$/中等部/;
        } elsif ($title =~ /小学校/) {
          $name =~ s/小学校・中学校・高等学校$/小学校/;
          $name =~ s/初等部・中等部・高等部$/初等部/;
        } elsif ($title =~ /高等学校/) {
          $name =~ s/小学校・中学校・高等学校$/高等学校/;
          $name =~ s/初等部・中等部・高等部$/高等部/;
        }
      } elsif ($name =~ /小学校・中学校$|初等部・中等部$/) {
        my $title = $self->title;
        if ($title =~ /中学校/) {
          $name =~ s/小学校・中学校$/中学校/;
          $name =~ s/初等部・中等部$/中等部/;
        } elsif ($title =~ /小学校/) {
          $name =~ s/小学校・中学校$/小学校/;
          $name =~ s/初等部・中等部$/初等部/;
        }
      } elsif ($name =~ /中[学等](?:校|部|)・高等(?:学校|部)$/) {
        my $title = $self->title;
        if ($title =~ /中学校/) {
          $name =~ s/中学校?・高等(?:学校|部)$/中学校/;
          $name =~ s/中等部・高等(?:学校|部)$/中等部/;
        } elsif ($title =~ /高等学校/) {
          $name =~ s/中学(?:校|部|)・(高等(?:学校|部))$/$1/;
        }
      } elsif ($name =~ /高等学校・附属中学校$/) {
        my $title = $self->title;
        if ($title =~ /中学校/) {
          $name =~ s/高等学校・附属中学校$/附属中学校/;
        } elsif ($title =~ /高等学校/) {
          $name =~ s/高等学校・附属中学校$/高等学校/;
        }
      } elsif ($name =~ /中学校・[^高等学校]+高等学校$/) {
        my $title = $self->title;
        if ($title =~ /中学校/) {
          $name =~ s/中学校・.+?$/中学校/;
        } elsif ($title =~ /高等学校/) {
          $name =~ s/(立)[^中学校]+中学校・([^高等学校]+)高等学校$/$1$2高等学校/;
        }
      } elsif ($name eq '広島三育学院高等学校・中学校・大和小学校') {
        my $title = $self->title;
        if ($title =~ /中学校/) {
          $name = '広島三育学院中学校';
        } elsif ($title =~ /小学校/) {
          $name = '広島三育学院大和小学校';
        } elsif ($title =~ /高等学校/) {
          $name = '広島三育学院高等学校';
        }
      } elsif ($name eq '早稲田実業学校') {
        ## Source: Web site
        my $title = $self->title;
        $name = '早稲田大学系属' . $name;
        if ($title =~ /高等学校/) {
          $name .= '高等部';
        } elsif ($title =~ /中学校/) {
          $name .= '中等部';
        } elsif ($title =~ /小学校/) {
          $name .= '初等部';
        }
      } elsif ($name eq '箕面市立止々呂美小中一貫校') {
        ## Source: Web site.
        my $title = $self->title;
        if ($title =~ /中学校/) {
          $name = '箕面市立とどろみの森学園 (箕面市立止々呂美中学校)';
        } elsif ($title =~ /小学校/) {
          $name = '箕面市立とどろみの森学園 (箕面市立止々呂美小学校)';
        }
      }
      $name = {
        '鹿児島育英館高等部' => '鹿児島育英館高等学校', # Source: Web site
        'ウィングハイスクール' => '日本航空高等学校通信制課程', # Source: Wikipedia
        'クラ・ゼミ 輝高等学院・[[クラ・ゼミ 輝高等学校]]浜松校' => 'クラ・ゼミ 輝高等学校浜松校',
        '尾山台高等学校' => '藤花学園尾山台高等学校', # Source: Wikipedia
        '古川学園' => '向陽台高等学校古川学園キャンパス', # Source: Web site
        '法政大学第二中' => '法政大学第二中学校', # Source: Web site
        '練馬区立光が丘四季の香学校' => '練馬区立光が丘四季の香小学校', # Source: newspaper
        '名古屋市立吉根学校' => '名古屋市立吉根小学校', # Source: Web site
      }->{$name} || $name;
      next if $name =~ /^.{2,3}学区$/;
      if ($name =~ /・/) {
        warn "Name with \"・\": |$name|\n";
      }

      my $props = {};
      for (grep {$_} @$headings) {
        if (/^
          ([国都道府県公市区町村私]立|市?町村立|市・町・組合立|組合立)
          (?:[小中]学校|高等学校|中等教育学校(?:及び県立中学校)?|中学校(?:及び|および)中等教育学校|中高一貫校)?
        $/x) {
          $props->{owner_type} = $1 if 2 == length $1;
          ## Note that "国立中学校及び中等教育学校" means "either national
          ## junior high school, or high school".
          #if (not $props->{owner_type} or $props->{owner_type} eq '公立') {
            if ($name =~ /([県市区町村]立)/) {
              $props->{owner_type} = $1;
            }
          #}
        } elsif (/^組合立中学校$/) {
          $props->{owner_type} = '組合';
        } elsif (/^北海道立$/) {
          $props->{owner_type} = '道立';
        } elsif (/(?:学区|通学圏)$/) {
          $props->{school_area} = $_;
          $props->{school_area} =~ s/^.+課程・//;
        } elsif (/^(?!特別区)(.+?[都道府県市郡区町村])(?: \(..国\))?$/) {
          $props->{location_area} ||= '';
          $props->{location_area} .= $1;
        } elsif (/^(?:
          岩手県立|東京都立|宮崎市立|宮崎県立|都城市立|
          多摩地域|
          (?:市町村|府|組合)立高等学校|
          その他(?:の専門学科高校)?|
          (?:地区|県内)全域から受験可能な学校|普通科高等学校|分校|専門(?:高校|学科)|
          公立・私立高等学校|
          [^学立]+立特別支援学校|(?:視覚|聴覚|特別)?支援学校|
          旧?(?:養護学校|ろう学校|聾学校|盲学校)|
          工業・工科高校|
          [商農]業高校|
          [商農工]業高等学校|
          農業高等学校・林業高等学校|
          家庭高等学校|
          国際・科学高校|
          総合学科のある高等学校|
          閉校・募集停止|
          総合学科|
          クリエイティブスクール|
          .*単位制|
          .*支庁|
          .*地方|特別区|
          .*振興局|
          中等教育学校|
          専門高校・総合学科高校など|
          (?:定時制|通信制|全日制(?:普通科)?)(?:課程)?|
          定時制・通信制のみ設置|定時制・通信制|定時制・通信制両課程を置く高校|
          高等専修学校|短期大学|
          男子校|女子校|共学校|
          名古屋市内|三河(?:[東西]部)?|尾張(?:[東西]部)?|知多|渥美|島嶼部|
          九州・沖縄県\|沖縄|近畿|中部|関東|東北|中国|四国|
          地域別の一覧|
          .*と合併する.*
        )$/x) {
          #
        } else {
          push @{$props->{misc} ||= []}, $_;
        }
      }
      if ($name =~ /高等学校[^学校]+([市町村][立])[^学校]+校$/) {
        $props->{owner_type} = $1;
      }
      $props->{wikipedia_name} = $wikipedia_name
          if $wikipedia_name and $name ne $wikipedia_name;

      my $short_name = $name;
      $short_name =~ s/高等学校/高校/;
      $short_name =~ s/高等専門学校/高専/;
      $short_name =~ s/^(?:[^立]+?[都府県市区町村]立|北海道|長野県|宮城県)//
          unless $short_name =~ /大学$/;
      $short_name =~ s/短期大学/短大/g;
      $short_name = {
        '日本航空高等学校通信制課程' => 'ウィングハイスクール',
        'クラ・ゼミ 輝高等学校浜松校' => '輝高等学校浜松校',
        '藤花学園尾山台高等学校' => '尾山台高校',
        '大多和学園 開星中学校' => '開星中学校',
        '大多和学園 開星高等学校' => '開星高校',
        '箕面市立とどろみの森学園 (箕面市立止々呂美中学校)' => 'とどろみの森学園',
        '箕面市立とどろみの森学園 (箕面市立止々呂美小学校)' => 'とどろみの森学園',
      }->{$name} || $short_name;
      $props->{short_name} = $short_name if $name ne $short_name;

      my $v_mode;
      if ($name =~ /小中学校$|小中一貫校..学園$/) {
        $v_mode = 'primary_and_secondary_schools';
      } elsif ($name =~ /
        (?:小学[校部]|初等学?[部科]|初等学校)
        (?:[^学校]+(?:分[校室]|校舎))?
      /x) {
        $v_mode = 'elementary_schools';
      } elsif ($name =~ /
        (?:中学[校部]|中等[部科])
        (?:[^学校]+(?:分[校室]|学園分校|校舎?)|夜間学級|二部|特学分校|男子部|女子部)?
      $/x) {
        $v_mode = 'junior_high_schools';
      } elsif ($name =~ /中等教育学校[^校]*$/) {
        $v_mode = 'high_schools';
      } elsif ($name =~ /
        (?:支援学校|養護学校|ろう学校|聾学校|盲学校)
          (?:小学部|高等部)?
          (?:[^学校]+(?:学園|校|分教室|高校分教室|学園内教室|学園分[室校]|大学(?:医学部)?[^学校]+?(?:分(?:校|教室)|院内学級)|校舎|分校[^学校]+分教室|分級|学園[^学校]+分校|院内学級))?$|
        聾話学校$|都立[小中高]+?学園$|区立[小中高]+?学校$|^特別支援学校|訓盲学院|
        ことばの?教室
      /x) {
        $v_mode = 'special_schools';
      } elsif ($name =~ /高等学校[^校]*(?:分校|校舎|校地)?$|高等(?:科|部|学[院部])$/) {
        $v_mode = 'senior_high_schools';
      } elsif ($name =~ /高等学校[^学校分院科園]+校$/) {
        $v_mode = 'senior_high_schools';
      } elsif ($name =~ /高等専門学校$/) {
        $v_mode = 'tech_colleges';
      } elsif ($name =~ /短期大学部?(?:[^学]+キャンパス)?$/) {
        $v_mode = 'junior_colleges';
      } elsif ($name =~ /大学院大学(?:[^学]+キャンパス)?$/) {
        $v_mode = 'graduate_schools';
      } elsif ($name =~ /大[学學](?:.+?キャンパス)?$/) {
        $v_mode = 'univs';
      } else {
        $v_mode = {
          '国立唐津海上技術学校' => 'senior_high_schools', # Source: Web site
          '向陽橘香館' => 'senior_high_schools', # Source: Web site
          '九州国際高等学園' => '_', # 高等専修学校 (Source: Wikipedia)
          '明倫館学院' => '_', # サポート校 (Source: Wikipedia)
          '大垣文化総合専門学校' => '_', # 連携校 (Source: Wikipedia)
          '首都大学東京' => 'univs',
          '福岡県立北九州高等学園' => 'special_schools', # Source: Web site
          '福岡県立福岡高等学園' => 'special_schools', # Source: Web site
          '札幌市立東米里小・中学校ひまわり分校' => 'primary_and_secondary_schools',
          '鴨川市立長狭学園' => 'primary_and_secondary_schools', # Source: Web site
          '箕面市立とどろみの森学園 (箕面市立止々呂美中学校)' => 'junior_high_schools',
          '箕面市立とどろみの森学園 (箕面市立止々呂美小学校)' => 'elementary_schools',
          '八王子市立高尾山学園' => 'primary_and_secondary_schools', # Source: Web site
          '慶應義塾幼稚舎' => 'elementary_schools', # Source: Web site
          '慶應義塾普通部' => 'junior_high_schools', # Source: Web site
        }->{$name} || 'misc_schools';
      }
      $self->{$v_mode}->{$name} = $props unless $name eq '_';
    } elsif ($t =~ /^(=+)\s*(.+?)\s*=+\s*$/) {
      my $level = length $1;
      my $name = $2;
      $name =~ s/\[\[(.*?)\]\]/$1/g;
      s/（.*?）// for $name;
      $headings = [@$headings[0..($level - 1)], $name];
      splice @$headings, $level + 1, $#$headings - $level - 1, ();
      undef $mode if $name =~ /関連|外部|リンク|改称した|再編|広域通信制の学習センター等|サポート校|通称|かつて|特記事項|廃校/;
    } elsif ($t =~ /^'''\s*(.+?)\s*'''\s*$/) {
      my $level = 7;
      my $name = $1;
      $name =~ s/\[\[(.*?)\]\]/$1/g;
      s/（.*?）// for $name;
      $headings = [@$headings[0..($level - 1)], $name];
      splice @$headings, $level + 1, $#$headings - $level - 1, ();
    }
  }
} # parse_text

sub as_hashref ($) {
  my $self = shift;
  my $r = {};
  for (qw(
    elementary_schools junior_high_schools
    high_schools senior_high_schools tech_colleges junior_colleges
    univs graduate_schools misc_schools special_schools
  )) {
    $r->{$_} = $self->{$_} if $self->{$_};
  }
  return $r;
} # as_hashref

1;
