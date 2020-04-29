all:	git

zip:
	cd .. ; rm -f bt-l2vpn-vmm.zip ; zip -r bt-l2vpn-vmm.zip bt-l2vpn -x '*.git*'
	exit

git:
	git add .
	git commit -am "`date -u +%Y%m%d-%H:%M:%S`" --no-edit
	git push -u origin master
	exit

git-resync:
	git fetch origin
	git reset --hard origin/master
	git clean -f -d
	exit

