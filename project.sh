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
			read name
			if ! [[ $name =~ ^[a-zA-Z_0-9]+$ ]]
			then
				echo Avoid special characters
				break;
			else
            	check_name=`ls $DB_DIR/ | grep ^$name$`
            	echo $check_name
                
				if [ $check_name ]
				then
					echo database $name exists
		            break;
                else
                    mkdir $DB_DIR/$name
					echo $name database is created
		            break;	
                fi 
		   fi
	    ;;
          	
	    2) ls -F $DB_DIR | grep "/"
		   break;
            ;;
		  
	    3) echo Enter database name to connect
		   	read name
            check_name=`ls $DB_DIR/ | grep ^$name$`
		   	if [ -z $check_name ]
            then
                echo Invalid database name
				break;
		   	else	   
		        cd $DB_DIR/$name
		        echo you are connected to the $name database
				source $WORKING_DIR/tables.sh
		   	fi
		;;

	    4) echo Enter database name to drop 
		   	read name
		   	check_name=`ls $DB_DIR/ | grep ^$name$`
            if [ -z $check_name ]
            then
                echo database $name doesnot not exist
				break;
    	    else
		        rm -r $DB_DIR/$name
		        echo  $name database is dropped 
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
