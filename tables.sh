#!/bin/bash
alphaRegex=^[a-zA-Z_[:space:]]+$
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
    echo "Enter new table Name"
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

                if [[ $pKey == "" ]]
                then
                    echo -e "Make PrimaryKey ? "
                    select var in "yes" "no"
                    do
                        case $var in
                        yes ) pKey="PK";
                            col_primary+=$colName
                            col_null[$counter-1]="not_null"
                            break;;
                        
                        no ) echo -e "\nSelect column to be NULL or NOT_NULL"
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
                            break;;
                        
                        *) echo "Wrong Choice" ;;
                        esac
                    done
                fi

                counter=$counter+1
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



function insert_data()
{
            databases_num=`ls $DB_DIR/$dbname/ | wc -l`
            select tables in `ls $DB_DIR/$dbname` "Exit"
            do 
            IFS=';'
            row_data="="         
            if [ $REPLY -gt $databases_num ]
            then 
                break;
            else
                table_name=`ls $DB_DIR/$dbname/ | tail +$REPLY | head -1`
                echo $table_name
                typeset -i col_num
                col_num=`head -1 $DB_DIR/$dbname/$table_name`
                
                table_pk=`grep primary_key $DB_DIR/$dbname/$table_name | cut -d : -f2`
                        
                typeset -i counter
                counter=1

                until [ $counter -gt $col_num ]
                do
                    col_name=`tail +2 $DB_DIR/$dbname/$table_name | head -1 | cut -d : -f $counter` 
                    echo Enter $col_name column value  
                    read -r data 
                    echo $data

                    #  Check data type 
                    data_type=`tail +3 $DB_DIR/$dbname/$table_name | head -1 | cut -d : -f $counter`      
                    null_status=`tail +4 $DB_DIR/$dbname/$table_name | head -1 | cut -d : -f $counter`

                    if [ $data_type = "string" ]
                            then
                                if [ -z $data ]
                                then 
                                    if [ $null_status = "null" ]
                                    then
                                          data="null"

                        elif [ $null_status = "not_null" ]
                        then  
                            echo  NOT_NULL Entry ! try again
                            read -r data
                            while [ -z $data ]
                            do
                                echo  NOT_NULL Entry ! try again
                                read -r data
                            done
                            while ! [[ $data =~ ^[a-zA-Z[:space:]]+$ ]]
                            do
                                    echo  Please Enter valid value ! try again
                                    read -r data
                            done
                        fi
                    else
                        while ! [[ $data =~ ^[a-zA-Z[:space:]]+$ ]]
                            do
                                if [ -z $data ]
                                then 
                                    if [ $null_status = "null" ]
                                        then
                                                data="null"
                                                break;
                                    fi
                                fi
                                echo  Please Enter valid value ! try again
                                read -r data
                            done
                    fi

            
                elif [ $data_type="int" ]
                then
                    if [ -z $data ]
                    then 
                        if [ $null_status = "null" ]
                        then
                            data="null"
    
                        elif [ $null_status = "not_null" ]
                        then  
                            echo  NOT_NULL Entry ! try again
                            read -r data
                            while [ -z $data ]
                            do
                                echo  NOT_NULL Entry ! try again
                                read -r data
                            done
                            while  [[ ! $data =~ ^[0-9]+$  ]]
                            do
                                echo  Please Enter valid value ! try again
                                read -r data
                            done
                        fi
                    else
                        while  [[ ! $data =~ ^[0-9]+$ ]]
                        do
                            if [ -z $data ]
                            then 
                                if [ $null_status = "null" ]
                                then
                                    data="null"
                                    break;
                                fi
                            fi
                            echo $data 
                            echo  Please Enter valid value ! try again
                            read -r data
                        done
                    fi
        
        
                elif [ $data_type="float" ]
                then 
                    if [ -z $data ]
                    then 
                        if [ $null_status = "null" ]
                        then
                            data="null"
        
                        elif [ $null_status = "not_null" ]
                        then  
                            echo  NOT_NULL Entry ! try again
                            read -r data
                            while [-z $data ]
                            do
                                echo  NOT_NULL Entry ! try again
                                read -r data
                            done
                            while ! [[ $data =~ ^[0-9]+([.][0-9]+)?$ ]]
                            do
                                    echo  Please Enter valid value ! try again
                                    read -r data
                            done
                        fi
                    else
                        while ! [[ $data =~ ^[0-9]+([.][0-9]+)?$ ]]
                        do
                            if [ -z $data ]
                            then 
                                if [ $null_status = "null" ]
                                then
                                    data="null"
                                    break;
                                fi
                            fi
                            echo  Please Enter valid value ! try again
                            read -r data
                        done
                    fi
            
                fi
                
                if [ $table_pk=$col_name ]
                then
                    isUnique=`awk  -v COL=$counter -v VALUE=^$data$ 'BEGIN{OFS="__";FS=":"} {if((NR>5) && ($COL ~ VALUE)) print $0;}' $DB_DIR/$dbname/$table_name`
                    echo $isUnique
        
                    until [ -z $isUnique ]
                    do 
                        echo you cannot repeat primary key! try again: 
                        read data
                        echo $dbname
                        isUnique="`awk -v COL=$counter -v VALUE=^$data$ 'BEGIN{OFS="__";FS=":"} {if((NR>5) && ($COL ~ VALUE)) print $0;}' $DB_DIR/$dbname/$table_name`"
                    done
        
                fi
        
                if  [[ $row_data =~ ^[=]$ ]]
                then 
                        row_data=$data
                else
                        row_data=$row_data':'$data
                fi
            
                counter=counter+1
            done
        
            if !  [[ $row_data =~ ^[=]$ ]]
            then
            echo $row_data >> $DB_DIR/$dbname/$table_name 
            echo one record inserted 
            else
                break;
            fi
        fi
    break;
    done    
    unset IFS
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


function delete()
{
        databases_num=`ls $DB_DIR/$dbname/ | wc -l`
        select tables in `ls $DB_DIR/$dbname ` "Exit"
        do 
            if ! [[ $REPLY =~ ^[0-9]+$ ]]
            then
                echo $REPLY is not one of the choices.
                echo Try again 
                break;
            else

            if [ $REPLY -gt $databases_num ]
            then 
                break;
            else
                table_name=`ls $DB_DIR/$dbname/ | tail +$REPLY | head -1`
                echo $table_name

                select option in "Delete All" "With Constrain" Exit
                do 
                    case $REPLY in 
                    1) echo "Are you sure you want to delete ALL ? y/n "
                        read answer
                        if [[ $answer =~ ^[yY] ]]
                        then
                            touch $DB_DIR/$dbname/new_table_name.txt
                            head -5 $DB_DIR/$dbname/$table_name  >> $DB_DIR/$dbname/new_table_name.txt
                            mv $DB_DIR/$dbname/new_table_name.txt $DB_DIR/$dbname/$table_name
                            echo All rows Deleted
                            
                        elif [[ $answer =~ ^[nN] ]]
                        then
                            break;
                        fi
                    ;;
                    
                    2) typeset -i col_num
                        col_num=`head -1 $DB_DIR/$dbname/$table_name`
                        
                        columns=`tail +2 $DB_DIR/$dbname/$table_name | head -1 `
                        IFS=:

                        select field in $columns "Exit"
                        do 
                            if ! [[ $REPLY =~ ^[0-9]+$ ]]
                            then
                                echo $REPLY is not one of the choices.
                                echo Try again 
                                break;
                            else
                                if ! [ $REPLY -gt  $col_num ]
                                then    
                                    echo $field
                                    echo $REPLY
                                    echo "Delete from $table_name where $field = "
                                    IFS=";"
                                    read value
                                    touch $DB_DIR/$dbname/new_table_name.txt
                                    head -5 $DB_DIR/$dbname/$table_name  >> $DB_DIR/$dbname/new_table_name.txt
                                    delete=`awk -F ':' -v FIELD=$REPLY -v DATA=$value '{if( (NR>5) && ($FIELD != DATA) ) print}' $DB_DIR/$dbname/$table_name >> $DB_DIR/$dbname/new_table_name.txt `
                                    mv $DB_DIR/$dbname/new_table_name.txt $DB_DIR/$dbname/$table_name

                                    columns=`tail +2 $DB_DIR/$dbname/$table_name | head -1 `
                                    break;
                                else
                                    break;
                                fi
                            fi
                        done
                        break;
                        ;;
                    
                    3) break;
                    ;;
                    esac
                done
                break;
            fi
            break;
        fi
    done
    unset IFS
}

function update()
{
    databases_num=`ls $DB_DIR/$dbname | wc -l`

    select tables in `ls $DB_DIR/$dbname` "Exit"
    do 
    IFS=";"
    if ! [[ $REPLY =~ ^[0-9]+$ ]]
    then
        echo $REPLY is not one of the choices.
        echo Try again 
        break;
    else

    if [ $REPLY -gt $databases_num ]
    then
        break;
    else
        table_name=`ls $DB_DIR/$dbname/ | tail +$REPLY | head -1`
        echo $table_name

        typeset -i col_num
        col_num=`head -1 $DB_DIR/$dbname/$table_name`
                
        columns=`tail +2 $DB_DIR/$dbname/$table_name | head -1 `
        IFS=:

        echo "Update table $table_name set column:"
        select field in $columns "Exit"
        do 
                if ! [[ $REPLY =~ ^[0-9]+$ ]]
                then
                    echo $REPLY is not one of the choices.
                    echo Try again 
                    break;
                else
                    
                    if  [ $REPLY -gt  $col_num ]
                    then    
                        break;
                    else
                        # echo $REPLY
                        echo "Update table $table_name set $field = "
                        Data_Field=$REPLY
                        read -r Data_value

                        #  Check data type 
                        data_type=`tail +3 $DB_DIR/$dbname/$table_name | head -1 | cut -d : -f $REPLY`      
                        null_status=`tail +4 $DB_DIR/$dbname/$table_name | head -1 | cut -d : -f $REPLY`
                        table_pk=`grep primary_key $DB_DIR/$dbname/$table_name | cut -d : -f2`


                        if [ $data_type = "string" ]
                        then
                            echo $Data_value 
                            if [ -z $Data_value ]
                            then 
                                if [ $null_status = "null" ]
                                then
                                    Data_value="null"

                                elif [ $null_status = "not_null" ]
                                then  
                                    echo  NOT_NULL Entry ! try again
                                    read -r Data_value
                                    while [-z $Data_value ]
                                    do
                                        echo  NOT_NULL Entry ! try again
                                        read -r Data_value
                                    done
                                while ! [[ $data =~ ^[a-zA-Z[:space:]]+$ ]]
                                    do
                                            echo $Data_value 
                                            echo  Please Enter valid value ! try again
                                            read -r Data_value
                                    done
                                fi
                            else
                                while ! [[ $data =~ ^[a-zA-Z[:space:]]+$ ]]
                                    do
                                            if [ -z $Data_value ]
                                            then 
                                                if [ $null_status = "null" ]
                                                    then
                                                        Data_value="null"
                                                        break;
                                                fi
                                            fi
                                            echo $Data_value 
                                            echo  Please Enter valid value ! try again
                                            read -r Data_value
                                    done
                            fi
                            
                        elif [ $data_type = "int" ]
                        then
                            echo $Data_value 
                            if [ -z $Data_value ]
                            then 
                                if [ $null_status = "null" ]
                                then
                                    Data_value="null"

                                elif [ $null_status = "not_null" ]
                                then  
                                    echo  NOT_NULL Entry ! try again
                                    read -r Data_value
                                    while [-z $Data_value ]
                                    do
                                        echo  NOT_NULL Entry ! try again
                                        read -r Data_value
                                    done
                                    while  [[ ! $Data_value =~ ^[0-9]+$  ]]
                                    do
                                            echo $Data_value 
                                            echo  Please Enter valid value ! try again
                                            read -r Data_value
                                    done
                                fi
                            else
                                    while  [[ ! $Data_value =~ ^[0-9]+$ ]]
                                    do
                                            if [ -z $Data_value ]
                                            then 
                                                if [ $null_status = "null" ]
                                                    then
                                                        Data_value="null"
                                                        break;
                                                fi
                                            fi
                                            echo $Data_value 
                                            echo  Please Enter valid value ! try again
                                            read -r Data_value
                                    done
                            fi

                        elif [ $data_type = "float" ]
                        then
                            echo $Data_value 
                            if [ -z $Data_value ]
                            then 
                                if [ $null_status = "null" ]
                                then
                                    Data_value="null"

                                elif [ $null_status = "not_null" ]
                                then  
                                    echo  NOT_NULL Entry ! try again
                                    read -r Data_value
                                    while [-z $Data_value ]
                                    do
                                        echo  NOT_NULL Entry ! try again
                                        read -r Data_value
                                    done
                                    while ! [[ $Data_value =~ ^[0-9]+([.][0-9]+)?$ ]]
                                    do
                                            echo $Data_value 
                                            echo  Please Enter valid value ! try again
                                            read -r Data_value
                                    done
                                fi
                            else
                                while ! [[ $Data_value =~ ^[0-9]+([.][0-9]+)?$ ]]
                                do
                                        if [ -z $Data_value ]
                                        then 
                                            if [ $null_status = "null" ]
                                                then
                                                    Data_value="null"
                                                    break;
                                            fi
                                        fi
                                        echo $Data_value 
                                        echo  Please Enter valid value ! try again
                                        read -r Data_value
                                done
                    fi
                fi
                if [ $table_pk = $field ]
                    then
                        isUnique="`awk  -F ':' -v COL=$REPLY -v VALUE=^$Data_value$ '$COL ~ VALUE {print $0;}' $DB_DIR/$dbname/$table_name`"
                        echo $isUnique

                        until [[ -z $isUnique ]]
                        do 
                            echo you cannot repeat primary key! try again: 
                            read Data_value
                            echo $dbname
                            isUnique="`awk  -F ':' -v COL=$REPLY -v VALUE=^$Data_value$ '$COL ~ VALUE {print $0;}' $DB_DIR/$dbname/$table_name`"
                        done
                fi
            fi


        select option in "Update All" "With Constrain" "Exit"
        do 
            case $REPLY in 
            1) echo "Are you sure you want to Update ALL ? y/n "
                read answer
                if [[ $answer =~ ^[yY] ]]
                then
                    
                    touch $DB_DIR/$dbname/new_table_name.txt
                    head -5 $DB_DIR/$dbname/$table_name  > $DB_DIR/$dbname/new_table_name.txt
                    path=$DB_DIR/$dbname/new_table_name.txt
                    awk -v VALUE_FIELD=$Data_field -v DATA=$Data_value  'BEGIN{FS=OFS=":"} {if(NR>5) { $VALUE_FIELD=DATA; print $0 >> PATH }  }' $DB_DIR/$dbname/$table_name
                    mv $path $DB_DIR/$dbname/$table_name
                    echo All rows Updated
                    break
                fi
            ;;
            2)  echo "Update table $table_name set column $Data_Field where column:"
                select Constraint_field in $columns "Exit"
                do 
                    if ! [[ $REPLY =~ ^[0-9]+$ ]]
                    then
                        echo $REPLY is not one of the choices.
                        echo Try again 
                        break;
                    else

                        if ! [ $REPLY -gt  $col_num ]
                        then    
                            echo $REPLY
                            echo "Update from $table_name Where $Constraint_field = "
                            read Constraint_Value
                            touch $DB_DIR/$dbname/new_table_name.txt
                            path=$DB_DIR/$dbname/new_table_name.txt
                            awk -v PATH=$path -v CONSTRAINT_FIELD=$REPLY  -v VALUE_FIELD=$Data_Field -v DATA=$Data_value -v CONSTRAINT=$Constraint_Value 'BEGIN{FS=OFS=":"}{if( (NR>5) && ($CONSTRAINT_FIELD == CONSTRAINT)) { $VALUE_FIELD=DATA; print $0 > PATH } else {print $0 > PATH} }' $DB_DIR/$dbname/$table_name
                            mv $path $DB_DIR/$dbname/$table_name
                            echo "Rows Updated Successfully"
                            break;
                        else
                            break;
                        fi
                    fi
                done
                break;;

            *) break;;
            
            esac
            break

        done
        break

    # fi
    break

        fi
        done  
    fi
    break;
        fi
    done  
    unset IFS
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
           delete
           break;;
        
        7) echo update table
            update
            break;;

        8) echo You are Disconnected
            source $WORKING_DIR/project.sh
            break;;
        
        *) echo $REPLY is not one of the choices.
            echo Try again
        
        esac
    done
done
