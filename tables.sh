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
            writeMetaData
        fi
    fi
}

function writeMetaData {
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


function insert_data ()
{
            databases_num=`ls $DB_DIR/$1 | wc -l`

            select tables in `ls $DB_DIR/$1` "Exit"
            do 

            if [ $REPLY -gt $databases_num ]
            then 
                exit

            else [ $REPLY -lt $databases_num ] || [ $REPLY -eq $databases_num ]

                # echo $REPLY
                table_name=`ls $DB_DIR/$dbname/ | head -$REPLY`
                echo $table_name

                typeset -i col_num
                col_num=`head -1 $DB_DIR/$dbname/$table_name`
                
                table_pk=`grep primary_key $DB_DIR/$dbname/$table_name | cut -d : -f2`
                echo $table_pk

                # echo $col_num
                        
                typeset -i counter
                counter=1

                until [ $counter -gt $col_num ]
                do
                    col_name=`tail +2 $DB_DIR/$dbname/$table_name | head -1 | cut -d : -f $counter` 
                    echo Enter $col_name column value           
                    read data 
                    
                    #  Check data type 
                    data_type=`tail +3 $DB_DIR/$dbname/$table_name | head -1 | cut -d : -f $counter`      
                    null_status=`tail +4 $DB_DIR/$dbname/$table_name | head -1 | cut -d : -f $counter`

                    if [ $data_type = "string" ]
                    then
                        if [ $null_status = "null" ]
                        then
                            if [ -z $data ]
                            then 
                                data="null"
                            fi
                        elif [ $null_status = "not_null" ]
                        then
                            while ! [[ $data =~ ^[a-zA-Z]+$ ]] || [[ $data == ^[\]$ ]]
                            do  
                                    echo Please Enter valid value !  try again 
                                    read data
                                    
                            done 
                        fi
                        
                        # echo $data

                    elif [ $data_type="int" ]
                    then 
                        if [ $null_status = "null" ]
                        then
                            if [ -z $data ]
                            then 
                                data="null"
                            fi
                        elif [ $null_status = "not_null" ]
                        then
                        while ! [[ $data =~ ^[0-9]+$ ]]
                        do
                            echo  Please Enter valid value ! try again
                            read data
                        done
                        fi

                        # echo $data

                    elif [ $data_type="float" ]
                    then 
                        if [ $null_status = "null" ]
                        then
                            if [ -z $data ]
                            then 
                                data="null"
                            fi
                        elif [ $null_status = "not_null" ]
                        then
                        while ! [[ $data =~ ^[0-9]+([.][0-9]+)?$ ]]
                        do   
                            echo  Please Enter valid value ! try again
                            read data
                        done
                        fi
                        # echo $data
                
                    fi
                    
                    if [[ $table_pk == $col_name ]]
                    then
                        echo $col_name
                        echo $table_pk
                        isUnique="`awk  -F ':' -v COL=$counter -v VALUE=^$data$ '$COL ~ VALUE {print $0;}' $DB_DIR/$dbname/$table_name`"
                        echo $isUnique

                        until [[ -z $isUnique ]]
                        do 
                            echo you cannot repeat primary key! try again: 
                            read data
                            isUnique="`awk  -F ':' -v COL=$counter -v VALUE=^$data$ '$COL ~ VALUE {print $0;}' $DB_DIR/$1/$table_name`"
                        done

                    fi

                    if [ -z $row_data ]
                    then 
                            row_data=$data
                    else
                            row_data=$row_data':'$data
                    fi

                counter=counter+1
                done
                # echo $row_data 
                echo $row_data >> $DB_DIR/$dbname/$table_name 
                echo one record inserted 
            fi
        exit
    done     
}

function selectFromTable {
    echo "This is all tables"
    ls $DB_DIR/$dbname
    echo -e "\nEnter table Name: \c"
    read selectTable
    if ! [[ $selectTable =~ $alphaRegex ]]
    then
        echo "Please enter a valid table name"
    else
        check_tableName=`ls | grep ^$selectTable$`
        if [ $check_tableName ]
        then
            colNames=`sed -n '2p' $DB_DIR/$dbname/$selectTable`
            typeset -i col_num
            col_num=`head -1 $DB_DIR/$dbname/$selectTable`
            select choice in "select all" "select by column" "exit"
            do
                case $REPLY in
                1) echo -e "\nselect * from $selectTable"
                    read -r -p "Include CONSTRAINT 'where clause'? [y/N] " response
                    IFS=:
                    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
                    then
                        echo "select column to filter by:"
                        select field in $colNames Exit
                        do
                            if [[ $REPLY =~ ^[0-9]+$ ]]
                            then
                                if ! [ $REPLY -gt  $col_num ]
                                then
                                    read -p "select * from $selectTable where $field = " value

                                    awk -F: -v FIELD=$REPLY -v DATA=$value '{if($FIELD == DATA) print}' $DB_DIR/$dbname/$selectTable
                                    break
                                else
                                    echo "Please select one of the choices"
                                    break
                                fi
                            else
                                echo "Please select one of the choices"
                            fi
                        done
                    else
                        echo $colNames
                        tail +6 $DB_DIR/$dbname/$selectTable
                        echo -e "\n"
                    fi                    
                    break;;

                # select name from table (by column)
                2) echo "How many columns you want ?"
                    read num_of_cols
                    until [[ $num_of_cols =~ ^[0-9]+$ ]] && [ $num_of_cols -le $col_num ]
                    do
                        echo "Please enter a valid number of columns"
                        echo -e "The table has $col_num columns \n$colNames"
                        read -p "#columns = " num_of_cols
                    done
                    
                    typeset -i counter
                    counter=1
                    fields=""
                    until [ $counter -gt $num_of_cols ]
                    do
                        IFS=:
                        echo -e "\nSelect column No.$counter:"
                        select field in $colNames Exit
                        do
                            if ! [ $REPLY -gt  $col_num ]
                            then
                                fields+="$field,"
                                temp+="$REPLY,"
                                break
                            else
                                echo "Please select one of the choices"
                                break
                            fi
                        done
                        counter=$counter+1
                    done

                    read -r -p "Include CONSTRAINT 'where clause'? [y/N] " response
                    IFS=:
                    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
                    then
                        echo "select column to filter by:"
                        select entry in $colNames Exit
                        do
                            if [[ $REPLY =~ ^[0-9]+$ ]]
                            then
                                if ! [ $REPLY -gt  $col_num ]
                                then
                                    read -p "select ${fields:0:-1} from $selectTable where $entry = " value

                                    awk -F: -v FIELD=$REPLY -v DATA=$value '{if($FIELD == DATA) print}' $DB_DIR/$dbname/$selectTable | cut -f ${temp:0:-1} -d:
                                    break
                                else
                                    echo "Please select one of the choices"
                                    break
                                fi
                            else
                                echo "Please select one of the choices"
                            fi
                        done
                    
                    else
                        echo -e "\nselect ${fields:0:-1} from $selectTable"
                        cut -f ${temp:0:-1} -d: $DB_DIR/$dbname/$selectTable | sed -n 2p
                        cut -f ${temp:0:-1} -d: $DB_DIR/$dbname/$selectTable | tail +6
                        echo -e "\n"
                    fi     

                    break;;
                
                3) break;;
                
                *) echo $REPLY is not one of the choices.
                    echo Try again
                esac
            done
        else
            echo "Table $selectTable doesn't exist"
        fi
    fi
}

while true
do
    select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Disconnect"
    do
        case $REPLY in
        1) createTable
            break;;
        
        2) listTables
            break;;
        
        3) dropTable 
            break;;
        
        4) insert_data
            break;;
        
        5) selectFromTable
            break;;
        
        6) echo Delete from table
            break;;
        
        7) echo update table
            break;;

        8) echo You are Disconnected
            source $WORKING_DIR/project.sh
            break;;
        
        *) echo $REPLY is not one of the choices.
            echo Try again
        
        esac
    done
done