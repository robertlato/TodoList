#! /bin/bash
UZYTKOWNIK=$(whoami)
mkdir -p /home/$UZYTKOWNIK/todo


##############################################################
#poczatek funkcji#############################################
##############################################################
function opcje(){
local OPTIND opt i
while getopts ":vh" opt; do
	case $opt in
		v) 	echo "Autor: Robert Latoszewski"
			echo "Wersja: 1.0"
			exit 1;;

		h) 	cat << _EOF
			
Program do tworzenia i edycji list zadan do zrobienia.
Dostepne opcje: 

W KROTCE


_EOF
exit 1;;

		\?)	echo "Blednie wybrana opcja";;
	esac
done
shift $(( OPTIND - 1 ))

}
#-------------------------------------------------------------
#koniec funkcji-----------------------------------------------
#-------------------------------------------------------------


##############################################################
#poczatek funkcji#############################################
##############################################################
function menu(){

opcje $@


WYBOR=`zenity --list \
	--title="Todo list" \
	--height=300 \
	--width=400 \
	--text="Menu glowne. Wybierz jedna z opcji:\n" \
	--column="Menu"\
	"Nowa lista" \
	"Wyswietl" \
	"Usun" \
	"Zakoncz"`
	
if [ $? -eq "0" ]; then
	
	case "$WYBOR" in
		"Nowa lista") nowa_lista;;
		"Wyswietl") wyswietl_listy;;
		"Zakoncz") echo "Koncze program"; exit 1;;
		*) echo "Cos poszlo nie tak"; menu;;
	esac
else
	echo "Koncze program"
fi
		
}
#-------------------------------------------------------------
#koniec funkcji-----------------------------------------------
#-------------------------------------------------------------



##############################################################
#poczatek funkcji#############################################
##############################################################
function nowa_lista(){

NAZWA=`zenity --entry --title="Nowa lista" --text="Podaj nazwe nowej listy"`

if [[ $NAZWA =~ ^[a-zA-Z]+$ ]];then
	touch /home/$UZYTKOWNIK/todo/$NAZWA.todo
	chmod 700 /home/$UZYTKOWNIK/todo/$NAZWA.todo
	pokaz_zadania $NAZWA.todo
elif [ $? -eq "1" ]; then #uzytkownik nie wybral zadnej opcji, ale wybral przycisk "ok" zamiast "cancel"
	menu
else
	echo "Podales zla nazwe"
	menu
fi

}
#-------------------------------------------------------------
#koniec funkcji-----------------------------------------------
#-------------------------------------------------------------



##############################################################
#poczatek funkcji#############################################
##############################################################
function wyswietl_listy(){
	#wybor = nazwa listy
	WYBOR=$(zenity --list \
		--title="Todo list" \
		--text="Dostepne listy. Wybierz jedna z list, aby zobaczyc szczegoly" \
		--column="Listy" \
		`ls /home/$UZYTKOWNIK/todo`)

	if [ $? -eq "0" ]; then
		pokaz_zadania $WYBOR
	else
		menu
		
	fi

}
#--text=`cat < /home/$UZYTKOWNIK/todo/$WYBOR` \
#-------------------------------------------------------------
#koniec funkcji-----------------------------------------------
#-------------------------------------------------------------

##############################################################
#poczatek funkcji#############################################
##############################################################
function pokaz_zadania(){
	unset list
	list=`cat /home/$UZYTKOWNIK/todo/$1`
	#while read -r line
	#do
	#	list+=("$line")
	#done < /home/$UZYTKOWNIK/todo/$WYBOR
		WYBOR2=$(zenity --list \
		--title=$1 \
		--height=300 \
		--text="Twoja lista zadan: \n\n${list[@]}\n\n"\
		--column="Dostepne opcje" \
		"Dodaj" \
		"Usun" \
		"Powrot do menu" \
		"Pozostale listy" )
		
		if [ $? -eq "0" ]; then
		
			case "$WYBOR2" in
				"Dodaj") dodaj_zadanie $1;;
				"Usun") usun_zadanie $1;;
				"Powrot do menu") menu;;
				"Pozostale listy") wyswietl_listy;;
				*) echo "Cos poszlo nie tak"; menu;;
			esac
		else
			menu
		fi
		

}

#--text=`cat < /home/$UZYTKOWNIK/todo/$WYBOR` \
#-------------------------------------------------------------
#koniec funkcji-----------------------------------------------
#-------------------------------------------------------------

##############################################################
#poczatek funkcji#############################################
##############################################################
function usun_zadanie(){
	unset list
	while read -r line
	do
		list+=("$line")
	done < /home/$UZYTKOWNIK/todo/$1

	WYBOR=$(zenity --list \
	--title=$1 \
	--height=300 \
	--width=400 \
	--text="Wybierz, ktore zadania chcesz usunac: " \
	--column="Twoja lista zadan" \
	"${list[@]}")
	
	if [ $? -eq "0" ]; then
		sed -i "\?^$WYBOR?d" /home/$UZYTKOWNIK/todo/$1
	fi
	
	
	pokaz_zadania $1

}


#-------------------------------------------------------------
#koniec funkcji-----------------------------------------------
#-------------------------------------------------------------


##############################################################
#poczatek funkcji#############################################
##############################################################
function dodaj_zadanie(){
	ZADANIE=`zenity --entry --title="$1 - nowe zadanie" --text="Wprowadz zadanie"`
	echo "`date +'%d/%m/%Y/%R'` $ZADANIE" >> /home/$UZYTKOWNIK/todo/$1
	#$ZADANIE
	pokaz_zadania $1
	shift $(( OPTIND - 1 ))
}


#-------------------------------------------------------------
#koniec funkcji-----------------------------------------------
#-------------------------------------------------------------


menu $@
