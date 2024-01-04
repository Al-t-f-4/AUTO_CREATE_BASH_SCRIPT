#!/opt/homebrew/bin/bash


CSRC="confScript"
FILE=myScript.sh
END="EOF"

usage()
{
NAME=$(basename $0)
cat << EOF
	$NAME [PACKAGE]
		-h, --help	this message
		-s, --source	config file with lists ( default: $CSRC )
		-f, --file	create sample file ( default: $FILE )
	Example:
		$NAME -h
		$NAME	( create test file )

EOF
}


while [ -n "$1" ]; do

	case "$1" in
		-h|--help)
			usage
			exit 0
		;;
		
		-s)
			if [ -n "$2" ]; then
				CSRC="$2"
				shift
			fi
		;;

		-f)
			if [ -n "$2" ]; then
				FILE="$2"
				shift
			fi
		;;

		--source=*)
			CSRC="${1#*=}"
		;;
		
		--file=*)
			FILE="${1#*=}"
		;;

		*)
			usage
			exit 1
		;;
	esac

	if [ -z "$1" ]; then
		break
	fi
	shift
done

declare -A SV
declare -A SF
source $CSRC

cat << EOF > $FILE
#!/bin/bash

$( for key in "${!SV[@]}"; do echo "$key=${SV[$key]}"; done)

usage()
{
NAME=\$(basename \$0)
cat << EOF
	\$NAME [PACKAGE] 
		-h, --help	this message
$( for key in ${!SF[@]}; do
echo -e "\t\t-$key, --${SF[$key]}\tdesription ( default: \$${SF[$key]} )"
done)
	Example:
		\$NAME -h
$END
}

while [ -n "\$1" ]; do

	case "\$1" in
	
		-h|--help)
			usage
			exit 0
		;;

$( for key in ${!SF[@]}; do
	echo -e "\t\t-$key) 
		\tif [ -n \"\$2\" ]; then
		\t\t${SF[$key]}=\"\$2\"
		\t\tshift
		\tfi
		;;
	"		
done)
$( for key in ${!SF[@]}; do
	echo -e "\t\t--${SF[$key]}=*)
\t\t\t${SF[$key]}=\${1#*=}
		;;
		"
done)
		*)
			info
			exit 1
		;;

	esac 

	if [ -z "\$1" ]; then
		break
	fi
	shift

done

EOF

chmod +x $FILE

cat $FILE
