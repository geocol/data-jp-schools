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

sub load_school_text_from_cache ($$) {
  my ($self, $school_wikipedia_name) = @_;
  require MediaWikiXML::PageExtractor;
  my $text = MediaWikiXML::PageExtractor->get_text_from_cache
      ($school_wikipedia_name, allow_not_found => 1);
  if (defined $text) {
    my $school = $self->{school}->{$school_wikipedia_name} = {text => $text};

    if ($text =~ /
      \{\{(?:日本の(?:小|中|高等|)学校|高等専門学校|日本の幼稚園|大学)\s*\n
        (.*?)
      \n\}\}
    /sx) {
      my $v = $1;
      $v =~ s[<!--.*?-->][]gs;
      $v .= "\n|";
      for (split /\s*\n\|\s*/, $v) {
        if (/(\S+)\s*=\s*(.+)/) {
          $school->{$1} = $2;
        }
      }
    }
    return $school;
  } else {
    #warn "Page |$school_wikipedia_name| not found in the cache";
    return undef;
  }
} # load_school_text_from_cache

sub title ($) {
  return $_[0]->{title};
} # title

sub parse_text ($) {
  my $self = shift;
  my $text = $self->{text} or die "text is not loaded yet";
  my $mode = 'schools';
  my $headings = [];
  my $prev_name;
  $text =~ s[<!--.*?-->][]gs;
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
      $name =~ s[<ref>.*?</ref>][]g;
      if ($name =~ /^\s*'''(.+?)'''/) {
        $name = $1;
      }
      if ($name =~ /^\s*(\S+) - /) {
        $name = $1;
      }
      if ($name =~ /^\s*\[([^\|\]]+?)\]\[http:([^\|\]]*?)\]/) {
        $name = $1;
      }
      if ($name =~ m{^\s*\[http://[\x21-\x7E]+\s+([^\|\]]+?)\]}) {
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
      s/\s*\((.*?キャンパス)\)/$1/ for $name;
      s/｛.*?｝// for $name;
      s/（.*?）// for $name;
      s/\s*\(.*?\)// for $name;
      $name =~ s[\s*/\s*$][];
      $name =~ s/\[\[([^\|\[\]]+)\|([^\|\[\]]+)\]\]/$2/g;
      $name =~ s[\s*\[http://[\x21-\x7E]+?\]\s*$][];
      $name =~ s[\s*http://[\x21-\x7E]+\s*$][];
      $name =~ s/：\[\[.+$//;
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
        '久留米あかつき幼稚国' => '久留米あかつき幼稚園', # Source: Web site
        '吉岡バプテスト光の園' => '吉岡バプテストひかりの園', # Source: Web site
        '光陽保育園 桑部' => '光陽桑部保育園', # Source: Web site
        '光陽保育園 桑部第二' => '光陽桑部第二保育園', # Source: Web site
        '光陽保育園 久米' => '光陽久米保育園', # Source: Web site
        '光陽保育園' => '光陽希望ヶ丘保育園', # Source: Web site

        ## Source: <http://www.m-hoiku.or.jp/kamei/miyazakishi.html>
        'めぐみ保育園(※本郷南方)' => '社会福祉法人恵広会めぐみ保育園',
        'めぐみ保育園(※田野町)' => '社会福祉法人恵浄福祉会めぐみ保育園',
      }->{$name} || $name;
      next if $name =~ /^.{2,3}学区$/;
      if ($name =~ /・/) {
        warn "Name with \"・\": |$name|\n";
      } elsif ($name eq '川棚町立川棚小学校') {
        my $title = $self->title;
        next if $title =~ /幼稚園一覧/;
      } elsif ($name eq '学校法人白百合学園') {
        my $title = $self->title;
        $name = '白百合幼稚園' if $title eq '福島県幼稚園一覧';
      }

      my $props = {};
      for (grep {$_} @$headings) {
        if (/^
          ([国都道府県公市区町村私]立|市?町村立|市・町・組合立|組合立)
          (?:幼稚園|保育[園所]|[小中]学校|高等学校|中等教育学校(?:及び県立中学校)?|中学校(?:及び|および)中等教育学校|中高一貫校)?
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
          if ($props->{location_area} =~ /^([^|]+)\|[^|]+$/) {
            $props->{location_area} = $1;
            $props->{location_area} =~ s/\s*\([^()]+\)$//g;
          }
          $props->{location_area} =~ s/^[^地区]+地区//;
          $props->{location_area} =~ s/^[東西中]濃(?!郡)//;
          delete $props->{location_area} unless $props->{location_area};
        } elsif (/^(?:
          岩手県立|東京都立|宮崎市立|宮崎県立|都城市立|
          多摩地域|佐土原|檍南|高岡|赤江[東西南]|中央[東西]|青島|大宮東|田野|大塚|小戸|木花|檍北|大宮西|住吉|橘|大淀西|生目|北|大塚台|大淀東|生目台|
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
          長崎市私立幼稚園協会|
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
      if ($props->{location_area} and $props->{location_area} =~ /郡$/) {
        if ($name =~ /^(.+?[町村])立/) {
          $props->{location_area} .= $1;
        }
      }
      if ($wikipedia_name and $name =~ /^\Q$wikipedia_name\E.*キャンパス$/) {
        undef $wikipedia_name;
      }
      $props->{wikipedia_name} = $wikipedia_name
          if $wikipedia_name and $name ne $wikipedia_name;

      my $school = $self->load_school_text_from_cache ($wikipedia_name || $name);
      if ($school) {
        $props->{english_long_name} ||= $school->{'英称'};
        if ($props->{english_long_name}) {
          $props->{english_long_name} =~ s['''([^']*)'''][$1]g;
          $props->{english_long_name} =~ s[''([^']*)''][$1]g;
          $props->{english_long_name} =~ s/、または.*//g;
          if ($props->{english_long_name} =~ /^(.+?)\s*[(（](.+?)[)）]$/) {
            my $n1 = $1;
            my $n2 = $2;
            if (length $n1 < length $n2) {
              $props->{english_abbr_name} ||= $n1;
              $props->{english_long_name} = $n2;
            } else {
              $props->{english_abbr_name} ||= $n2;
              $props->{english_long_name} = $n1;
            }
          }
          $props->{english_long_name} =~ s/\s*;.*//g;
        }
        $props->{english_abbr_name} ||= $school->{'英略称'};
        $props->{senior_high_school_code} ||= $school->{'高校コード'};
        if ($props->{senior_high_school_code}) {
          $props->{senior_high_school_code} =~ s[<br\s*/?>.+][]gs;
          my $title = $self->title;
          undef $props->{senior_high_school_code} unless $title =~ /中等|高等/;
        }
        # 品質のばらつきが大きすぎるので採用しない
        #$props->{abbr_name} ||= $school->{'大学の略称'};
        #if ($props->{abbr_name}) {
        #  $props->{abbr_name} =~ s[(?:、|あるいは).+][]g;
        #  $props->{abbr_name} =~ s[\s*（.+?）\s*$][]g;
        #  undef $props->{abbr_name} if $props->{abbr_name} =~ /^全国的には|^対外的には|^県外では|^不明/;
        #}
        $props->{school_area} ||= $school->{'学区'};
        if ($props->{school_area}) {
          $props->{school_area} =~ s{\[\[[^\|\]]+\|([^\|\]]+)\]\]}[$1]g;
          $props->{school_area} =~ s{\[\[([^\|\]]+)\]\]}[$1]g;
          $props->{school_area} =~ s[\s*（.+?）\s*$][]g;
          $props->{school_area} =~ s[<br\s*/?>.*][]gs;
          $props->{school_area} =~ s[<[^<>]+>][]g;
          delete $props->{school_area}
              if $props->{school_area} eq '全県一区' or
                 $props->{school_area} =~ /県一円$/;
        }
        $props->{location_zipcode} ||= $school->{'郵便番号'};
        if ($props->{location_zipcode}) {
          $props->{location_zipcode} =~ s[<br\s*/?>.+][]gs;
          $props->{location_zipcode} =~ s[\s*（.+?）\s*$][]g;
          if ($props->{location_zipcode} =~ /^([0-9-]+)/) {
            $props->{location_zipcode} = $1;
          }
        }
        $props->{location} ||= $school->{'所在地'};
        if ($school->{'座標'} and $school->{'座標'} =~ s/
          \{\{ウィキ座標(?:2段)?度分秒(.*?)\}\}
        //x) {
          $props->{location_wikipedia_latlon} ||= $1;
        } elsif ($school->{text} and $school->{text} =~ s/
          \{\{ウィキ座標(?:2段)?度分秒(.*?)\}\}
        //x) {
          $props->{location_wikipedia_latlon} ||= $1;
        }
        if ($props->{location_wikipedia_latlon}) {
          $props->{location_wikipedia_latlon} =~ s[<[^<>]+>][];
        }
        if ($props->{location}) {
          if ($props->{location} =~ s/
            \{\{ウィキ座標(?:2段)?度分秒(.*?)\}\}
          //x) {
            $props->{location_wikipedia_latlon} ||= $1;
          }
          $props->{location} =~ s[<br\s*/?>.+][]gs;
          $props->{location} =~ s{\[\[[^\|\]]+\|([^\|\]]+)\]\]}[$1]g;
          $props->{location} =~ s{\[\[([^\|\]]+)\]\]}[$1]g;
          $props->{location} =~ s[\{\{Color\|[^\|]+\|([^\|\}]+)\}\}][$1]g;
          $props->{location} =~ s[\{\{[Ss]mall(?:er)?\|([^\|\}]*)\}\}][$1]g;
          $props->{location} =~ s[<[^<>]+>][]g;
          $props->{location} =~ s['''([^']*)'''][$1]g;
          $props->{location} =~ s[(?<=\S)\s+\S+?キャンパス:?\s+.+][]g;
          $props->{location} =~ s[^\s*\S+?キャンパス\s+][]g;
          $props->{location} =~ s[\s*（.+?）\s*$][]g;
          $props->{location} =~ s[^本校：][]g;
          $props->{location} =~ tr/０１２３４５６７８９/0-9/;
          if ($props->{location} =~ s/^〒([0-9-]+)\s*//) {
            $props->{location_zipcode} ||= $1;
          }
          $props->{location} =~ s/^\s+//;
          $props->{location} =~ s/\s+$//;
          $props->{location} =~ s/\s+//g;
        }
        $props->{url} ||= $school->{'ウェブサイト'} || $school->{'外部リンク'};
        if ($props->{url}) {
          $props->{url} =~ s{\[(http://[\x21-\x7E]+\s+\S+)\]}{$1}g;
          if ($props->{url} =~ s[(http://[\x21-\x7E]+)][]) {
            $props->{url} = $1;
          }
          $props->{url} =~ tr/\[\]//d;
          undef $props->{url}
              if $props->{url} =~ /未開設/ or
                 $props->{url} =~ /\(Web/;
        }
      }
      if ($school->{text} and $school->{text} =~ /\{\{DEFAULTSORT:([^{}]+)\}\}/) {
        $props->{sort_name} ||= $1;
      }

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
      if ($v_mode = {
        'こども芸術大学' => 'misc_schools', ## Source: Web site
        '慶應義塾幼稚舎' => 'elementary_schools',
      }->{$name}) {
        #
      } elsif ($name =~ /
        (?:幼稚[園部舎]部?|キンダー学園|こども園|幼保園|天使園|幼児センター|幼児園|児童園|なかよしセンター|子ども園|保育[園所]|子ども未来園|キンダーホーム|プレスクール|保育学園|こどもの家|保育センター|ベビーセンター|乳児センター|[^学校分]園|子育て支援センター|こどもセンター|保育・教育センター)
        (?:[^園校]+(?:分[園室]|園舎?))?$|
        幼児教育センター|幼保園|ナーサリー|保育の家|チャイルドケアセンター
      /x) {
        $v_mode = 'kindergartens';
      } elsif ($name =~ /
          小・?中学校(?:[^学校]+分校)?$|
          小中一貫校..学園$
      /x) {
        $v_mode = 'primary_and_secondary_schools';
      } elsif ($name =~ /
        (?:小学[校部]|初等学?[部科]|初等学校)
        (?:[^学校]+(?:分[校室]|校舎)|分校)?
      $/x) {
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
        聾話学校$|都立[^小中高]+?学園$|区立[^小中高]+?学校$|^特別支援学校|訓盲学院|
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
          '慶應義塾普通部' => 'junior_high_schools', # Source: Web site
          '高岡第一学園福岡ひばり園' => 'kindergartens', # Source: Web site
          '品川区立のびっこ園台場' => 'kindergartens', # 幼保一体 (Source: Web site)
          '品川区立二葉すこやか園' => 'kindergartens', # 幼保一体 (Source: Web site)
          '慶光ブライトンアカデミーフォーヤングラーナーズ' => 'kindergartens', # Source: Web site
          '広島光明学園' => 'kindergartens', # 幼保一体 (Source: Web site)
          '吉岡バプテストひかりの園' => 'kindergartens', # Source: Web site
        }->{$name} || 'misc_schools';
      }
      $self->{$v_mode}->{$name} = $props unless $name eq '_';
      for (keys %$props) {
        delete $props->{$_} unless defined $props->{$_};
      }
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
    kindergartens
    elementary_schools junior_high_schools primary_and_secondary_schools
    high_schools senior_high_schools tech_colleges junior_colleges
    univs graduate_schools misc_schools special_schools
  )) {
    $r->{$_} = $self->{$_} if $self->{$_};
  }
  return $r;
} # as_hashref

1;
