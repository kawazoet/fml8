#!/bin/sh
#
#  Copyright (C) 2001 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under the same terms as Perl itself. 
#
# $FML: INSTALL.sh,v 1.41 2001/12/16 13:33:29 fukachan Exp $
#

# Run this from the top-level fml source directory.

PATH=/bin:/usr/bin:/usr/sbin:/usr/etc:/sbin:/etc
umask 022


get_fml_version () {
   if [ -f .version ];then
	fml_version=`cat .version`
   else
	date=`date +%C%y%m%d`
	fml_version=current-${date}
   fi
}

_mkdir () {
	local dir=$1 
	echo mkdir $dir; 
	test -d $dir || mkdir -p $dir
}


### MAIN ###

# configurations generated by ./configure
. ./config.sh

get_fml_version
default_config_dir=$config_dir/defaults/$fml_version

# check whether $ml_spool_dir exists or not.
need_fix_ml_spool_dir=0
test -d $ml_spool_dir || need_fix_ml_spool_dir=1

for dir in 	$config_dir \
		$config_dir/defaults \
		$config_dir/defaults/$fml_version \
		$lib_dir	\
		$lib_dir/$fml_version	\
		$libexec_dir	\
		$libexec_dir/$fml_version \
		$bindir \
		$ml_spool_dir
do
   test -d $dir || _mkdir $dir
done


if [ ! -f $config_dir/main.cf ];then
	echo creating $config_dir/main.cf
	sed 	-e s@__fml_version__@$fml_version@ \
		-e s@__config_dir__@$config_dir@ \
		fml/etc/main.cf > $config_dir/main.cf
fi

echo updating $default_config_dir/
cp fml/etc/default_config.cf.ja $default_config_dir/default_config.cf
cp fml/etc/config.cf.ja         $default_config_dir/config.cf

for file in include include-ctl aliases
do
   cp fml/etc/$file $default_config_dir/$file
   chmod 644 $default_config_dir/$file
done

echo updating $lib_dir/$fml_version/
cp -pr fml/lib/*	$lib_dir/$fml_version/
cp -pr cpan/lib/*	$lib_dir/$fml_version/
cp -pr img/lib/*	$lib_dir/$fml_version/

echo updating $libexec_dir/$fml_version/
cp -pr fml/libexec/*	$libexec_dir/$fml_version/

echo updating ${bindir}/
for prog in fmldoc fmlthread fmlconf makefml fmlsch fmlhtmlify
do
	echo updating ${bindir}/$prog
	cp fml/bin/$prog ${bindir}/$prog.new
	chmod 755 ${bindir}/$prog.new
	mv ${bindir}/$prog.new ${bindir}/$prog
done

PROGRAMS="fml.pl distribute command ";
PROGRAMS="$PROGRAMS fmlserv mead fmlconf fmldoc"
PROGRAMS="$PROGRAMS fmlthread fmlthread.cgi"
PROGRAMS="$PROGRAMS makefml makefml.cgi"
PROGRAMS="$PROGRAMS fmlsch fmlsch.cgi"
PROGRAMS="$PROGRAMS fmlhtmlify"


#
# check loader is upgraded or not
#
loader_replace=0
if [ -f $libexec_dir/loader ];then
   cmp fml/libexec/loader $libexec_dir/loader > /dev/null

   if [ $? != 0 ];then
	echo "warn: loader updated."
	echo -n "  You must upgrade loader. Replace it ? [y/n]"; read answer;

	if [ "X$answer" = "Xy" ];then
		loader_replace=1
	fi   
   fi
fi

# 
# install loader
#
if [ ! -f $libexec_dir/loader -o $loader_replace = 1 ];then

   echo install libexec/loader
   cp -p fml/libexec/loader $libexec_dir/loader.new.$$
   mv $libexec_dir/loader.new.$$ $libexec_dir/loader

   (
	cd $libexec_dir/
	i=0

	echo -n "   link loader to: "
	for x in $PROGRAMS
	do
		rm -f $x
		ln -s loader $x && echo -n "$x "

		i=`expr $i + 1`
		if [ $i -ge 6 ];then
			echo ""
			echo -n "                   "
			i=0
		fi
	done
	echo ""
   )
fi

iam=`id -un`

if [ "X$iam" != Xroot ];then
	echo error: run $0 as root
	exit 1
fi

id -un $owner 2>/dev/null || (
	echo warning: user $owner is not defined
)

grep "^${group}:" /etc/group >/dev/null || (
	echo warning: group $group is not defined
)

if [ $need_fix_ml_spool_dir = 1 ]; then
   if [ -d $ml_spool_dir -a -w $ml_spool_dir ]; then
	echo set up the owner of $ml_spool_dir to be $owner
	chown -R $owner:$group $ml_spool_dir
   fi
else
  echo "info: $ml_spool_dir exists. We do not touch it.";
fi

exit 0
