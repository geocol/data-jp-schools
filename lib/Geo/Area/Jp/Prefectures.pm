package Geo::Area::Jp::Prefectures;
use strict;
use warnings;
use utf8;
our $VERSION = '1.0';

our @JpanLongName = qw(
  北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県 茨城県 栃木県 群馬県
  埼玉県 千葉県 東京都 神奈川県 新潟県 富山県 石川県 福井県 山梨県 
  長野県 岐阜県 静岡県 愛知県 三重県 滋賀県 京都府 大阪府 兵庫県 奈良県
  和歌山県 鳥取県 島根県 岡山県 広島県 山口県 徳島県 香川県 愛媛県 
  高知県 福岡県 佐賀県 長崎県 熊本県 大分県 宮崎県 鹿児島県 沖縄県
);

our @JpanShortName = map { my $v = $_; $v =~ s/[都府県]$//; $v } @JpanLongName;

our @LatnLongName = qw(
  Hokkaido Aomori-ken Iwate-ken Miyagi-ken Akita-ken Yamagata-ken
  Fukushima-ken Ibaraki-ken Tochigi-ken Gunma-ken Saitama-ken
  Chiba-ken Tokyo-to Kanagawa-ken Niigata-ken Toyama-ken Ishikawa-ken
  Fukui-ken Yamanashi-ken Nagano-ken Gifu-ken Shizuoka-ken Aichi-ken
  Mie-ken Shiga-ken Kyoto-fu Osaka-fu Hyogo-ken Nara-ken Wakayama-ken
  Tottori-ken shimane-ken Okayama-ken Hiroshima-ken Yamaguchi-ken
  Tokushima-ken Kagawa-ken Ehime-ken Kochi-ken Fukuoka-ken Saga-ken
  Nagasaki-ken Kumamoto-ken Oita-ken Miyazaki-ken Kagoshima-ken
  Okinawa-ken
);

our @LatnShortName = map { my $v = $_; $v =~ s/-.*$//; $v } @LatnLongName;

1;

__END__

=head1 LICENSE

Public Domain.

=cut
