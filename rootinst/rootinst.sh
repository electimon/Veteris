#!/bin/bash
#ssh 192.168.1.8 cp -rav /var/mobile/Applications/*/Veteris.app /Applications/
#ssh 192.168.1.8 uicache
scp ./rootinst root@192.168.1.11:/tmp/
scp ./Veteris root@192.168.1.11:/tmp/
scp ./ent.xml root@192.168.1.11:/tmp/
ssh root@192.168.1.11 bash /tmp/rootinst
