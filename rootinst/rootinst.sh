#!/bin/bash
#ssh 192.168.1.9 cp -rav /var/mobile/Applications/*/Veteris.app /Applications/
#ssh 192.168.1.9 uicache
scp ./rootinst root@192.168.1.9:/tmp/
scp ./Veteris root@192.168.1.9:/tmp/
scp ./ent.xml root@192.168.1.9:/tmp/
ssh root@192.168.1.9 bash /tmp/rootinst
