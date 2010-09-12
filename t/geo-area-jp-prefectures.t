package t::Geo::Area::Jp::Prefectures;
use strict;
use warnings;
use utf8;
use Path::Class;
use lib file (__FILE__)->dir->parent->subdir ('lib')->stringify;
use lib glob file (__FILE__)->dir->parent->subdir ('modules/*/lib');
use base qw(Test::Class);
use Geo::Area::Jp::Prefectures;
use Test::More;

sub _lists : Test(4) {
  is scalar @Geo::Area::Jp::Prefectures::JpanLongName, 47;
  is scalar @Geo::Area::Jp::Prefectures::JpanShortName, 47;
  is scalar @Geo::Area::Jp::Prefectures::LatnLongName, 47;
  is scalar @Geo::Area::Jp::Prefectures::LatnShortName, 47;
} # _lists

sub _lists_values : Test(12) {
  is $Geo::Area::Jp::Prefectures::JpanLongName[0], '北海道';
  is $Geo::Area::Jp::Prefectures::JpanShortName[0], '北海道';
  is $Geo::Area::Jp::Prefectures::LatnLongName[0], 'Hokkaido';
  is $Geo::Area::Jp::Prefectures::LatnShortName[0], 'Hokkaido';
  is $Geo::Area::Jp::Prefectures::JpanLongName[1], '青森県';
  is $Geo::Area::Jp::Prefectures::JpanShortName[1], '青森';
  is $Geo::Area::Jp::Prefectures::LatnLongName[1], 'Aomori-ken';
  is $Geo::Area::Jp::Prefectures::LatnShortName[1], 'Aomori';
  is $Geo::Area::Jp::Prefectures::JpanLongName[46], '沖縄県';
  is $Geo::Area::Jp::Prefectures::JpanShortName[46], '沖縄';
  is $Geo::Area::Jp::Prefectures::LatnLongName[46], 'Okinawa-ken';
  is $Geo::Area::Jp::Prefectures::LatnShortName[46], 'Okinawa';
}

__PACKAGE__->runtests;

1;

__END__

=head1 AUTHOR

Wakaba <w@suika.fam.cx>.

=head1 LICENSE

Public Domain.

=cut
