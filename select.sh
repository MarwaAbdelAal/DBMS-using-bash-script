function select()
{
select tables in `ls $DB_DIR/$dbname` "Exit"
do 

  if [ $REPLY -gt $databases_num ]
  then 
       exit

  elif [ $REPLY -lt $databases_num ] || [ $REPLY -eq $databases_num ]
  then
      table_name=`ls $DB_DIR/$dbname/ | head -$REPLY`
      echo $table_name

      typeset -i col_num
      col_num=`head -1 $DB_DIR/$dbname/$table_name`
      
      columns=`tail +2 $DB_DIR/$dbname/$table_name | head -1 `
      IFS=:
      select field in $columns Exit
      do 
            if ! [ $REPLY -gt  $col_num ]
            then    
                echo $field
                echo $REPLY
                echo Delete from $table_name where $field = 
                read value
                selected_rows=`awk -F ':' -v FIELD=$REPLY -v DATA=$value '{if($FIELD == DATA) print}' $DB_DIR/$dbname/$table_name `
                echo $selected_rows
            else
                break;
            fi
      done
    fi
done
}


