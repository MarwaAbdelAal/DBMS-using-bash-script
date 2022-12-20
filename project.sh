#!/usr/bin/bash 

WORKING_DIR=~/Bash_Project
DB_DIR=$WORKING_DIR/DBM

# creating DBM if doesn't exist
mkdir -p $DB_DIR
while true
do
	echo
	select choice in "Create_Database" "List_Databases" "Connect_Database" "Drop_Database" "Exit"
    	do 
		case $REPLY in 
	
		1)  echo "Enter new database name:"
			read dbname
			if ! [[ $dbname =~ ^[a-zA-Z_][a-zA-Z_0-9]+$ ]]
			then
				echo "Avoid using special characters"
			else
				if [ -d $DB_DIR/$dbname ]
				then
					echo "database $dbname already exists."
                else
                    mkdir $DB_DIR/$dbname
					echo "$dbname database is created."
                fi 
			fi
		    break;;

	    2) ls -F $DB_DIR | grep "/" | cut -f1 -d'/'
		   break;
            ;;
		  
		3)  echo "This is all databases: "
			ls -F $DB_DIR | grep "/" | cut -f1 -d'/'
			echo "Enter database name to connect"
			read dbname
            check_dbname=`ls $DB_DIR/ | grep ^$dbname$`
		   	if [ -z $check_dbname ]
            then
                echo "database $dbname doesnot exist"
				break;
		   	else	   
		        cd $DB_DIR/$dbname
		        echo "you are connected to the $dbname database"
				source $WORKING_DIR/tables.sh
		   	fi
		;;

	    4)	echo "This is all databases: " 
			ls -F $DB_DIR | grep "/" | cut -f1 -d'/'
			echo "Enter database name to drop" 
		   	read dbname
		   	check_dbname=`ls $DB_DIR/ | grep ^$dbname$`
            if [ -z $check_dbname ]
            then
                echo "database $dbname doesnot exist"
				break;
    	    else
		        rm -r $DB_DIR/$dbname
		        echo  "$dbname database is dropped"
				break;
		   	fi
		;;
		 
	    5)  exit
		;;	

		*)  echo $REPLY is not one of the choices.
            echo Try again
			break;
		;;
    
		esac 
 	done 
done
