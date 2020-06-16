#! /bin/bash
UZYTKOWNIK=$(whoami)
mkdir -p /home/$UZYTKOWNIK/todo
mkdir -p /home/$UZYTKOWNIK/"todo history"


##############################################################
#poczatek funkcji#############################################
##############################################################
function opcje(){
local OPTIND opt i
while getopts ":a::fhs:v" opt; do
	case $opt in
		v) 	echo "Autor: Robert Latoszewski"
			echo "Wersja: 1.0"
			exit 1;;

		h) 	cat << _EOF
			
Todo list to program do tworzenia i edycji list zadan do zrobienia.
Program korzysta z interfejsu graficznego przy pomocy okien dialogowych GTK+ (zenity).
Kluczowa funkcjonalnosc jest dostepna sa przez uruchomienie skryptu bez dodatkowych opcji wywolan.
Dostepne opcje: 

-f			- Wyswietl wszystkie dostepne listy zadan.

-h 			- Wyswietl ten widok pomocy.

-s [lista]		- Wyswietl wszystkie zadania danej listy. 

-v			- Wyswietl informacje o autorze orazo wersji programu. 


_EOF
exit 1;;
		f)	ls /home/$UZYTKOWNIK/todo
			exit 1;;
			
		s)	target=$OPTARG	
			if [ -f /home/$UZYTKOWNIK/todo/$target ]; then	
				cat /home/$UZYTKOWNIK/todo/$target
			else
				echo "Nie ma takiej listy."
			fi
			exit 1;;

		\?)	echo "Blednie wybrana opcja";;
		:)	echo "Podano zly argument"
			exit 1;;
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
		"Usun") usun_liste;;
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

#zenity --entry nie zwraca return code'u -> zawsze jest to 1. entry zwraca standard output
NAZWA=`zenity --entry --title="Nowa lista" --text="Podaj nazwe nowej listy"`

if [[ $NAZWA =~ ^[a-zA-Z]+$ ]];then
	touch /home/$UZYTKOWNIK/todo/$NAZWA.todo
	touch /home/$UZYTKOWNIK/"todo history"/$NAZWA.tdhs
	chmod 700 /home/$UZYTKOWNIK/todo/$NAZWA.todo
	chmod 700 /home/$UZYTKOWNIK/"todo history"/$NAZWA.tdhs
	pokaz_zadania $NAZWA.todo
else
	zenity --info --title="Todo list" --text="Sprobuj bez spacji i znakow specjalnych" --ellipsize 
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


	if [ $? -eq "0" ] && [ -f /home/$UZYTKOWNIK/todo/$WYBOR ] ; then
		pokaz_zadania $WYBOR
	else
		menu
		
	fi

}

#-------------------------------------------------------------
#koniec funkcji-----------------------------------------------
#-------------------------------------------------------------

##############################################################
#poczatek funkcji#############################################
##############################################################
function pokaz_zadania(){
#$1 to nazwa todo listy
	unset list
	list=`cat /home/$UZYTKOWNIK/todo/$1`
	WYBOR2=$(zenity --list \
	--title=$1 \
	--height=300 \
	--text="Twoja lista zadan: \n\n${list[@]}\n\n"\
	--column="Dostepne opcje" \
	"Dodaj" \
	"Usun" \
	"Pokaz historie" \
	"Powrot do menu" \
	"Pozostale listy" )
	
	if [ $? -eq "0" ]; then
	
		case "$WYBOR2" in
			"Dodaj") dodaj_zadanie $1;;
			"Usun") usun_zadanie $1;;
			"Pokaz historie") pokaz_historie $1;;
			"Powrot do menu") menu;;
			"Pozostale listy") wyswietl_listy;;
			*) echo "Cos poszlo nie tak"; menu;;
		esac
	else
		menu
	fi
	

}

#-------------------------------------------------------------
#koniec funkcji-----------------------------------------------
#-------------------------------------------------------------

##############################################################
#poczatek funkcji#############################################
##############################################################

function pokaz_historie(){
	NAZWA="${1//.todo/.tdhs}"
	zenity --text-info \
	--title="Historia zadan wykopnanych z listy $1" \
	--filename=/home/$UZYTKOWNIK/"todo history"/$NAZWA \
	--width=1000 \
	--height=800
	
	pokaz_zadania $1	
}

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
		HISTORY="${1//.todo/.tdhs}" #zamien nazwe_listy.todo na nazwe_listy.tdhs
		echo $WYBOR >> /home/$UZYTKOWNIK/"todo history"/$HISTORY # dodaj usuniete zadanie do historii
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
	echo "`date +'%d/%m/%Y/%T'` $ZADANIE" >> /home/$UZYTKOWNIK/todo/$1
	#$ZADANIE
	pokaz_zadania $1
	shift $(( OPTIND - 1 ))
}


#-------------------------------------------------------------
#koniec funkcji-----------------------------------------------
#-------------------------------------------------------------


##############################################################
#poczatek funkcji#############################################
##############################################################
function usun_liste(){

	WYBOR=$(zenity --list \
		--title="Todo list" \
		--text="Dostepne listy. Wybierz liste, ktora chcialbys usunac: " \
		--column="Listy" \
		`ls /home/$UZYTKOWNIK/todo`)
		
	if [ $? -eq "0" ]; then
		if [ -f /home/$UZYTKOWNIK/todo/$WYBOR ]; then
			WYBOR2=$(zenity --question \
				--title="Todo list" \
				--ellipsize \
				--text="$WYBOR \nCzy na pewno chcesz usunac ta liste?")
			
			if [ $? -eq "0" ]; then
				rm -r /home/$UZYTKOWNIK/todo/$WYBOR
				rm -r /home/$UZYTKOWNIK/"todo history"/"${WYBOR//.todo/.tdhs}"
				menu
			else
				menu
			fi
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
