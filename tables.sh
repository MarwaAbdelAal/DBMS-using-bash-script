#!/bin/bash
function dropTable {
    echo -e "Enter table name you want to drop: \c"
    read tName
    if [[ -f $tName ]]
    then
        rm $tName
        echo "Table $tName Dropped Successfully"
    else
        echo "Table $tName doesn't exist"
    fi
}

function listTables {
    if [ -z $DB_DIR/$name ]
    then 
        ls
    else 
        echo "No Tables Created yet." 
    fi
}

function createTable {
}

while true
do
    select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Disconnect"
    do
        case $REPLY in
        1) createTable
            break;
        ;;
        
        2) listTables
            break;
        ;;
        
        3) dropTable 
            break;
        ;;
        
        4) echo Insert into table
        ;;
        
        5) echo Select from table
        ;;
        
        6) echo Delete from table
        ;;
        
        7) echo update table
        ;;

        8) echo You are Disconnected
        source $WORKING_DIR/project.sh
        ;;
        
        *) echo $REPLY is not one of the choices.
        echo Try again
        esac
    done
done