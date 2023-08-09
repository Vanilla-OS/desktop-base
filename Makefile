PIXMAPS=$(wildcard pixmaps/*.png)

.PHONY: all clean install install-local
all: build-emblems build-logos
clean: clean-emblems clean-logos

.PHONY: build-emblems clean-emblems install-emblems
build-emblems clean-emblems install-emblems:
	@target=`echo $@ | sed s/-emblems//`; \
	$(MAKE) $$target -C emblems-vanilla || exit 1;

.PHONY: build-logos clean-logos install-logos
build-logos clean-logos install-logos:
	@target=`echo $@ | sed s/-logos//`; \
	$(MAKE) $$target -C vanilla-logos || exit 1;


install: install-emblems install-logos install-local

install-local:
	# vanilla logo in circle as default user face icon
	install -d $(DESTDIR)/etc/skel
	$(INSTALL_DATA) defaults/common/etc/skel/.face $(DESTDIR)/etc/skel
	cd $(DESTDIR)/etc/skel && ln -s .face .face.icon

	# pixmaps files
	mkdir -p $(DESTDIR)/usr/share/pixmaps
	$(INSTALL_DATA) $(PIXMAPS) $(DESTDIR)/usr/share/pixmaps/

include Makefile.inc
