SHELL = /bin/bash
.PHONY: build build-styles build-scripts watch package open-fontello save-fontello

build:
	stylus .

watch:
	ls *.styl | entr -r ${MAKE} build

package:
	rm -f chrome-ext.zip
	mkdir pkg
	ls | grep -vF pkg | xargs cp -rt pkg
	rm pkg/*.styl pkg/Makefile
	cd pkg; zip -r ../chrome-ext.zip * > /dev/null
	rm -r pkg
