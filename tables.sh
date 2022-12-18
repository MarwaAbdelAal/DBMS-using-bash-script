#!/bin/bash
alphaRegex=^[a-zA-Z_]+$
function dropTable {
    echo -e "Enter table name you want to drop: \c"
    read tName
    if [[ -f $tName ]]
    then
        rm $DB_DIR/$dbname/$tName
        echo "Table $tName Dropped Successfully"
    else
        echo "Table $tName doesn't exist"
    fi
}

function listTables {
    if [ "$(ls -A $DB_DIR/$dbname)" ]
    then 
        ls
    else 
        echo "No Tables Created yet." 
    fi
}

function createTable {
    echo "Enter table Name"
    read newTable
    if ! [[ $newTable =~ $alphaRegex ]]
    then
        echo "Please enter a valid table name"
    else
        check_tableName=`ls | grep ^$newTable$`
        if [ $check_tableName ]
        then
            echo "Table $newTable already exists"
        else
            touch $DB_DIR/$dbname/$newTable
            echo "How many columns you want ?"
            read cols
            until [[ $cols =~ ^[0-9]+$ ]]
            do
                echo "Please enter a valid number of columns"
                read cols
            done

            echo $cols > $newTable
            declare -a col_names[$cols] col_datatypes[$cols] col_null[$cols] col_primary[$cols] #declare arrays for metadata
            pKey=""
            typeset -i counter
            counter=1
            until [ $counter -gt $cols ]
            do
                echo -e "\nEnter column No.$counter name: \c"
                read colName
                until [[ $colName =~ $alphaRegex ]]
                do
                    echo "Please enter a valid column name for col No.$counter"
                    read colName
                done
                col_names[$counter-1]=$colName
                
                echo -e "\nSelect column datatype"
                select choice in string int
                do
                    case $REPLY in
                    1) col_datatypes[$counter-1]="string"
                    break;;
                    
                    2) col_datatypes[$counter-1]="int"
                    break;;

                    *) echo $REPLY is not one of the choices.
                        echo Try again
                esac
                done

                echo -e "\nSelect column to be NULL or NOT_NULL"
                select choice in NULL NOT_NULL
                do
                    case $REPLY in
                    1) col_null[$counter-1]="null"
                    break;;
                    
                    2) col_null[$counter-1]="not_null"
                    break;;

                    *) echo $REPLY is not one of the choices.
                        echo Try again
                esac
                done

                counter=$counter+1

                if [[ $pKey == "" ]]
                then
                    echo -e "Make PrimaryKey ? "
                    select var in "yes" "no"
                    do
                        case $var in
                        yes ) pKey="PK";
                            col_primary+=$colName
                            break;;
                        
                        no )
                        break;;
                        
                        *) echo "Wrong Choice" ;;
                        esac
                    done
                fi
            done

            echo "Table $newTable created successfully"
            wirteMetaData
        fi
    fi
}

function wirteMetaData {
    # Write 2nd row metadata to file (columns names)
    for i in ${!col_names[@]}
    do
        if [[ $i+1 -eq ${#col_names[@]} ]]
        then
            echo "${col_names[$i]}" >> $newTable
        else
            echo -n "${col_names[$i]}:" >> $newTable
        fi
    done

    # Write 3rd row metadata to file (columns datatypes)
    for i in ${!col_datatypes[@]}
    do
        if [[ $i+1 -eq ${#col_datatypes[@]} ]]
        then
            echo "${col_datatypes[$i]}" >> $newTable
        else
            echo -n "${col_datatypes[$i]}:" >> $newTable
        fi
    done

    # Write 4th row metadata to file (columns null)
    for i in ${!col_null[@]}
    do
        if [[ $i+1 -eq ${#col_null[@]} ]]
        then
            echo "${col_null[$i]}" >> $newTable
        else
            echo -n "${col_null[$i]}:" >> $newTable
        fi
    done

    # Write 5th row metadata to file (columns primary_key)
    echo "primary_key:${col_primary[@]}" >> $newTable
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