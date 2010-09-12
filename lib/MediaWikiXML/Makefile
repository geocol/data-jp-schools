POD2HTML = pod2html --css "http://suika.fam.cx/www/style/html/pod.css" \
  --htmlroot ".."

all: PageExtractor.html

%.html: %.pod
	$(POD2HTML) $< > $@

## License: Public Domain.
