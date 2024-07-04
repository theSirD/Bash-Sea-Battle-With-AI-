#!/bin/bash

echo "Games starts now."
echo 

player1_board_file="player1_board_file.txt"
player2_board_file="player2_board_file.txt"
score1_file="score1_file.txt"
score2_file="score2_file.txt"

touch $score1_file
touch $score2_file

from=0
to=3
# tmp=$(( "$to" % 3 ))
number_of_lines_to_erase=$((2 + 2 + ("$to" + 1)*2))

clear_this_line(){
        printf '\r'
        cols="$(tput cols)"
        for i in $(seq "$cols"); do
                printf ' '
        done
        printf '\r'
}


erase_lines(){
        test -z "$1" && lines="1" || lines="$1"

        UP='\033[1A'

        [ "$lines" = 0 ] && return

        if [ "$lines" = 1 ]; then
                clear_this_line
        else
                lines=$((lines-1))
                clear_this_line
                for i in $(seq "$lines"); do
                        printf "$UP"
                        clear_this_line
                done
        fi
}

WINCONDITION=9

# echo "handler: trying to create pipes"
mkfifo "pipe1"
./playerOfSeaBattle1.sh &
pid1=$!

mkfifo "pipe2"
./playerOfSeaBattle2.sh &
pid2=$!

echo "Initial board 1 (player 2 shoots here)"
for ((y=$from; y< $((to+1)); y++)); do
	row=""
	for ((x=$from; x< $((to+1)); x++)); do
		cell=$(grep "^$x $y [0-9]$" $player1_board_file | awk '{print $3}')
		row="${row}$cell"
		row="${row} "    
	done
	echo "$row"
done
echo
echo "Initial board 2 (player 1 shoots here)"
for ((y=$from; y< $((to+1)); y++)); do
	row=""
	for ((x=$from; x< $((to+1)); x++)); do
		cell=$(grep "^$x $y [0-9]$" $player2_board_file | awk '{print $3}')
		row="${row}$cell"
		row="${row} "    
	done
	echo "$row"
done 

echo 0 >> $score1_file
echo 0 >> $score2_file


sleep 2

kill -USR1 $pid1


while true;
do
	count0=$(tail -n 1 $score1_file)
	if [[ $count0 -eq $WINCONDITION ]];
	then 
		exit 0
	fi

	count1=$(tail -n 1 $score2_file)
	if [[ $count1 -eq $WINCONDITION ]];
	then 
		exit 0
	fi

	(tail -f pipe1) | 
		while true; 
		do
			read LINE
			x=$(echo $LINE | awk '{print $2}')
			y=$(echo $LINE | awk '{print $3}')
		    chosen_cell=$(grep "^$x $y [0-9]$" $player2_board_file)
            status_of_chosen_cell=$(echo $chosen_cell | awk '{print $3}')

			erase_lines "$number_of_lines_to_erase"
			echo "Player 1 shot $x $y"
			echo 

#			echo "x: $x, y: $y"
			if (( $status_of_chosen_cell == 1 ));
			then
				count0=$(tail -n 1 $score1_file)
				count0=$((count0+1))
				echo $count0 >> $score1_file
                sed -i "s/^$x $y [0-9]$/$x $y 3/" $player2_board_file
				#player2_board[$x,$y]=3 

				echo "Board 1 (player 2 shoots here)"
				for ((y=$from; y< $((to+1)); y++)); do
					row=""
					for ((x=$from; x< $((to+1)); x++)); do
						cell=$(grep "^$x $y [0-9]$" $player1_board_file | awk '{print $3}')
						row="${row}$cell"
						row="${row} "    
					done
					echo "$row"
				done
				echo
				echo "Board 2 (player 1 shoots here)"
				for ((y=$from; y< $((to+1)); y++)); do
					row=""
					for ((x=$from; x< $((to+1)); x++)); do
						cell=$(grep "^$x $y [0-9]$" $player2_board_file | awk '{print $3}')
						row="${row}$cell"
						row="${row} "    
					done
					echo "$row"
				done 

				# echo "Getting info from 1"
				count0=$(tail -n 1 $score1_file)
				count1=$(tail -n 1 $score2_file)
				# echo "$count0 Ships destroyed by 1"
				# echo "$count1 Ships destroyed by 2"

				count0=$(tail -n 1 $score1_file)
				if [[ $count0 -eq $WINCONDITION ]];
				then 
					echo 
					echo "Player1 won"
					kill -TERM $pid1
					kill -TERM $pid2
					rm pipe1
					rm pipe2
					exit 0
				fi

				kill -USR2 $pid1
			else
				sed -i "s/^$x $y [0-9]$/$x $y 2/" $player2_board_file
				# echo "Board 1 (player 2 shoots here)"

				echo "Board 1 (player 2 shoots here)"
				for ((y=$from; y< $((to+1)); y++)); do
					row=""
					for ((x=$from; x< $((to+1)); x++)); do
						cell=$(grep "^$x $y [0-9]$" $player1_board_file | awk '{print $3}')
						row="${row}$cell"
						row="${row} "    
					done
					echo "$row"
				done
				echo
				echo "Board 2 (player 1 shoots here)"
				for ((y=$from; y< $((to+1)); y++)); do
					row=""
					for ((x=$from; x< $((to+1)); x++)); do
						cell=$(grep "^$x $y [0-9]$" $player2_board_file | awk '{print $3}')
						row="${row}$cell"
						row="${row} "    
					done
					echo "$row"
				done 

				# echo "Getting info from 1"
				count0=$(tail -n 1 $score1_file)
				count1=$(tail -n 1 $score2_file)
				# echo "$count0 Ships destroyed by 1"
				# echo "$count1 Ships destroyed by 2"
				kill -USR1 $pid2
				break
			fi
		done

	count0=$(tail -n 1 $score1_file)
	if [[ $count0 -eq $WINCONDITION ]];
	then 
		exit 0
	fi

	count1=$(tail -n 1 $score2_file)
	if [[ $count1 -eq $WINCONDITION ]];
	then 
		exit 0
	fi
	(tail -f pipe2) |
		while true;
		do
			read LINE
			x=$(echo $LINE | awk '{print $2}')
            y=$(echo $LINE | awk '{print $3}')
            chosen_cell=$(grep "^$x $y [0-9]$" $player1_board_file)
            status_of_chosen_cell=$(echo $chosen_cell | awk '{print $3}')
			erase_lines "$number_of_lines_to_erase"
			echo "Player 2 shot $x $y"
			echo 
			
#			echo "x: $x, y: $y"
            if (( $status_of_chosen_cell == 1 ));
            then
				count1=$(tail -n 1 $score2_file)
				count1=$((count1+1))
				echo $count1 >> $score2_file
                sed -i "s/^$x $y [0-9]$/$x $y 3/" $player1_board_file
				#player1_board[$x,$y]=3

				echo "Board 1 (player 2 shoots here)"
				for ((y=$from; y< $((to+1)); y++)); do
					row=""
					for ((x=$from; x< $((to+1)); x++)); do
						cell=$(grep "^$x $y [0-9]$" $player1_board_file | awk '{print $3}')
						row="${row}$cell"
						row="${row} "    
					done
					echo "$row"
				done
				echo
				echo "Board 2 (player 1 shoots here)"
				for ((y=$from; y< $((to+1)); y++)); do
					row=""
					for ((x=$from; x< $((to+1)); x++)); do
						cell=$(grep "^$x $y [0-9]$" $player2_board_file | awk '{print $3}')
						row="${row}$cell"
						row="${row} "    
					done
					echo "$row"
				done 

				# echo "Getting info from 2"
				count0=$(tail -n 1 $score1_file)
				count1=$(tail -n 1 $score2_file)
				# echo "$count0 Ships destroyed by 1"
				# echo "$count1 Ships destroyed by 2"

				count1=$(tail -n 1 $score2_file)
				if [[ $count1 -eq $WINCONDITION ]]
				then 
							echo "Player2 won"
							kill -TERM $pid1
							kill -TERM $pid2
							rm pipe1
							rm pipe2
							exit 0
				fi

                kill -USR2 $pid2
            else
                sed -i "s/^$x $y [0-9]$/$x $y 2/" $player1_board_file
				#player1_board[$x,$y]=2

				echo "Board 1 (player 2 shoots here)"
				for ((y=$from; y< $((to+1)); y++)); do
					row=""
					for ((x=$from; x< $((to+1)); x++)); do
						cell=$(grep "^$x $y [0-9]$" $player1_board_file | awk '{print $3}')
						row="${row}$cell"
						row="${row} "    
					done
					echo "$row"
				done
				echo
				echo "Board 2 (player 1 shoots here)"
				for ((y=$from; y< $((to+1)); y++)); do
					row=""
					for ((x=$from; x< $((to+1)); x++)); do
						cell=$(grep "^$x $y [0-9]$" $player2_board_file | awk '{print $3}')
						row="${row}$cell"
						row="${row} "    
					done
					echo "$row"
				done 

				count0=$(tail -n 1 $score1_file)
				count1=$(tail -n 1 $score2_file)
				# echo "Getting info from 2"
				# echo "$count0 Ships destroyed by 1"
				# echo "$count1 Ships destroyed by 2"
                kill -USR1 $pid1
                break
            fi
        done
done







