#!/bin/sh
echo -n "Please enter the location of the file (leave empty to print on stdout): "; read output
if [ "$output" = "" ]
then
	output="stdout"
else
	if [ -f "$output" -a ! -w "$output" ]
	then
		echo "ERROR: You cannot write to $output"
		exit
	fi
fi
echo -n "Please enter the desired username: "; read user
if [ "$user" = "" ]
then
	echo "ERROR: User field cannot be empty"
	exit
fi
if [ $output != "stdout" ]
then
	if [ "`grep $user $output 2>/dev/null`" != "" ]
	then
		echo "ERROR: User $user already exists."
		exit
	fi
fi
settings=$(stty -g)
stty -echo
echo -n "Please enter the password for the user $user: "; read passwd
stty "$settings"
echo 
if [ "$passwd" = "" ]
then
	echo "ERROR: Password cannot be empty"
	exit
fi
echo "Please select:"
echo "	1) Encrypt password using crypt(3) [default]"
echo "	2) Encrypt password using apache md5"
echo "	3) Encrypt password using md5sum(1)"
read choice
if [ "$choice" = "" ]
then
	choice=1
fi
case $choice in
	1)
		if [ "$output" = "stdout" ]
		then
			printf "$user:$(openssl passwd -crypt $passwd)\n"
		else
			printf "$user:$(openssl passwd -crypt $passwd)\n" >> $output
		fi
	;;
	2)
		if [ "$output" = "stdout" ]
		then
			printf "$user:$(openssl passwd -apr1 $passwd)\n"
		else
			printf "$user:$(openssl passwd -apr1 $passwd)\n" >> $output
		fi
	;;
	3)
		if [ "$output" = "stdout" ]
		then
			printf "$user:$(openssl passwd -1 $passwd)\n"
		else
			printf "$user:$(openssl passwd -1 $passwd)\n" >> $output
		fi
	;;
	*)
		echo "Wrong choice."
		exit
	;;
esac
if [ "$output" != "stdout" ]
then
	echo "User $user added in $output"
fi
