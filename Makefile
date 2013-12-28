SHELL = /bin/bash
.PHONY: package

package:
	rm -f chrome-ext.zip
	mkdir pkg
	ls | grep -vF pkg | xargs cp -rt pkg
	rm pkg/Makefile
	cd pkg; zip -r ../chrome-ext.zip * > /dev/null
	rm -r pkg
