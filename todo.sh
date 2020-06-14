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
	--text="Menu glowne. Wybierz jedna z opcji:\n" \
	--column="Menu"\
	"Nowa lista" \
	"Wyswietl" \
	"Usun" \
	"Edytuj" \
	"Zakoncz"`
	
if [ $? -eq "0" ]; then
	
	case "$WYBOR" in
		"Nowa lista") nowa_lista;;
		"Wyswietl") wyswietl;;
		"Zakoncz") echo "Koncze program"; exit 1;;
		*) echo "Cos poszlo nie tak";;
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
else
	echo "Podales zla nazwe"
fi

}
#-------------------------------------------------------------
#koniec funkcji-----------------------------------------------
#-------------------------------------------------------------



##############################################################
#poczatek funkcji#############################################
##############################################################
function wyswietl(){

WYBOR=$(zenity --list \
	--title="Todo list" \
	--text="Dostepne listy. Wybierz jedna z list, aby zobaczyc szczegoly" \
	--column="Listy" \
	`ls /home/$UZYTKOWNIK/todo`)

if [ $? -eq "0" ]; then
	WYBOR2=$(zenity --list \
	--title=$WYBOR \
	--text=`cat < /home/$UZYTKOWNIK/todo/$WYBOR` \
	--column="Dostepne opcje" \
	"Dodaj" \
	"Usun" \
	"Powrot do menu" )
	
	if [ $? -eq "0" ]; then
	
		case "$WYBOR2" in
			"Dodaj") menu;;
			"Usun") menu;;
			"Powrot do menu") menu;;
			*) echo "Cos poszlo nie tak";;
		esac
	else
		menu
	fi
else
	menu
	
fi




}
#-------------------------------------------------------------
#koniec funkcji-----------------------------------------------
#-------------------------------------------------------------




menu $@
