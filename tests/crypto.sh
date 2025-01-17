#!/bin/sh

#
# Get the tests directory from $0.
#
testsdir=`dirname "$0"`

exitcode=0
passed=`cat .passed`
failed=`cat .failed`

# Only attempt OpenSSL-specific tests when compiled with the library.

if grep '^#define HAVE_LIBCRYPTO 1$' ../config.h >/dev/null
then
	if ${testsdir}/TESTonce esp1 ${testsdir}/02-sunrise-sunset-esp.pcap ${testsdir}/esp1.out '-E "0x12345678@192.1.2.45 3des-cbc-hmac96:0x4043434545464649494a4a4c4c4f4f515152525454575758"'
	then
		passed=`expr $passed + 1`
		echo $passed >.passed
	else
		failed=`expr $failed + 1`
		echo $failed >.failed
		exitcode=1
	fi
	if ${testsdir}/TESTonce esp2 ${testsdir}/08-sunrise-sunset-esp2.pcap ${testsdir}/esp2.out '-E "0x12345678@192.1.2.45 3des-cbc-hmac96:0x43434545464649494a4a4c4c4f4f51515252545457575840,0xabcdabcd@192.0.1.1 3des-cbc-hmac96:0x434545464649494a4a4c4c4f4f5151525254545757584043"'
	then
		passed=`expr $passed + 1`
		echo $passed >.passed
	else
		failed=`expr $failed + 1`
		echo $failed >.failed
		exitcode=1
	fi
	if ${testsdir}/TESTonce esp3 ${testsdir}/02-sunrise-sunset-esp.pcap ${testsdir}/esp1.out '-E "3des-cbc-hmac96:0x4043434545464649494a4a4c4c4f4f515152525454575758"'
	then
		passed=`expr $passed + 1`
		echo $passed >.passed
	else
		failed=`expr $failed + 1`
		echo $failed >.failed
		exitcode=1
	fi
	# Reading the secret(s) from a file does not work with Capsicum.
	if grep '^#define HAVE_CAPSICUM 1$' ../config.h >/dev/null
	then
		FORMAT='    %-35s: TEST SKIPPED (compiled w/Capsicum)\n'
		printf "$FORMAT" esp4
		printf "$FORMAT" esp5
		printf "$FORMAT" espudp1
		printf "$FORMAT" ikev2pI2
		printf "$FORMAT" isakmp4
	else
		if ${testsdir}/TESTonce esp4 ${testsdir}/08-sunrise-sunset-esp2.pcap ${testsdir}/esp2.out "-E \"file ${testsdir}/esp-secrets.txt\""
		then
			passed=`expr $passed + 1`
			echo $passed >.passed
		else
			failed=`expr $failed + 1`
			echo $failed >.failed
			exitcode=1
		fi
		if ${testsdir}/TESTonce esp5 ${testsdir}/08-sunrise-sunset-aes.pcap ${testsdir}/esp5.out "-E \"file ${testsdir}/esp-secrets.txt\""
		then
			passed=`expr $passed + 1`
			echo $passed >.passed
		else
			failed=`expr $failed + 1`
			echo $failed >.failed
			exitcode=1
		fi
		if ${testsdir}/TESTonce espudp1 ${testsdir}/espudp1.pcap ${testsdir}/espudp1.out "-nnnn -E \"file ${testsdir}/esp-secrets.txt\""
		then
			passed=`expr $passed + 1`
			echo $passed >.passed
		else
			failed=`expr $failed + 1`
			echo $failed >.failed
			exitcode=1
		fi
		if ${testsdir}/TESTonce ikev2pI2 ${testsdir}/ikev2pI2.pcap ${testsdir}/ikev2pI2.out "-E \"file ${testsdir}/ikev2pI2-secrets.txt\" -v -v -v -v"
		then
			passed=`expr $passed + 1`
			echo $passed >.passed
		else
			failed=`expr $failed + 1`
			echo $failed >.failed
			exitcode=1
		fi
		if ${testsdir}/TESTonce isakmp4 ${testsdir}/isakmp4500.pcap ${testsdir}/isakmp4.out "-E \"file esp-secrets.txt\""
		then
			passed=`expr $passed + 1`
			echo $passed >.passed
		else
			failed=`expr $failed + 1`
			echo $failed >.failed
			exitcode=1
		fi
	fi
	if ${testsdir}/TESTonce bgp-as-path-oobr-ssl ${testsdir}/bgp-as-path-oobr.pcap ${testsdir}/bgp-as-path-oobr-ssl.out '-vvv -e'
	then
		passed=`expr $passed + 1`
		echo $passed >.passed
	else
		failed=`expr $failed + 1`
		echo $failed >.failed
		exitcode=1
	fi
	if ${testsdir}/TESTonce bgp-aigp-oobr-ssl ${testsdir}/bgp-aigp-oobr.pcap ${testsdir}/bgp-aigp-oobr-ssl.out '-vvv -e'
	then
		passed=`expr $passed + 1`
		echo $passed >.passed
	else
		failed=`expr $failed + 1`
		echo $failed >.failed
		exitcode=1
	fi
	FORMAT='    %-35s: TEST SKIPPED (compiled w/OpenSSL)\n'
	printf "$FORMAT" bgp-as-path-oobr-nossl
	printf "$FORMAT" bgp-aigp-oobr-nossl
else
	FORMAT='    %-35s: TEST SKIPPED (compiled w/o OpenSSL)\n'
	printf "$FORMAT" esp1
	printf "$FORMAT" esp2
	printf "$FORMAT" esp3
	printf "$FORMAT" esp4
	printf "$FORMAT" esp5
	printf "$FORMAT" espudp1
	printf "$FORMAT" ikev2pI2
	printf "$FORMAT" isakmp4
	printf "$FORMAT" bgp-as-path-oobr-ssl
	printf "$FORMAT" bgp-aigp-oobr-ssl
	if ${testsdir}/TESTonce bgp-as-path-oobr-nossl ${testsdir}/bgp-as-path-oobr.pcap ${testsdir}/bgp-as-path-oobr-nossl.out '-vvv -e'
	then
		passed=`expr $passed + 1`
		echo $passed >.passed
	else
		failed=`expr $failed + 1`
		echo $failed >.failed
		exitcode=1
	fi
	if ${testsdir}/TESTonce bgp-aigp-oobr-nossl ${testsdir}/bgp-aigp-oobr.pcap ${testsdir}/bgp-aigp-oobr-nossl.out '-vvv -e'
	then
		passed=`expr $passed + 1`
		echo $passed >.passed
	else
		failed=`expr $failed + 1`
		echo $failed >.failed
		exitcode=1
	fi
fi

exit $exitcode
