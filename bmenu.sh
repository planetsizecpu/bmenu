!/bin/bash
####################################
# Script : bmenu.sh
# Author : PlanetSizeCpu
# Date   : 03-03-1992
# Use    : Menus manager shell
# Remarks: It uses "tput" command for screen controls

####################################
# Environment settings
####################################

# Ending program settings
end()
{
	echo $CLS
	echo $NOR'\n        MENU: Menu management in shell,  by @planetsizecpu  1992'
	echo
	exit
}

# Argument defaults
ARG1=$1
if (test -n "$ARG1" )
	then MENU0=$ARG1.m 
	else MENU0="menu.m"
fi

# Decode terminal screen sequences
getterm()
{
	CLS=`tput clear`
	HOM=`tput home`
	NOR=`tput sgr0` 
	REV=`tput rev` 
	BLI=`tput blink` 
	BOL=`tput bold` 
}

# Traps
trap "tput sgr0 ; echo '\n       MENU Interrupted, press (CTRL+D) to exit shell.' ; exit" 2
DATE=`date +%a%t%d%t%m%t%y`

####################################
# Functions definition
####################################

# Read and show options for current menu
getmenu()
{
	if [ -z "$MENU0" ]
	   then end
        fi
	if [ ! -r "$MENU0" ]
		then echo 'Non existent menu !' ; exit 2
	else 

	# Paint menu title
	TIT=`awk ' NR==1 {print " "$0" " ; exit } ' $MENU0`
	echo $CLS$REV"                                                                   "$DATE$NOR
	echo $HOM$REV$TIT$NOR

	# Paint exit option if apply
	SAL=`awk 'BEGIN {FS=","} NR==2 {print $1 ; exit }' $MENU0`
	case $SAL in
	      "0") : ;;
	      *) echo '  0  -  Exit  ' ;;
	esac

	# Paint menu options
	awk 'BEGIN {FS=","} /[1-9]?,/ {printf "%3d %3s %-49s\n",$1," - ",$2 }' $MENU0
	echo $REV"										"$NOR
	fi

	# Look for biggest option number
	maxop=`awk 'BEGIN {FS=","} /[1-9]?,/ {maxop=$1} END{print maxop+1}' $MENU0`
}

# Ask for Enter Key
askpause()
{
	echo
        echo -n 'Press (ENTER) to continue . . .'
	read pause
}

# Ask for arguments
askargum()
{
	echo
        echo -n 'Enter command arguments: '
	read commandA
}


# Ask end evaluate menu option
askmenu()
{
	echo 
	echo -n $REV'        SELECT OPTION:         '
	read option
	echo $NOR

	##################################################################
	# Test if there is an option
	if [ -z "$option" ]
	   then getmenu ; askmenu
        fi

        ##############################################################
        # Special case: ksh (AIX korn shell)
        if [ $option = "ksh" ]
	then
		echo
		echo "KORN COMMAND LINE"
		echo
		uname -a
		echo
		date
		echo
		who am i
		echo
		ksh
	fi

        ##############################################################
        # Special case: bash (linux shell)
        if [ $option = "bash" ]
	then
		echo
		echo "BASH COMAND LINE"
		echo
		uname -a
		echo
		date
		echo
		who am i
		echo
		bash
	fi


	##################################################################
	# Test for zero option to go back or exit
	if [ $option = "0" -o $option = "00" ]
	then
	        if [ -n $MENU1 ]
		then
			MENU0=$MENU1;MENU1=$MENU2;MENU2=$MENU3;MENU3=$MENU4;
			MENU4=$MENU5;MENU5=$MENU6;MENU6=$MENU7;MENU7=$MENU8;
			MENU8="" ; getmenu ; askmenu
		else
			exit 0
		fi
	fi

	##################################################################
	# Test if option exists in menu
	result=`grep -c $option, $MENU0`
	if [ $result -lt 1 ]
	then
		getmenu
		askmenu
	fi

	##################################################################
	# Test for option number in range
	if [ $option -gt 0 -a $option -lt $maxop ]
	then
        	# Search command line
        	comline=`awk 'BEGIN{FS=","} $1==ARGV[2] {print FNR+1;exit}' $MENU0 $option`
        	# Read command
		commandS=`awk ' NR==ARGV[2] {print $1;exit}' $MENU0 $comline`
        	# Read argument
		commandA=`awk ' NR==ARGV[2] {print $2;exit}' $MENU0 $comline`
        	# Read whole command line
		commandL=`awk ' NR==ARGV[2] {print $0;exit}' $MENU0 $comline`
	else
		getmenu
		askmenu
	fi
}

####################################
# Main procedures
####################################
	getterm
	while true
	do
	   getmenu
	   askmenu

	   ##############################################################
	   # Execute option
	   executed="0"

	   ##############################################################
	   # Sspecial case: pause 
	   if [ $commandS = "pause" ]
	   then
	 	askpause ; executed="1"
	   fi

	   ##############################################################
	   # Special case: menu MENU (go down submenu MENU) (max 8 levels)
	   if [ $commandS = "menu" ]
	   then
	 	MENU8=$MENU7;MENU7=$MENU6;MENU6=$MENU5;MENU5=$MENU4;
		MENU4=$MENU3;MENU3=$MENU2;MENU2=$MENU1;MENU1=$MENU0;
	 	MENU0=$commandA".m" ; executed="1"
	   fi

	   ##############################################################
	   # Special case: % (ask command % arguments)
	   if [ $commandS = "%" ]
	   then
	 	askargum ; commandL=$commandA 
	   fi

	   ##############################################################
	   # Special case: comando % (ask arguments for command)
	   if [ -n "$commandA" ]
	   then
	   	if [ $commandA = "%" ]
		then
			askargum ; $commandS $commandA ; executed="1"
		fi
	   fi

	   ##############################################################
	   # If not any previous then execute command line
	   if [ $executed = "0" ]
	   then 
	        ksh -c "$commandL"
	   fi
	done
	exit
