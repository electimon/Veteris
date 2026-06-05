LDID := /usr/local/bin/ldid
IPHONE_IP:=192.168.0.143
THINSERVER_IP := 127.0.0.1
PROJECTNAME:=Veteris_
APPFOLDER:=xcbuild/Veteris.app
DEBFOLDER:=xcbuild/Veteris-deb
INSTALLFOLDER:=Veteris.app
VERSION := $(shell xmlstarlet sel --net -t -m "/plist/dict/key[.='CFBundleVersion']" -v "following-sibling::string[1]"  Veteris/Veteris-Info.plist)

CC:=ios-clang
CPP:=ios-clang++

CFLAGS += -miphoneos-version-min=5.0 -fblocks -fobjc-arc -include "Veteris/Veteris-Prefix.pch" -I./Veteris -I./Veteris/ActionSheetPicker -I./Veteris/Classes -I./Veteris/Classes/../Clutch -I./Veteris/Classes/../Clutch/minizip -I./Veteris/Classes/AppInfo -I./Veteris/Classes/AppsTableViewController -I./Veteris/Classes/CategoriesTableViewController -I./Veteris/Classes/CategorySelectedViewController -I./Veteris/Classes/CrackTableViewCell -I./Veteris/Classes/CrackTableViewController -I./Veteris/Classes/CrackViewController -I./Veteris/Classes/FeaturedTableViewController -I./Veteris/Classes/SearchViewController -I./Veteris/Classes/SettingsTableViewController -I./Veteris/SVProgressHUD -I.

CPPFLAGS += -include "Veteris/Veteris-Prefix.pch" -I./Veteris -I./Veteris/ActionSheetPicker -I./Veteris/Classes -I./Veteris/Classes/../Clutch -I./Veteris/Classes/../Clutch/minizip -I./Veteris/Classes/AppInfo -I./Veteris/Classes/AppsTableViewController -I./Veteris/Classes/CategoriesTableViewController -I./Veteris/Classes/CategorySelectedViewController -I./Veteris/Classes/CrackTableViewCell -I./Veteris/Classes/CrackTableViewController -I./Veteris/Classes/CrackViewController -I./Veteris/Classes/FeaturedTableViewController -I./Veteris/Classes/SearchViewController -I./Veteris/Classes/SettingsTableViewController -I./Veteris/SVProgressHUD -I.

LDFLAGS += -lz
LDFLAGS += -framework QuartzCore
LDFLAGS += -framework Security
LDFLAGS += -framework Foundation
LDFLAGS += -framework UIKit
LDFLAGS += -framework MobileInstallation
LDFLAGS += -framework CoreGraphics


all: $(PROJECTNAME)

OBJS+=  \
	./Veteris/Classes/../Clutch/ZipArchive.o \
	./Veteris/Classes/../Clutch/Localization.o \
	./Veteris/Classes/../Clutch/sha1.o \
	./Veteris/ActionSheetPicker/ActionSheetDistancePicker.o \
	./Veteris/Classes/../Clutch/minizip/miniunz.o \
	./Veteris/Classes/../Clutch/API.o \
	./Veteris/Classes/../Clutch/minizip/ioapi.o \
	./Veteris/Classes/FeaturedTableViewController/FeaturedTableViewController.o \
	./Veteris/Classes/AppInfo/AppInfo.o \
	./Veteris/KeychainItemWrapper.o \
	./Veteris/ActionSheetPicker/DistancePickerView.o \
	./Veteris/Classes/../Clutch/ApplicationLister.o \
	./Veteris/Classes/../Clutch/minizip/mztools.o \
	./Veteris/Classes/CrackTableViewController/CrackTableViewController.o \
	./Veteris/Classes/CrackViewController/CrackViewController.o \
	./Veteris/Classes/FeaturedTableViewController/FeaturedTableViewCell.o \
	./Veteris/ActionSheetPicker/ActionSheetDatePicker.o \
	./Veteris/Classes/CategoriesTableViewController/CategoriesTableViewCell.o \
	./Veteris/Classes/VAPIHelper.o \
	./Veteris/Classes/SearchViewController/SearchTableViewCell.o \
	./Veteris/Classes/CategorySelectedViewController/CategorySelectedViewController.o \
	./Veteris/ActionSheetPicker/AbstractActionSheetPicker.o \
	./Veteris/main.o \
	./Veteris/Classes/../Clutch/Application.o \
	./Veteris/SVProgressHUD/SVProgressHUD.o \
	./Veteris/Classes/../Clutch/izip.o \
	./Veteris/Classes/../Clutch/minizip/minizip.o \
	./Veteris/Classes/SettingsTableViewController/SettingsTableViewController.o \
	./Veteris/Classes/SearchViewController/SearchViewController.o \
	./Veteris/Classes/../Clutch/minizip/zip.o \
	./Veteris/Classes/CrackTableViewCell/CrackTableViewCell.o \
	./Veteris/ActionSheetPicker/ActionSheetCustomPicker.o \
	./Veteris/ActionSheetPicker/ActionSheetStringPicker.o \
	./Veteris/Classes/../Clutch/Cracker.o \
	./Veteris/Classes/../Clutch/minizip/unzip.o \
	./Veteris/Classes/../Clutch/scinfo.o \
	./Veteris/Classes/CategoriesTableViewController/CategoriesTableViewController.o \
	./Veteris/Classes/../Clutch/Device.o \
	./Veteris/Classes/../Clutch/Binary.o \
	./Veteris/AppDelegate.o \
	./Veteris/Classes/AppsTableViewController/AppsTableViewController.o \
	./Veteris/Classes/../Clutch/Preferences.o

$(PROJECTNAME): \
	./Veteris/Classes/../Clutch/ZipArchive.o \
	./Veteris/Classes/../Clutch/Localization.o \
	./Veteris/Classes/../Clutch/sha1.o \
	./Veteris/ActionSheetPicker/ActionSheetDistancePicker.o \
	./Veteris/Classes/../Clutch/minizip/miniunz.o \
	./Veteris/Classes/../Clutch/API.o \
	./Veteris/Classes/../Clutch/minizip/ioapi.o \
	./Veteris/Classes/FeaturedTableViewController/FeaturedTableViewController.o \
	./Veteris/Classes/AppInfo/AppInfo.o \
	./Veteris/KeychainItemWrapper.o \
	./Veteris/ActionSheetPicker/DistancePickerView.o \
	./Veteris/Classes/../Clutch/ApplicationLister.o \
	./Veteris/Classes/../Clutch/minizip/mztools.o \
	./Veteris/Classes/CrackTableViewController/CrackTableViewController.o \
	./Veteris/Classes/CrackViewController/CrackViewController.o \
	./Veteris/Classes/FeaturedTableViewController/FeaturedTableViewCell.o \
	./Veteris/ActionSheetPicker/ActionSheetDatePicker.o \
	./Veteris/Classes/CategoriesTableViewController/CategoriesTableViewCell.o \
	./Veteris/Classes/VAPIHelper.o \
	./Veteris/Classes/SearchViewController/SearchTableViewCell.o \
	./Veteris/Classes/CategorySelectedViewController/CategorySelectedViewController.o \
	./Veteris/ActionSheetPicker/AbstractActionSheetPicker.o \
	./Veteris/main.o \
	./Veteris/Classes/../Clutch/Application.o \
	./Veteris/SVProgressHUD/SVProgressHUD.o \
	./Veteris/Classes/../Clutch/izip.o \
	./Veteris/Classes/../Clutch/minizip/minizip.o \
	./Veteris/Classes/SettingsTableViewController/SettingsTableViewController.o \
	./Veteris/Classes/SearchViewController/SearchViewController.o \
	./Veteris/Classes/../Clutch/minizip/zip.o \
	./Veteris/Classes/CrackTableViewCell/CrackTableViewCell.o \
	./Veteris/ActionSheetPicker/ActionSheetCustomPicker.o \
	./Veteris/ActionSheetPicker/ActionSheetStringPicker.o \
	./Veteris/Classes/../Clutch/Cracker.o \
	./Veteris/Classes/../Clutch/minizip/unzip.o \
	./Veteris/Classes/../Clutch/scinfo.o \
	./Veteris/Classes/CategoriesTableViewController/CategoriesTableViewController.o \
	./Veteris/Classes/../Clutch/Device.o \
	./Veteris/Classes/../Clutch/Binary.o \
	./Veteris/AppDelegate.o \
	./Veteris/Classes/AppsTableViewController/AppsTableViewController.o \
	./Veteris/Classes/../Clutch/Preferences.o
	mkdir -p xcbuild
	$(CC) $(CFLAGS) $(LDFLAGS) $(filter %.o,$^) -o xcbuild/$@
	ldid -SVeteris/ent.xml xcbuild/$@

./Veteris/Classes/../Clutch/ZipArchive.o: ./Veteris/Classes/../Clutch/ZipArchive.m
	$(CC) -c $(CFLAGS) -fno-objc-arc $< -o $@

./Veteris/Classes/../Clutch/Localization.o: ./Veteris/Classes/../Clutch/Localization.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/../Clutch/sha1.o: ./Veteris/Classes/../Clutch/sha1.c
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/ActionSheetPicker/ActionSheetDistancePicker.o: ./Veteris/ActionSheetPicker/ActionSheetDistancePicker.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/../Clutch/minizip/miniunz.o: ./Veteris/Classes/../Clutch/minizip/miniunz.c
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/../Clutch/API.o: ./Veteris/Classes/../Clutch/API.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/../Clutch/minizip/ioapi.o: ./Veteris/Classes/../Clutch/minizip/ioapi.c
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/FeaturedTableViewController/FeaturedTableViewController.o: ./Veteris/Classes/FeaturedTableViewController/FeaturedTableViewController.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/AppInfo/AppInfo.o: ./Veteris/Classes/AppInfo/AppInfo.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/KeychainItemWrapper.o: ./Veteris/KeychainItemWrapper.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/ActionSheetPicker/DistancePickerView.o: ./Veteris/ActionSheetPicker/DistancePickerView.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/../Clutch/ApplicationLister.o: ./Veteris/Classes/../Clutch/ApplicationLister.m
	$(CC) -c $(CFLAGS) -fno-objc-arc $< -o $@

./Veteris/Classes/../Clutch/minizip/mztools.o: ./Veteris/Classes/../Clutch/minizip/mztools.c
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/CrackTableViewController/CrackTableViewController.o: ./Veteris/Classes/CrackTableViewController/CrackTableViewController.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/CrackViewController/CrackViewController.o: ./Veteris/Classes/CrackViewController/CrackViewController.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/FeaturedTableViewController/FeaturedTableViewCell.o: ./Veteris/Classes/FeaturedTableViewController/FeaturedTableViewCell.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/ActionSheetPicker/ActionSheetDatePicker.o: ./Veteris/ActionSheetPicker/ActionSheetDatePicker.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/CategoriesTableViewController/CategoriesTableViewCell.o: ./Veteris/Classes/CategoriesTableViewController/CategoriesTableViewCell.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/VAPIHelper.o: ./Veteris/Classes/VAPIHelper.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/SearchViewController/SearchTableViewCell.o: ./Veteris/Classes/SearchViewController/SearchTableViewCell.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/CategorySelectedViewController/CategorySelectedViewController.o: ./Veteris/Classes/CategorySelectedViewController/CategorySelectedViewController.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/ActionSheetPicker/AbstractActionSheetPicker.o: ./Veteris/ActionSheetPicker/AbstractActionSheetPicker.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/main.o: ./Veteris/main.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/../Clutch/Application.o: ./Veteris/Classes/../Clutch/Application.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/SVProgressHUD/SVProgressHUD.o: ./Veteris/SVProgressHUD/SVProgressHUD.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/../Clutch/izip.o: ./Veteris/Classes/../Clutch/izip.m
	$(CC) -c $(CFLAGS) -fno-objc-arc $< -o $@

./Veteris/Classes/../Clutch/minizip/minizip.o: ./Veteris/Classes/../Clutch/minizip/minizip.c
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/SettingsTableViewController/SettingsTableViewController.o: ./Veteris/Classes/SettingsTableViewController/SettingsTableViewController.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/SearchViewController/SearchViewController.o: ./Veteris/Classes/SearchViewController/SearchViewController.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/../Clutch/minizip/zip.o: ./Veteris/Classes/../Clutch/minizip/zip.c
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/CrackTableViewCell/CrackTableViewCell.o: ./Veteris/Classes/CrackTableViewCell/CrackTableViewCell.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/ActionSheetPicker/ActionSheetCustomPicker.o: ./Veteris/ActionSheetPicker/ActionSheetCustomPicker.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/ActionSheetPicker/ActionSheetStringPicker.o: ./Veteris/ActionSheetPicker/ActionSheetStringPicker.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/../Clutch/Cracker.o: ./Veteris/Classes/../Clutch/Cracker.m
	$(CC) -c $(CFLAGS) -fobjc-weak -fno-objc-arc $< -o $@

./Veteris/Classes/../Clutch/minizip/unzip.o: ./Veteris/Classes/../Clutch/minizip/unzip.c
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/../Clutch/scinfo.o: ./Veteris/Classes/../Clutch/scinfo.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/CategoriesTableViewController/CategoriesTableViewController.o: ./Veteris/Classes/CategoriesTableViewController/CategoriesTableViewController.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/../Clutch/Device.o: ./Veteris/Classes/../Clutch/Device.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/../Clutch/Binary.o: ./Veteris/Classes/../Clutch/Binary.m
	$(CC) -c $(CFLAGS) -fno-objc-arc $< -o $@

./Veteris/AppDelegate.o: ./Veteris/AppDelegate.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/AppsTableViewController/AppsTableViewController.o: ./Veteris/Classes/AppsTableViewController/AppsTableViewController.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Veteris/Classes/../Clutch/Preferences.o: ./Veteris/Classes/../Clutch/Preferences.m
	$(CC) -c $(CFLAGS)  $< -o $@

INFOPLIST:=Veteris/Veteris-Info.plist

RESOURCES += \
	./Veteris/Images.xcassets \
	./Veteris/Images/CrackTabIcon@2x.png \
	./Veteris/Images/Default-568h@2x.png \
	./Veteris/Images/Default.png \
	./Veteris/Images/Default@2x.png \
	./Veteris/Images/arrow.png \
	./Veteris/Images/categories.png \
	./Veteris/Images/featured.png \
	./Veteris/Images/more.png \
	./Veteris/Images/search.png \
	./Veteris/Images/updates.png \
	./Veteris/Images/AppIcon29x29.png \
	./Veteris/Images/AppIcon29x29@2x.png \
	./Veteris/Images/AppIcon40x40@2x.png \
	./Veteris/Images/AppIcon57x57.png \
	./Veteris/Images/AppIcon57x57@2x.png \
	./Veteris/Images/AppIcon60x60@2x.png \
	./Veteris/SVProgressHUD/SVProgressHUD.bundle \
	./Veteris/Settings.bundle \
	./Veteris/en.lproj \
	./Veteris/Veteris

dist: $(PROJECTNAME)
	mkdir -p $(APPFOLDER)
	rm -rf Veteris/en.lproj/MainStoryboard.storyboardc
	sshpass -p _1 ssh -oHostKeyAlgorithms=ssh-rsa -p 160 root@$(THINSERVER_IP) "rm -rf /srv/MainStoryboard.storyboardc /srv/MainStoryboard.storyboard"
	sshpass -p _1 scp -oHostKeyAlgorithms=ssh-rsa -P 160 Veteris/en.lproj/MainStoryboard.storyboard root@$(THINSERVER_IP):/mnt/Public/Temp/
	sshpass -p weed ssh -oHostKeyAlgorithms=ssh-rsa root@192.168.0.232 '/Applications/Xc2ode.app/Contents/Developer/usr/bin/ibtool --errors --warnings --notices --minimum-deployment-target 5.0 --output-format human-readable-text --compile /Volumes/NAS/Public/Temp/MainStoryboard.storyboardc /Volumes/NAS/Public/Temp/MainStoryboard.storyboard'
	sshpass -p _1 scp -r -oHostKeyAlgorithms=ssh-rsa -P 160 root@$(THINSERVER_IP):/mnt/Public/Temp/MainStoryboard.storyboardc Veteris/en.lproj/
	cp -r $(RESOURCES) $(APPFOLDER)
	cp $(INFOPLIST) $(APPFOLDER)/Info.plist
	cp xcbuild/$(PROJECTNAME) $(APPFOLDER)
	sed -i 's|$${EXECUTABLE_NAME}|Veteris|g' $(APPFOLDER)/Info.plist
	sed -i 's|$${PRODUCT_NAME}|Veteris|g' $(APPFOLDER)/Info.plist
	sed -i 's|$${PRODUCT_NAME:identifier}|veteris|g' $(APPFOLDER)/Info.plist
	sed -i 's|$${PRODUCT_NAME:rfc1034identifier}|veteris|g' $(APPFOLDER)/Info.plist
	find $(APPFOLDER) -name \*.png|xargs ios-pngcrush -c
	find $(APPFOLDER) -name \*.plist|xargs ios-plutil -c
	find $(APPFOLDER) -name \*.strings|xargs ios-plutil -c
	chown 0:0 $(APPFOLDER)/Veteris
	chmod 755 $(APPFOLDER)/Veteris
	chmod 6755 $(APPFOLDER)/Veteris_
	chown 0:0 $(APPFOLDER)/Veteris_


langs:
	ios-genLocalization

install: dist
ifeq ($(IPHONE_IP),)
	echo "Please set IPHONE_IP"
else
	sshpass -p alpine ssh -oHostKeyAlgorithms=ssh-rsa root@$(IPHONE_IP) 'rm -fr /Applications/$(INSTALLFOLDER)'
	sshpass -p alpine scp -oHostKeyAlgorithms=ssh-rsa -O -r $(APPFOLDER) root@$(IPHONE_IP):/Applications/$(INSTALLFOLDER)
	echo "Application $(INSTALLFOLDER) installed"
	sshpass -p alpine ssh -oHostKeyAlgorithms=ssh-rsa mobile@$(IPHONE_IP) 'killall -9 Veteris_'
endif

deb: dist
	mkdir $(DEBFOLDER)/DEBIAN -p
	mkdir $(DEBFOLDER)/Applications -p
	cp -ra $(APPFOLDER) $(DEBFOLDER)/Applications/
	cp deb-stuff/control $(DEBFOLDER)/DEBIAN/control
	echo Version: $(VERSION) >> $(DEBFOLDER)/DEBIAN/control
	dpkg-deb -b -Zgzip --root-owner-group $(DEBFOLDER) xcbuild/Veteris-v$(VERSION).deb

push: deb
	sshpass -P passphrase -p 1 ssh 1pwn "cd /var/www/html/dev; rm -rf packs/Veteris*"
	sshpass -P passphrase -p 1 scp xcbuild/Veteris-v$(VERSION).deb 1pwn:/var/www/html/dev/packs/
	sshpass -P passphrase -p 1 ssh 1pwn "cd /var/www/html/dev; ./repo.sh"
	postDisc Veteris Veteris-v$(VERSION).deb "$(shell cat changelog.txt)"

uninstall:
ifeq ($(IPHONE_IP),)
	echo "Please set IPHONE_IP"
else
	sshpass -p alpine ssh -oHostKeyAlgorithms=ssh-rsa root@$(IPHONE_IP) 'rm -fr /Applications/$(INSTALLFOLDER)'
	sshpass -p alpine ssh -oHostKeyAlgorithms=ssh-rsa mobile@$(IPHONE_IP) 'uicache'
	echo "Application $(INSTALLFOLDER) uninstalled"
endif

clean:
	find . -name \*.o|xargs rm -rf
	rm -rf xcbuild
