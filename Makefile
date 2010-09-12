JA_CURRENT_XML = cache/xml/jawiki-latest-pages-meta-current.xml

ROOTDIR = .
BINDIR = $(ROOTDIR)/bin
PREPARE_CACHES_BY_PATTERN = perl $(BINDIR)/prepare-caches-by-pattern.pl
EXTRACT_JP_SENIOR_HIGH_SCHOOLS = perl $(BINDIR)/extract-jp-senior-high-schools.pl

all: schools

download: jawiki-latest-pages-meta-current

jawiki-latest-pages-meta-current: $(JA_CURRENT_XML)

$(JA_CURRENT_XML): $(JA_CURRENT_XML).bz2
	bunzip $<

$(JA_CURRENT_XML).bz2:
	-mkdir cache
	-mkdir cache/xml
	wget -O $@ http://download.wikimedia.org/jawiki/latest/jawiki-latest-pages-meta-current.xml.bz2

schools: list-senior-high-schools

list-senior-high-schools:
	$(EXTRACT_JP_SENIOR_HIGH_SCHOOLS)

schools-cache: cache-senior-high-schools

cache-senior-high-schools: #$(JA_CURRENT_XML)
	$(PREPARE_CACHES_BY_PATTERN) '^[^:]+?(?:都|道|府|県)高等学校一覧' < $(JA_CURRENT_XML)

## License: Public Domain.
