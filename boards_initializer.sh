#!/bin/bash
player1_board_file="player1_board_file.txt"
player2_board_file="player2_board_file.txt"
cells_to_shoot_on_player2_board_file="cells_to_shoot_on_player2_board_file.txt"
cells_to_shoot_on_player1_board_file="cells_to_shoot_on_player1_board_file.txt"
tmp1="tmp1.txt"
tmp2="tmp2.txt"

touch "$player1_board_file"
touch "$player2_board_file"
touch "$tmp1"
touch "$tmp2"
touch "$cells_to_shoot_on_player2_board_file"
touch "$cells_to_shoot_on_player1_board_file"

from=0;
to=3;
countOne=1;
countTwo=1;
countThree=2;

for ((i=$from; i< $((to+1)); i++)); do
    for ((j=$from; j< $((to+1)); j++)); do
        echo "$i $j 0" >> $player1_board_file
        echo "$i $j" >> $tmp1
    done
done

shuf $tmp1 --output=$cells_to_shoot_on_player1_board_file
rm $tmp1


i=0;

while (( i < countThree )); do
    random_x=$(( RANDOM % $to + $from ))
    random_y=$(( RANDOM % $to + $from ))
    first_x=$random_x
    first_y=$random_y
    chosen_cell=$(grep "^$random_x $random_y [0-9]$" $player1_board_file)
    status_of_chosen_cell=$(echo $chosen_cell | awk '{print $3}')

    if (( $status_of_chosen_cell == 1 )); then
        continue;
    else 
        sed -i "s/^$random_x $random_y [0-9]$/$random_x $random_y 1/" $player1_board_file

        x_plus=$(( random_x+1 )) 
        y_plus=$(( random_y+1 ))
        x_minus=$(( random_x-1 ))
        y_minus=$(( random_y-1 ))
        

        if (( "$x_plus" <= "$to" && "$x_plus" >= "$from" )); then

            x_plus_chosen_cell=$(grep "^$x_plus $random_y [0-9]$" $player1_board_file)
            status_of_x_plus_chosen_cell=$(echo $x_plus_chosen_cell | awk '{print $3}')

            if (( $status_of_x_plus_chosen_cell == 0 )); then
                ((random_x++))
            fi

        elif (( "$x_minus" <= "$to" && "$x_minus" >= "$from" )); then
        
            x_minus_chosen_cell=$(grep "^$x_minus $random_y [0-9]$" $player1_board_file)
            status_of_x_minus_chosen_cell=$(echo $x_minus_chosen_cell | awk '{print $3}')

            if (( $status_of_x_minus_chosen_cell == 0 )); then
                ((random_x--))
            fi

        elif (( "$y_minus" <= "$to" && "$y_minus" >= "$from" )); then

            y_minus_chosen_cell=$(grep "^$random_x $y_minus [0-9]$" $player1_board_file)
            status_of_y_minus_chosen_cell=$(echo $y_minus_chosen_cell | awk '{print $3}')
            if (( $status_of_y_minus_chosen_cell == 0 )); then
                ((random_y--))
            fi

        elif (( "$y_plus" <= "$to" && "$y_plus" >= "$from" )); then

            y_plus_chosen_cell=$(grep "^$random_x $y_plus [0-9]$" $player1_board_file)
            status_of_y_plus_chosen_cell=$(echo $y_plus_chosen_cell | awk '{print $3}')

            if (( $status_of_y_plus_chosen_cell == 0 )); then
                ((random_y++))
            fi
        else
            continue
        fi


    
        second_x=$random_x
        second_y=$random_y

        sed -i "s/^$random_x $random_y [0-9]$/$random_x $random_y 1/" $player1_board_file

        tmp_x=$((first_x-second_x))
        tmp_y=$((first_y-second_y))

        if (( $tmp_y != 0 )); then
            third_y_option1=$(( first_y + tmp_y ))
            third_y_option2=$(( second_y - tmp_y ))

            if (( $third_y_option1 >= $from && $third_y_option1 <= $to )); then

                third_y_option1_chosen_cell=$(grep "^$first_x $third_y_option1 [0-9]$" $player1_board_file)
                third_y_option1_status_of_chosen_cell=$(echo $third_y_option1_chosen_cell | awk '{print $3}')

                if (( $third_y_option1_status_of_chosen_cell == 0 )); then 
                    random_y=$third_y_option1
                fi

            elif (( $third_y_option2 >= $from && $third_y_option2 <= $to  )); then

                third_y_option2_chosen_cell=$(grep "^$first_x $third_y_option2 [0-9]$" $player1_board_file)
                third_y_option2_status_of_chosen_cell=$(echo $third_y_option2_chosen_cell | awk '{print $3}')

                if (( $third_y_option2_status_of_chosen_cell == 0 )); then 
                    random_y=$third_y_option2
                fi
            else 
                continue
            fi

        elif (( $tmp_x != 0 )); then
            third_x_option1=$(( first_x + tmp_x ))
            third_x_option2=$(( second_x - tmp_x ))

            if (( $third_x_option1 >= $from && $third_x_option1 <= $to )); then

                third_x_option1_chosen_cell=$(grep "^$third_x_option1 $first_y [0-9]$" $player1_board_file)
                third_x_option1_status_of_chosen_cell=$(echo $third_x_option1_chosen_cell | awk '{print $3}')

                if (( $third_x_option1_status_of_chosen_cell == 0 )); then 
                    random_x=$third_x_option1
                fi

            elif (( $third_x_option2 >= $from && $third_x_option2 <= $to  )); then

                third_x_option2_chosen_cell=$(grep "^$third_x_option2 $first_y [0-9]$" $player1_board_file)
                third_x_option2_status_of_chosen_cell=$(echo $third_x_option2_chosen_cell | awk '{print $3}')

                if (( $third_x_option2_status_of_chosen_cell == 0 )); then 
                    random_x=$third_x_option2
                fi
            else 
                continue
            fi
        fi
        echo $"Three ship. First: {$first_x}, {$first_y}. Second: {$second_x}, {$second_y}. Third: {$random_x}, {$random_y}."
        sed -i "s/^$random_x $random_y [0-9]$/$random_x $random_y 1/" $player1_board_file
        ((i++))
    fi
done


i=0;

while (( i < countTwo )); do
    random_x=$(( RANDOM % $to + $from ))
    random_y=$(( RANDOM % $to + $from ))
    first_x=$random_x
    first_y=$random_y
    chosen_cell=$(grep "^$random_x $random_y [0-9]$" $player1_board_file)
    status_of_chosen_cell=$(echo $chosen_cell | awk '{print $3}')

    if (( $status_of_chosen_cell == 1 )); then
        continue;
    else 
        sed -i "s/^$random_x $random_y [0-9]$/$random_x $random_y 1/" $player1_board_file

        x_plus=$(( random_x+1 )) 
        y_plus=$(( random_y+1 ))
        x_minus=$(( random_x-1 ))
        y_minus=$(( random_y-1 ))
        
        if (( "$x_plus" <= "$to" && "$x_plus" >= "$from" )); then

            x_plus_chosen_cell=$(grep "^$x_plus $random_y [0-9]$" $player1_board_file)
            status_of_x_plus_chosen_cell=$(echo $x_plus_chosen_cell | awk '{print $3}')

            if (( $status_of_x_plus_chosen_cell == 0 )); then
                ((random_x++))
            fi

        elif (( "$x_minus" <= "$to" && "$x_minus" >= "$from" )); then
        
            x_minus_chosen_cell=$(grep "^$x_minus $random_y [0-9]$" $player1_board_file)
            status_of_x_minus_chosen_cell=$(echo $x_minus_chosen_cell | awk '{print $3}')

            if (( $status_of_x_minus_chosen_cell == 0 )); then
                ((random_x--))
            fi

        elif (( "$y_minus" <= "$to" && "$y_minus" >= "$from" )); then

            y_minus_chosen_cell=$(grep "^$random_x $y_minus [0-9]$" $player1_board_file)
            status_of_y_minus_chosen_cell=$(echo $y_minus_chosen_cell | awk '{print $3}')
            if (( $status_of_y_minus_chosen_cell == 0 )); then
                ((random_y--))
            fi

        elif (( "$y_plus" <= "$to" && "$y_plus" >= "$from" )); then

            y_plus_chosen_cell=$(grep "^$random_x $y_plus [0-9]$" $player1_board_file)
            status_of_y_plus_chosen_cell=$(echo $y_plus_chosen_cell | awk '{print $3}')

            if (( $status_of_y_plus_chosen_cell == 0 )); then
                ((random_y++))
            fi
        else
            continue
        fi

    
        sed -i "s/^$random_x $random_y [0-9]$/$random_x $random_y 1/" $player1_board_file
        ((i++))
    fi
     echo $"Two ship first {$first_x}, {$first_y} second {$random_x}, {$random_y}"
done


i=0;

while (( i < countOne )); do
    random_x=$(( RANDOM % $to + $from ))
    random_y=$(( RANDOM % $to + $from ))
    chosen_cell=$(grep "^$random_x $random_y [0-9]$" $player1_board_file)
    status_of_chosen_cell=$(echo $chosen_cell | awk '{print $3}')

    if (( $status_of_chosen_cell == 1 )); then
        continue;
    else 
        sed -i "s/^$random_x $random_y [0-9]$/$random_x $random_y 1/" $player1_board_file
        ((i++))
    fi
    echo "One ship. {$random_x}, {$random_y}"
done

for ((i=$from; i< $((to+1)); i++)); do
    for ((j=$from; j< $((to+1)); j++)); do
        echo "$i $j 0" >> $player2_board_file
        echo "$i $j" >> $tmp2
        #player1_board[$i,$j]=0
    done
done

shuf $tmp2 --output=$cells_to_shoot_on_player2_board_file
rm $tmp2


i=0;

while (( i < countThree )); do
    random_x=$(( RANDOM % $to + $from ))
    random_y=$(( RANDOM % $to + $from ))
    first_x=$random_x
    first_y=$random_y
    chosen_cell=$(grep "^$random_x $random_y [0-9]$" $player2_board_file)
    status_of_chosen_cell=$(echo $chosen_cell | awk '{print $3}')

    if (( $status_of_chosen_cell == 1 )); then
        continue;
    else 
        sed -i "s/^$random_x $random_y [0-9]$/$random_x $random_y 1/" $player2_board_file

        x_plus=$(( random_x+1 )) 
        y_plus=$(( random_y+1 ))
        x_minus=$(( random_x-1 ))
        y_minus=$(( random_y-1 ))
        
        if (( "$x_plus" <= "$to" && "$x_plus" >= "$from" )); then

            x_plus_chosen_cell=$(grep "^$x_plus $random_y [0-9]$" $player2_board_file)
            status_of_x_plus_chosen_cell=$(echo $x_plus_chosen_cell | awk '{print $3}')

            if (( $status_of_x_plus_chosen_cell == 0 )); then
                ((random_x++))
            fi

        elif (( "$x_minus" <= "$to" && "$x_minus" >= "$from" )); then
        
            x_minus_chosen_cell=$(grep "^$x_minus $random_y [0-9]$" $player2_board_file)
            status_of_x_minus_chosen_cell=$(echo $x_minus_chosen_cell | awk '{print $3}')

            if (( $status_of_x_minus_chosen_cell == 0 )); then
                ((random_x--))
            fi

        elif (( "$y_minus" <= "$to" && "$y_minus" >= "$from" )); then

            y_minus_chosen_cell=$(grep "^$random_x $y_minus [0-9]$" $player2_board_file)
            status_of_y_minus_chosen_cell=$(echo $y_minus_chosen_cell | awk '{print $3}')
            if (( $status_of_y_minus_chosen_cell == 0 )); then
                ((random_y--))
            fi

        elif (( "$y_plus" <= "$to" && "$y_plus" >= "$from" )); then

            y_plus_chosen_cell=$(grep "^$random_x $y_plus [0-9]$" $player2_board_file)
            status_of_y_plus_chosen_cell=$(echo $y_plus_chosen_cell | awk '{print $3}')

            if (( $status_of_y_plus_chosen_cell == 0 )); then
                ((random_y++))
            fi
        else
            continue
        fi

    
        second_x=$random_x
        second_y=$random_y
        sed -i "s/^$random_x $random_y [0-9]$/$random_x $random_y 1/" $player2_board_file

        tmp_x=$((first_x-second_x))
        tmp_y=$((first_y-second_y))

        if (( $tmp_y != 0 )); then
            third_y_option1=$(( first_y + tmp_y ))
            third_y_option2=$(( second_y - tmp_y ))

            if (( $third_y_option1 >= $from && $third_y_option1 <= $to )); then

                third_y_option1_chosen_cell=$(grep "^$first_x $third_y_option1 [0-9]$" $player2_board_file)
                third_y_option1_status_of_chosen_cell=$(echo $third_y_option1_chosen_cell | awk '{print $3}')

                if (( $third_y_option1_status_of_chosen_cell == 0 )); then 
                    random_y=$third_y_option1
                fi

            elif (( $third_y_option2 >= $from && $third_y_option2 <= $to  )); then

                third_y_option2_chosen_cell=$(grep "^$first_x $third_y_option2 [0-9]$" $player2_board_file)
                third_y_option2_status_of_chosen_cell=$(echo $third_y_option2_chosen_cell | awk '{print $3}')

                if (( $third_y_option2_status_of_chosen_cell == 0 )); then 
                    random_y=$third_y_option2
                fi
            else 
                continue
            fi

        elif (( $tmp_x != 0 )); then
            third_x_option1=$(( first_x + tmp_x ))
            third_x_option2=$(( second_x - tmp_x ))

            if (( $third_x_option1 >= $from && $third_x_option1 <= $to )); then

                third_x_option1_chosen_cell=$(grep "^$third_x_option1 $first_y [0-9]$" $player2_board_file)
                third_x_option1_status_of_chosen_cell=$(echo $third_x_option1_chosen_cell | awk '{print $3}')

                if (( $third_x_option1_status_of_chosen_cell == 0 )); then 
                    random_x=$third_x_option1
                fi

            elif (( $third_x_option2 >= $from && $third_x_option2 <= $to  )); then

                third_x_option2_chosen_cell=$(grep "^$third_x_option2 $first_y [0-9]$" $player2_board_file)
                third_x_option2_status_of_chosen_cell=$(echo $third_x_option2_chosen_cell | awk '{print $3}')

                if (( $third_x_option2_status_of_chosen_cell == 0 )); then 
                    random_x=$third_x_option2
                fi
            else 
                continue
            fi
        fi
        echo $"Three ship. First: {$first_x}, {$first_y}. Second: {$second_x}, {$second_y}. Third: {$random_x}, {$random_y}."
        sed -i "s/^$random_x $random_y [0-9]$/$random_x $random_y 1/" $player2_board_file
        ((i++))
    fi
done


i=0;

while (( i < countTwo )); do
    random_x=$(( RANDOM % $to + $from ))
    random_y=$(( RANDOM % $to + $from ))
    first_x=$random_x
    first_y=$random_y
    chosen_cell=$(grep "^$random_x $random_y [0-9]$" $player2_board_file)
    status_of_chosen_cell=$(echo $chosen_cell | awk '{print $3}')

    if (( $status_of_chosen_cell == 1 )); then
        continue;
    else 
        sed -i "s/^$random_x $random_y [0-9]$/$random_x $random_y 1/" $player2_board_file

        x_plus=$(( random_x+1 )) 
        y_plus=$(( random_y+1 ))
        x_minus=$(( random_x-1 ))
        y_minus=$(( random_y-1 ))
        
        if (( "$x_plus" <= "$to" && "$x_plus" >= "$from" )); then

            x_plus_chosen_cell=$(grep "^$x_plus $random_y [0-9]$" $player2_board_file)
            status_of_x_plus_chosen_cell=$(echo $x_plus_chosen_cell | awk '{print $3}')

            if (( $status_of_x_plus_chosen_cell == 0 )); then
                ((random_x++))
            fi

        elif (( "$x_minus" <= "$to" && "$x_minus" >= "$from" )); then
        
            x_minus_chosen_cell=$(grep "^$x_minus $random_y [0-9]$" $player2_board_file)
            status_of_x_minus_chosen_cell=$(echo $x_minus_chosen_cell | awk '{print $3}')

            if (( $status_of_x_minus_chosen_cell == 0 )); then
                ((random_x--))
            fi

        elif (( "$y_minus" <= "$to" && "$y_minus" >= "$from" )); then

            y_minus_chosen_cell=$(grep "^$random_x $y_minus [0-9]$" $player2_board_file)
            status_of_y_minus_chosen_cell=$(echo $y_minus_chosen_cell | awk '{print $3}')
            if (( $status_of_y_minus_chosen_cell == 0 )); then
                ((random_y--))
            fi

        elif (( "$y_plus" <= "$to" && "$y_plus" >= "$from" )); then

            y_plus_chosen_cell=$(grep "^$random_x $y_plus [0-9]$" $player2_board_file)
            status_of_y_plus_chosen_cell=$(echo $y_plus_chosen_cell | awk '{print $3}')

            if (( $status_of_y_plus_chosen_cell == 0 )); then
                ((random_y++))
            fi
        else
            continue
        fi

    
        sed -i "s/^$random_x $random_y [0-9]$/$random_x $random_y 1/" $player2_board_file
        ((i++))
    fi
     echo $"Two ship first {$first_x}, {$first_y} second {$random_x}, {$random_y}"
done


i=0;

while (( i < countOne )); do
    random_x=$(( RANDOM % $to + $from ))
    random_y=$(( RANDOM % $to + $from ))
    chosen_cell=$(grep "^$random_x $random_y [0-9]$" $player2_board_file)
    status_of_chosen_cell=$(echo $chosen_cell | awk '{print $3}')

    if (( $status_of_chosen_cell == 1 )); then
        continue;
    else 
        sed -i "s/^$random_x $random_y [0-9]$/$random_x $random_y 1/" $player2_board_file
        ((i++))
    fi
    echo "One ship. {$random_x}, {$random_y}"
done




