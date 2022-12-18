#!/usr/bin/bash 

WORKING_DIR=~/bash_project
DB_DIR=$WORKING_DIR/DBM

# creating DBM if doesn't exist
mkdir -p $DB_DIR

while true
do
	select choice in "Create_Database" "List_Databases" "Connect_Database" "Drop_Database" "Exit"
    	do 
		case $REPLY in 
	
		1) echo enter database name 
			read dbname
			if ! [[ $dbname =~ ^[a-zA-Z_0-9]+$ ]]
			then
				echo Avoid special characters
				break;
			else
            	check_dbname=`ls $DB_DIR/ | grep ^$dbdbname$`
            	echo $check_dbname
                
				if [ $check_dbname ]
				then
					echo database $dbname exists
		            break;
                else
                    mkdir $DB_DIR/$dbname
					echo $dbname database is created
		            break;	
                fi 
		   fi
	    ;;
          	
	    2) ls -F $DB_DIR | grep "/"
		   break;
            ;;
		  
	    3) echo Enter database name to connect
		   	read dbname
            check_dbname=`ls $DB_DIR/ | grep ^$dbname$`
		   	if [ -z $check_dbname ]
            then
                echo Invalid database name
				break;
		   	else	   
		        cd $DB_DIR/$dbname
		        echo you are connected to the $dbname database
				source $WORKING_DIR/tables.sh
		   	fi
		;;

	    4) echo Enter database name to drop 
		   	read dbname
		   	check_dbname=`ls $DB_DIR/ | grep ^$dbname$`
            if [ -z $check_dbname ]
            then
                echo database $dbname doesnot not exist
				break;
    	    else
		        rm -r $DB_DIR/$dbname
		        echo  $dbname database is dropped 
				break;
		   	fi
		;;
		 
	    5) exit
		;;	

		*) echo $REPLY is not one of the choices.
            echo Try again
			break;
		;;
    
		esac 
 	done 
done
