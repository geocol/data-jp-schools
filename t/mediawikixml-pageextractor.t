package t::MediaWikiXML::PageExtractor;
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->subdir ('lib')->stringify;
use lib glob file (__FILE__)->dir->parent->subdir ('modules/*/lib');
use base qw(Test::Class);
use MediaWikiXML::PageExtractor;
use Test::More;

sub _get_f_from_title : Test(8) {
  for (
    ['abc', 'cache/page-by-name/abc.dat'],
    ["\x{5000}\x{5001}\x{5002}abc", 'cache/page-by-name/_E5_80_80_E5_80_81_E5_80_82abc.dat'],
    ['a+*&<>*a"//bb=-~\\_', 'cache/page-by-name/a_2B_2A_26_3C_3E_2Aa_22_2F_2Fbb_3D-~_5C_5F.dat'],
    ["\xE5\x80\x80\xE5\x80\x81abc", 'cache/page-by-name/_E5_80_80_E5_80_81abc.dat'],
  ) {
    my $f = MediaWikiXML::PageExtractor->get_f_from_title ($_->[0]);
    isa_ok $f, 'Path::Class::File';
    is $f . '', $_->[1];
  }
} # _get_f_from_title

__PACKAGE__->runtests;

1;
