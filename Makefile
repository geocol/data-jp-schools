JA_CURRENT_XML = cache/xml/jawiki-latest-pages-meta-current.xml

ROOTDIR = .
BINDIR = $(ROOTDIR)/bin
PREPARE_CACHES_BY_PATTERN = perl $(BINDIR)/prepare-caches-by-pattern.pl
EXTRACT_JP_JUNIOR_HIGH_SCHOOLS = perl $(BINDIR)/extract-jp-junior-high-schools.pl
EXTRACT_JP_SENIOR_HIGH_SCHOOLS = perl $(BINDIR)/extract-jp-senior-high-schools.pl
EXTRACT_JP_TECH_COLLEGES = perl $(BINDIR)/extract-jp-tech-colleges.pl
EXTRACT_JP_UNIVS = perl $(BINDIR)/extract-jp-univs.pl
EXTRACT_JP_SPECIAL_SCHOOLS = perl $(BINDIR)/extract-jp-special-schools.pl

all: schools

download: jawiki-latest-pages-meta-current

jawiki-latest-pages-meta-current: $(JA_CURRENT_XML)

$(JA_CURRENT_XML): $(JA_CURRENT_XML).bz2
	bunzip2 $<

$(JA_CURRENT_XML).bz2:
	-mkdir cache
	-mkdir cache/xml
	wget -O $@ http://download.wikimedia.org/jawiki/latest/jawiki-latest-pages-meta-current.xml.bz2

schools: \
    list-junior-high-schools list-senior-high-schools \
    list-senior-tech-colleges list-univs \
    list-special-schools

list-junior-high-schools:
	$(EXTRACT_JP_JUNIOR_HIGH_SCHOOLS)

list-senior-high-schools:
	$(EXTRACT_JP_SENIOR_HIGH_SCHOOLS)

list-senior-tech-colleges:
	$(EXTRACT_JP_TECH_COLLEGES)

list-univs:
	$(EXTRACT_JP_UNIVS)

list-special-schools:
	$(EXTRACT_JP_SPECIAL_SCHOOLS)

schools-cache: \
    cache-junior-high-schools cache-senior-high-schools \
    cache-tech-colleges cache-univs

cache-junior-high-schools: #$(JA_CURRENT_XML)
	$(PREPARE_CACHES_BY_PATTERN) '^[^:]+?(?:都|道|府|県)中学校一覧' <\
	    $(JA_CURRENT_XML)

cache-senior-high-schools: #$(JA_CURRENT_XML)
	$(PREPARE_CACHES_BY_PATTERN) '^[^:]+?(?:都|道|府|県)高等学校一覧' <\
	    $(JA_CURRENT_XML)

cache-tech-colleges:
	$(PREPARE_CACHES_BY_PATTERN) '^日本の高等専門学校一覧' \
	    $(JA_CURRENT_XML)

cache-univs:
	$(PREPARE_CACHES_BY_PATTERN) '^(?:東|西)?日本の(?:短期)?大学一覧|^大学校' \
	    $(JA_CURRENT_XML)

cache-special-schools:
	$(PREPARE_CACHES_BY_PATTERN) '^[^:]+?(?:都|道|府|県)特別支援学校一覧' <\
	    $(JA_CURRENT_XML)

## License: Public Domain.
