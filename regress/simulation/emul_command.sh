#!/bin/sh
#
# $FML: emul_command.sh,v 1.5 2004/03/14 07:01:08 fukachan Exp $
#

buf=$PWD/__command$$__
trap "rm -f $buf" 0 1 3 15

header_file=${header:-text=empty}

# option
option=${OPTION:-test_key=test_value}


DO () {
   (
	pwd=`pwd`
	cd ../.. || exit 1
	pwd

	test -f $msg || return;

	maincf=/tmp/main.cf.$$
	trap "rm -f $maincf" 0 1 3 15
	sed 	-e "s@\$pwd@$PWD@g" \
		-e "s@^debug.*@debug = $debug@" \
		regress/simulation/main.cf > $maincf


	env MODE=COMMAND regress/message/scramble.pl $msg |\
	${PERL:-perl} -w fml/libexec/loader -c $maincf \
		-o $option \
		--ctladdr \
		/var/spool/ml/elena
	echo "-- exit code: $?"
   )
}

(cd ../../fml/etc/;sh .gen.sh)

cat ./../testmails/$header_file > $buf
cat >> $buf

list=$buf

for msg in $list
do
   DO $msg
done

exit 0

