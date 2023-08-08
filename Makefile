GRUB_THEMES=emerald-theme/grub\
	homeworld-theme/grub\
	futureprototype-theme/grub\
	moonlight-theme/grub\
	softwaves-theme/grub\
	lines-theme/grub\
	joy-theme/grub\
	spacefun-theme/grub
DEFAULT_BACKGROUND=desktop-background

PIXMAPS=$(wildcard pixmaps/*.png)
DESKTOPFILES=$(wildcard *.desktop)

.PHONY: all clean install install-local
all: build-grub build-emblems build-logos
clean: clean-grub clean-emblems clean-logos

.PHONY: build-grub clean-grub install-grub
build-grub clean-grub install-grub:
	@target=`echo $@ | sed s/-grub//`; \
	for grub_theme in $(GRUB_THEMES) ; do \
		if [ -f $$grub_theme/Makefile ] ; then \
			$(MAKE) $$target -C $$grub_theme || exit 1; \
		fi \
	done

.PHONY: build-emblems clean-emblems install-emblems
build-emblems clean-emblems install-emblems:
	@target=`echo $@ | sed s/-emblems//`; \
	$(MAKE) $$target -C emblems-debian || exit 1;

.PHONY: build-logos clean-logos install-logos
build-logos clean-logos install-logos:
	@target=`echo $@ | sed s/-logos//`; \
	$(MAKE) $$target -C debian-logos || exit 1;


install: install-grub install-emblems install-logos install-local

install-local:
	# debian logo in circle as default user face icon
	install -d $(DESTDIR)/etc/skel
	$(INSTALL_DATA) defaults/common/etc/skel/.face $(DESTDIR)/etc/skel
	cd $(DESTDIR)/etc/skel && ln -s .face .face.icon

	# background files
	mkdir -p $(DESTDIR)/usr/share/images/desktop-base
	cd $(DESTDIR)/usr/share/images/desktop-base && ln -s $(DEFAULT_BACKGROUND) default
	# desktop files
	mkdir -p $(DESTDIR)/usr/share/desktop-base
	$(INSTALL_DATA) $(DESKTOPFILES) $(DESTDIR)/usr/share/desktop-base/
	# pixmaps files
	mkdir -p $(DESTDIR)/usr/share/pixmaps
	$(INSTALL_DATA) $(PIXMAPS) $(DESTDIR)/usr/share/pixmaps/

	# Create a 'debian-theme' symlink in plymouth themes folder, pointing at the
	# plymouth theme for the currently active 'desktop-theme' alternative.
	mkdir -p $(DESTDIR)/usr/share/plymouth/themes
	ln -s ../../desktop-base/active-theme/plymouth $(DESTDIR)/usr/share/plymouth/themes/debian-theme

	# Set Plasma 5 customizations
	install -d $(DESTDIR)/etc/xdg/autostart
	$(INSTALL_DATA) defaults/kde/etc/xdg/kcm-about-distrorc $(DESTDIR)/etc/xdg
	$(INSTALL_DATA) defaults/kde/etc/xdg/kickoffrc $(DESTDIR)/etc/xdg
	$(INSTALL_DATA) $(wildcard defaults/kde/etc/xdg/autostart/*) $(DESTDIR)/etc/xdg/autostart/
	install -d $(DESTDIR)/etc/xdg/plasma-workspace/env
	$(INSTALL_DATA) $(wildcard defaults/kde/etc/xdg/plasma-workspace/env/*) $(DESTDIR)/etc/xdg/plasma-workspace/env/
	install -d $(DESTDIR)/usr/share/desktop-base/kf5-settings
	$(INSTALL_DATA) $(wildcard defaults/kde/kf5-settings/*) $(DESTDIR)/usr/share/desktop-base/kf5-settings/
	install -d $(DESTDIR)/usr/share/plasma/look-and-feel/org.debian.desktop/contents
	$(INSTALL_DATA) defaults/kde/plasma/look-and-feel/org.debian.desktop/metadata.json $(DESTDIR)/usr/share/plasma/look-and-feel/org.debian.desktop
	$(INSTALL_DATA) defaults/kde/plasma/look-and-feel/org.debian.desktop/contents/defaults $(DESTDIR)/usr/share/plasma/look-and-feel/org.debian.desktop/contents
	install -d $(DESTDIR)/usr/share/plasma/look-and-feel/org.debian.desktop/contents/layouts
	$(INSTALL_DATA) $(wildcard defaults/kde/plasma/look-and-feel/org.debian.desktop/contents/layouts/*) $(DESTDIR)/usr/share/plasma/look-and-feel/org.debian.desktop/contents/layouts/
	install -d $(DESTDIR)/usr/share/plasma/look-and-feel/org.debian.desktop/contents/previews
	$(INSTALL_DATA) $(wildcard defaults/kde/plasma/look-and-feel/org.debian.desktop/contents/previews/*) $(DESTDIR)/usr/share/plasma/look-and-feel/org.debian.desktop/contents/previews/

	# Xfce 4.6
	mkdir -p $(DESTDIR)/usr/share/desktop-base/profiles/xdg-config/xfce4/xfconf/xfce-perchannel-xml
	$(INSTALL_DATA) $(wildcard profiles/xdg-config/xfce4/xfconf/xfce-perchannel-xml/*) $(DESTDIR)/usr/share/desktop-base/profiles/xdg-config/xfce4/xfconf/xfce-perchannel-xml

	# GNOME background descriptors
	mkdir -p $(DESTDIR)/usr/share/gnome-background-properties


	# Space Fun theme (Squeeze’s default)
	### Plymouth theme
	install -d $(DESTDIR)/usr/share/plymouth/themes/spacefun
	$(INSTALL_DATA) $(wildcard spacefun-theme/plymouth/*) $(DESTDIR)/usr/share/plymouth/themes/spacefun
	install -d $(DESTDIR)/usr/share/desktop-base/spacefun-theme
	cd $(DESTDIR)/usr/share/desktop-base/spacefun-theme && ln -s /usr/share/plymouth/themes/spacefun plymouth
	### Login background
	install -d $(DESTDIR)/usr/share/desktop-base/spacefun-theme/login
	$(INSTALL_DATA) $(wildcard spacefun-theme/login/*) $(DESTDIR)/usr/share/desktop-base/spacefun-theme/login

	### Wallpapers
	install -d $(DESTDIR)/usr/share/desktop-base/spacefun-theme/wallpaper/contents/images
	$(INSTALL_DATA) spacefun-theme/wallpaper/metadata.json $(DESTDIR)/usr/share/desktop-base/spacefun-theme/wallpaper
	$(INSTALL_DATA) spacefun-theme/wallpaper/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/spacefun-theme/wallpaper
	$(INSTALL_DATA) $(wildcard spacefun-theme/wallpaper/contents/images/*) $(DESTDIR)/usr/share/desktop-base/spacefun-theme/wallpaper/contents/images/
	$(INSTALL_DATA) spacefun-theme/gnome-wp-list.xml $(DESTDIR)/usr/share/gnome-background-properties/debian-spacefun.xml
	# Wallpaper symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/spacefun-theme/wallpaper SpaceFun

	### Lockscreen (same as wallpaper)
	cd $(DESTDIR)/usr/share/desktop-base/spacefun-theme && ln -s wallpaper lockscreen


	# Joy theme (Wheezy’s default)
	### Plymouth theme
	install -d $(DESTDIR)/usr/share/plymouth/themes/joy
	$(INSTALL_DATA) $(wildcard joy-theme/plymouth/*) $(DESTDIR)/usr/share/plymouth/themes/joy
	install -d $(DESTDIR)/usr/share/desktop-base/joy-theme
	cd $(DESTDIR)/usr/share/desktop-base/joy-theme && ln -s /usr/share/plymouth/themes/joy plymouth
	### Login background
	install -d $(DESTDIR)/usr/share/desktop-base/joy-theme/login
	$(INSTALL_DATA) $(wildcard joy-theme/login/*) $(DESTDIR)/usr/share/desktop-base/joy-theme/login

	### Wallpapers
	install -d $(DESTDIR)/usr/share/desktop-base/joy-theme/wallpaper/contents/images
	$(INSTALL_DATA) joy-theme/wallpaper/metadata.json $(DESTDIR)/usr/share/desktop-base/joy-theme/wallpaper
	$(INSTALL_DATA) joy-theme/wallpaper/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/joy-theme/wallpaper
	$(INSTALL_DATA) $(wildcard joy-theme/wallpaper/contents/images/*) $(DESTDIR)/usr/share/desktop-base/joy-theme/wallpaper/contents/images/
	$(INSTALL_DATA) joy-theme/gnome-wp-list.xml $(DESTDIR)/usr/share/gnome-background-properties/debian-joy.xml
	# Wallpaper symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/joy-theme/wallpaper Joy

	### Lockscreen
	install -d $(DESTDIR)/usr/share/desktop-base/joy-theme/lockscreen/contents/images
	$(INSTALL_DATA) joy-theme/lockscreen/metadata.json $(DESTDIR)/usr/share/desktop-base/joy-theme/lockscreen
	$(INSTALL_DATA) joy-theme/lockscreen/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/joy-theme/lockscreen
	$(INSTALL_DATA) $(wildcard joy-theme/lockscreen/contents/images/*) $(DESTDIR)/usr/share/desktop-base/joy-theme/lockscreen/contents/images/
	# Lock screen symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/joy-theme/lockscreen JoyLockScreen

	# Joy Inksplat theme (Wheezy’s alternate theme)
	install -d $(DESTDIR)/usr/share/desktop-base/joy-inksplat-theme
	### Plymouth theme
	# Reuse « normal » joy theme
	cd $(DESTDIR)/usr/share/desktop-base/joy-inksplat-theme \
		&& ln -s /usr/share/plymouth/themes/joy plymouth \

	### Wallpapers
	install -d $(DESTDIR)/usr/share/desktop-base/joy-inksplat-theme/wallpaper/contents/images
	$(INSTALL_DATA) joy-inksplat-theme/wallpaper/metadata.json $(DESTDIR)/usr/share/desktop-base/joy-inksplat-theme/wallpaper
	$(INSTALL_DATA) joy-inksplat-theme/wallpaper/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/joy-inksplat-theme/wallpaper
	$(INSTALL_DATA) $(wildcard joy-inksplat-theme/wallpaper/contents/images/*) $(DESTDIR)/usr/share/desktop-base/joy-inksplat-theme/wallpaper/contents/images/
	$(INSTALL_DATA) joy-inksplat-theme/gnome-wp-list.xml $(DESTDIR)/usr/share/gnome-background-properties/debian-joy-inksplat.xml
	# Wallpaper symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/joy-inksplat-theme/wallpaper JoyInksplat
	### Lockscreen (same as Joy)
	cd $(DESTDIR)/usr/share/desktop-base/joy-inksplat-theme && ln -s /usr/share/desktop-base/joy-theme/grub grub && ln -s /usr/share/desktop-base/joy-theme/lockscreen lockscreen && ln -s /usr/share/desktop-base/joy-theme/login login


	# Lines theme (Jessie’s default)
	### Plymouth theme
	install -d $(DESTDIR)/usr/share/plymouth/themes/lines
	$(INSTALL_DATA) $(wildcard lines-theme/plymouth/*) $(DESTDIR)/usr/share/plymouth/themes/lines
	install -d $(DESTDIR)/usr/share/desktop-base/lines-theme
	cd $(DESTDIR)/usr/share/desktop-base/lines-theme && ln -s /usr/share/plymouth/themes/lines plymouth
	### Login background
	install -d $(DESTDIR)/usr/share/desktop-base/lines-theme/login
	$(INSTALL_DATA) $(wildcard lines-theme/login/*) $(DESTDIR)/usr/share/desktop-base/lines-theme/login

	### Wallpapers
	install -d $(DESTDIR)/usr/share/desktop-base/lines-theme/wallpaper/contents/images
	$(INSTALL_DATA) lines-theme/wallpaper/metadata.json $(DESTDIR)/usr/share/desktop-base/lines-theme/wallpaper
	$(INSTALL_DATA) lines-theme/wallpaper/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/lines-theme/wallpaper
	$(INSTALL_DATA) $(wildcard lines-theme/wallpaper/contents/images/*) $(DESTDIR)/usr/share/desktop-base/lines-theme/wallpaper/contents/images/
	$(INSTALL_DATA) lines-theme/gnome-wp-list.xml $(DESTDIR)/usr/share/gnome-background-properties/debian-lines.xml
	# Wallpaper symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/lines-theme/wallpaper Lines

	### Lockscreen
	install -d $(DESTDIR)/usr/share/desktop-base/lines-theme/lockscreen/contents/images
	$(INSTALL_DATA) lines-theme/lockscreen/metadata.json $(DESTDIR)/usr/share/desktop-base/lines-theme/lockscreen
	$(INSTALL_DATA) lines-theme/lockscreen/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/lines-theme/lockscreen
	$(INSTALL_DATA) $(wildcard lines-theme/lockscreen/contents/images/*) $(DESTDIR)/usr/share/desktop-base/lines-theme/lockscreen/contents/images/
	# Lock screen symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/lines-theme/lockscreen LinesLockScreen


	# Soft waves theme (Stretch’s default)
	### Plymouth theme
	install -d $(DESTDIR)/usr/share/plymouth/themes/softwaves
	$(INSTALL_DATA) $(wildcard softwaves-theme/plymouth/*) $(DESTDIR)/usr/share/plymouth/themes/softwaves
	install -d $(DESTDIR)/usr/share/desktop-base/softwaves-theme
	cd $(DESTDIR)/usr/share/desktop-base/softwaves-theme && ln -s /usr/share/plymouth/themes/softwaves plymouth
	### Login background
	install -d $(DESTDIR)/usr/share/desktop-base/softwaves-theme/login
	$(INSTALL_DATA) $(wildcard softwaves-theme/login/*) $(DESTDIR)/usr/share/desktop-base/softwaves-theme/login

	### Wallpapers
	install -d $(DESTDIR)/usr/share/desktop-base/softwaves-theme/wallpaper/contents/images
	$(INSTALL_DATA) softwaves-theme/wallpaper/metadata.json $(DESTDIR)/usr/share/desktop-base/softwaves-theme/wallpaper
	$(INSTALL_DATA) softwaves-theme/wallpaper/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/softwaves-theme/wallpaper
	$(INSTALL_DATA) $(wildcard softwaves-theme/wallpaper/contents/images/*) $(DESTDIR)/usr/share/desktop-base/softwaves-theme/wallpaper/contents/images/
	$(INSTALL_DATA) softwaves-theme/gnome-wp-list.xml $(DESTDIR)/usr/share/gnome-background-properties/debian-softwaves.xml
	# Wallpaper symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/softwaves-theme/wallpaper SoftWaves

	### Lockscreen
	install -d $(DESTDIR)/usr/share/desktop-base/softwaves-theme/lockscreen/contents/images
	$(INSTALL_DATA) softwaves-theme/lockscreen/metadata.json $(DESTDIR)/usr/share/desktop-base/softwaves-theme/lockscreen
	$(INSTALL_DATA) softwaves-theme/lockscreen/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/softwaves-theme/lockscreen
	$(INSTALL_DATA) $(wildcard softwaves-theme/lockscreen/contents/images/*) $(DESTDIR)/usr/share/desktop-base/softwaves-theme/lockscreen/contents/images/
	# Lock screen symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/softwaves-theme/lockscreen SoftWavesLockScreen

	# futurePrototype theme (Buster’s default)
	### Plymouth theme
	install -d $(DESTDIR)/usr/share/plymouth/themes/futureprototype
	$(INSTALL_DATA) $(wildcard futureprototype-theme/plymouth/*) $(DESTDIR)/usr/share/plymouth/themes/futureprototype
	install -d $(DESTDIR)/usr/share/desktop-base/futureprototype-theme
	cd $(DESTDIR)/usr/share/desktop-base/futureprototype-theme && ln -s /usr/share/plymouth/themes/futureprototype plymouth

	### Login background
	install -d $(DESTDIR)/usr/share/desktop-base/futureprototype-theme/login
	$(INSTALL_DATA) $(wildcard futureprototype-theme/login/*) $(DESTDIR)/usr/share/desktop-base/futureprototype-theme/login

	### Wallpapers
	install -d $(DESTDIR)/usr/share/desktop-base/futureprototype-theme/wallpaper/contents/images
	$(INSTALL_DATA) futureprototype-theme/wallpaper/metadata.json $(DESTDIR)/usr/share/desktop-base/futureprototype-theme/wallpaper
	$(INSTALL_DATA) futureprototype-theme/wallpaper/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/futureprototype-theme/wallpaper
	$(INSTALL_DATA) $(wildcard futureprototype-theme/wallpaper/contents/images/*) $(DESTDIR)/usr/share/desktop-base/futureprototype-theme/wallpaper/contents/images/
	$(INSTALL_DATA) futureprototype-theme/gnome-wp-list.xml $(DESTDIR)/usr/share/gnome-background-properties/debian-futureprototype.xml
	# Wallpaper symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/futureprototype-theme/wallpaper FuturePrototype

	### Lockscreen is using the same image as wallpaper
	install -d $(DESTDIR)/usr/share/desktop-base/futureprototype-theme/lockscreen/contents/images
	$(INSTALL_DATA) futureprototype-theme/wallpaper/metadata.json $(DESTDIR)/usr/share/desktop-base/futureprototype-theme/lockscreen
	$(INSTALL_DATA) futureprototype-theme/wallpaper/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/futureprototype-theme/lockscreen
	$(INSTALL_DATA) $(wildcard futureprototype-theme/wallpaper/contents/images/*) $(DESTDIR)/usr/share/desktop-base/futureprototype-theme/lockscreen/contents/images/

	### Alternate wallpaper with Debian swirl
	install -d $(DESTDIR)/usr/share/desktop-base/futureprototype-theme/wallpaper-withlogo/contents/images
	$(INSTALL_DATA) futureprototype-theme/wallpaper-withlogo/metadata.json $(DESTDIR)/usr/share/desktop-base/futureprototype-theme/wallpaper-withlogo
	$(INSTALL_DATA) futureprototype-theme/wallpaper-withlogo/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/futureprototype-theme/wallpaper-withlogo
	$(INSTALL_DATA) $(wildcard futureprototype-theme/wallpaper-withlogo/contents/images/*) $(DESTDIR)/usr/share/desktop-base/futureprototype-theme/wallpaper-withlogo/contents/images/
	# Lock screen symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/futureprototype-theme/wallpaper-withlogo FuturePrototypeWithLogo


	# homeworld theme (Bullseye’s default)
	### Plymouth theme
	install -d $(DESTDIR)/usr/share/plymouth/themes/homeworld
	$(INSTALL_DATA) $(wildcard homeworld-theme/plymouth/*) $(DESTDIR)/usr/share/plymouth/themes/homeworld
	install -d $(DESTDIR)/usr/share/desktop-base/homeworld-theme
	cd $(DESTDIR)/usr/share/desktop-base/homeworld-theme && ln -s /usr/share/plymouth/themes/homeworld plymouth
	### Login background
	install -d $(DESTDIR)/usr/share/desktop-base/homeworld-theme/login
	$(INSTALL_DATA) $(wildcard homeworld-theme/login/*) $(DESTDIR)/usr/share/desktop-base/homeworld-theme/login

	### Wallpapers
	install -d $(DESTDIR)/usr/share/desktop-base/homeworld-theme/wallpaper/contents/images
	$(INSTALL_DATA) homeworld-theme/wallpaper/metadata.json $(DESTDIR)/usr/share/desktop-base/homeworld-theme/wallpaper
	$(INSTALL_DATA) homeworld-theme/wallpaper/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/homeworld-theme/wallpaper
	$(INSTALL_DATA) $(wildcard homeworld-theme/wallpaper/contents/images/*) $(DESTDIR)/usr/share/desktop-base/homeworld-theme/wallpaper/contents/images/
	$(INSTALL_DATA) homeworld-theme/gnome-wp-list.xml $(DESTDIR)/usr/share/gnome-background-properties/debian-homeworld.xml
	# Wallpaper symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/homeworld-theme/wallpaper homeworld

	### Lockscreen is using the same image as wallpaper
	install -d $(DESTDIR)/usr/share/desktop-base/homeworld-theme/lockscreen/contents/images
	$(INSTALL_DATA) homeworld-theme/wallpaper/metadata.json $(DESTDIR)/usr/share/desktop-base/homeworld-theme/lockscreen
	$(INSTALL_DATA) homeworld-theme/wallpaper/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/homeworld-theme/lockscreen
	$(INSTALL_DATA) $(wildcard homeworld-theme/wallpaper/contents/images/*) $(DESTDIR)/usr/share/desktop-base/homeworld-theme/lockscreen/contents/images/

	# Lock screen symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/homeworld-theme/wallpaper homeworld_wallpaper

	# emerald theme (Bookworm’s default)
	### Plymouth theme
	install -d $(DESTDIR)/usr/share/plymouth/themes/emerald
	$(INSTALL_DATA) $(wildcard emerald-theme/plymouth/*) $(DESTDIR)/usr/share/plymouth/themes/emerald
	install -d $(DESTDIR)/usr/share/desktop-base/emerald-theme
	cd $(DESTDIR)/usr/share/desktop-base/emerald-theme && ln -s /usr/share/plymouth/themes/emerald plymouth


	### Wallpapers
	install -d $(DESTDIR)/usr/share/desktop-base/emerald-theme/wallpaper/contents/images
	$(INSTALL_DATA) emerald-theme/wallpaper/metadata.json $(DESTDIR)/usr/share/desktop-base/emerald-theme/wallpaper
	$(INSTALL_DATA) emerald-theme/wallpaper/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/emerald-theme/wallpaper
	$(INSTALL_DATA) $(wildcard emerald-theme/wallpaper/contents/images/*) $(DESTDIR)/usr/share/desktop-base/emerald-theme/wallpaper/contents/images/
	$(INSTALL_DATA) emerald-theme/gnome-wp-list.xml $(DESTDIR)/usr/share/gnome-background-properties/debian-emerald.xml
	# Wallpaper symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/emerald-theme/wallpaper emerald

	### Login background
	install -d $(DESTDIR)/usr/share/desktop-base/emerald-theme/login
	$(INSTALL_DATA) $(wildcard emerald-theme/login/*) $(DESTDIR)/usr/share/desktop-base/emerald-theme/login

	### Lockscreen is using the same image as wallpaper
	install -d $(DESTDIR)/usr/share/desktop-base/emerald-theme/lockscreen/contents/images
	$(INSTALL_DATA) emerald-theme/wallpaper/metadata.json $(DESTDIR)/usr/share/desktop-base/emerald-theme/lockscreen
	$(INSTALL_DATA) emerald-theme/wallpaper/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/emerald-theme/lockscreen
	$(INSTALL_DATA) $(wildcard emerald-theme/wallpaper/contents/images/*) $(DESTDIR)/usr/share/desktop-base/emerald-theme/lockscreen/contents/images/

	# Lock screen symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/emerald-theme/wallpaper emerald_wallpaper


	# Moonlight theme
	### Plymouth theme
	install -d $(DESTDIR)/usr/share/plymouth/themes/moonlight
	$(INSTALL_DATA) $(wildcard moonlight-theme/plymouth/*) $(DESTDIR)/usr/share/plymouth/themes/moonlight
	install -d $(DESTDIR)/usr/share/desktop-base/moonlight-theme
	cd $(DESTDIR)/usr/share/desktop-base/moonlight-theme && ln -s /usr/share/plymouth/themes/moonlight plymouth
	### Login background
	install -d $(DESTDIR)/usr/share/desktop-base/moonlight-theme/login
	$(INSTALL_DATA) $(wildcard moonlight-theme/login/*) $(DESTDIR)/usr/share/desktop-base/moonlight-theme/login
	### Wallpapers
	install -d $(DESTDIR)/usr/share/desktop-base/moonlight-theme/wallpaper/contents/images
	$(INSTALL_DATA) moonlight-theme/wallpaper/metadata.json $(DESTDIR)/usr/share/desktop-base/moonlight-theme/wallpaper
	$(INSTALL_DATA) moonlight-theme/wallpaper/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/moonlight-theme/wallpaper
	$(INSTALL_DATA) $(wildcard moonlight-theme/wallpaper/contents/images/*) $(DESTDIR)/usr/share/desktop-base/moonlight-theme/wallpaper/contents/images/
	$(INSTALL_DATA) moonlight-theme/gnome-wp-list.xml $(DESTDIR)/usr/share/gnome-background-properties/debian-moonlight.xml
	# Wallpaper symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/moonlight-theme/wallpaper moonlight

	### Lockscreen
	install -d $(DESTDIR)/usr/share/desktop-base/moonlight-theme/lockscreen/contents/images
	$(INSTALL_DATA) moonlight-theme/lockscreen/metadata.json $(DESTDIR)/usr/share/desktop-base/moonlight-theme/lockscreen
	$(INSTALL_DATA) moonlight-theme/lockscreen/gnome-background.xml $(DESTDIR)/usr/share/desktop-base/moonlight-theme/lockscreen
	$(INSTALL_DATA) $(wildcard moonlight-theme/lockscreen/contents/images/*) $(DESTDIR)/usr/share/desktop-base/moonlight-theme/lockscreen/contents/images/
	# Lock screen symlink for KDE
	install -d $(DESTDIR)/usr/share/wallpapers
	cd $(DESTDIR)/usr/share/wallpapers && ln -s /usr/share/desktop-base/moonlight-theme/lockscreen MoonlightLockScreen

include Makefile.inc
