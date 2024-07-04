#!/bin/bash
SIZE_OF_BOARD_COUNTING_FROM_ZERO=10
pipe_name="pipe2"
cells_to_shoot_on_player2_board_file="cells_to_shoot_on_player1_board_file.txt"
if [ ! -p pipe1 ]; then
  mkfifo $pipe_name
fi

echo $$ > .pid
number_of_player=2

MODE="non"
usr1()
{
      MODE="failure"
}
trap 'usr1' USR1

usr2()
{
      MODE="success"
}
trap 'usr2' USR2


lastShot=""

# echo "$number_of_player: Entering loop"
while true; do
#  sleep 1
 # echo $MODE
  if [[ $MODE == "failure" ]]; then
    # echo "$number_of_player: Starting to shoot random coordinates"
    x=$(tail -n 1 $cells_to_shoot_on_player2_board_file | awk '{print $1}')
    y=$(tail -n 1 $cells_to_shoot_on_player2_board_file | awk '{print $2}')
    lastShot="$x $y"
    sed -i '$ d' $cells_to_shoot_on_player2_board_file
    MODE="non"
    # echo "Random shot: $x $y"
    echo "$number_of_player $x $y" > $pipe_name
  fi

  if [[ $MODE == "success" ]]; then
    while true; do
      # echo "$number_of_player: Starting to shoot adjacent coordinates"
      # echo "Last shot: $lastShot"
      lastShot_x=$(echo $lastShot | awk '{print $1}')
      lastShot_y=$(echo $lastShot | awk '{print $2}')

      upper_y=$((lastShot_y + 1))
      lower_y=$((lastShot_y - 1))
      right_x=$((lastShot_x + 1))
      left_x=$((lastShot_x - 1))

      lower_coordinates_from_file=""
      left_coordinates_from_file=""

      upper_coordinates_from_file=$(grep "$lastShot_x $upper_y" $cells_to_shoot_on_player2_board_file)
      right_coordinates_from_file=$(grep "$right_x $lastShot_y" $cells_to_shoot_on_player2_board_file)
      if [[ "$lower_y" -ge 0 ]]
      then
        lower_coordinates_from_file=$(grep "$lastShot_x $lower_y" $cells_to_shoot_on_player2_board_file)
      fi
      if [[ "$left_x" -ge 0 ]]
      then
        left_coordinates_from_file=$(grep "$left_x $lastShot_y" $cells_to_shoot_on_player2_board_file)
      fi
      

      if [ -z "$upper_coordinates_from_file" ] && [ -z "$right_coordinates_from_file" ] && [ -z "$lower_coordinates_from_file" ] && [ -z "$left_coordinates_from_file" ]; then
        MODE="failure"
        # echo "All adjacent coordinates have already been shot, switching to random"
        break
      fi

      if [ ! -z "$upper_coordinates_from_file" ]; then
        sed -i "/$lastShot_x $upper_y/d" $cells_to_shoot_on_player2_board_file
        lastShot="$lastShot_x $upper_y"
        MODE="non"
        echo "$number_of_player $lastShot_x $upper_y" > $pipe_name
        # echo "Shooting upper coordinates"
        # echo "Player 2 shot $lastShot_x $upper_y"
        # echo 
        break
      fi

      if [ ! -z "$right_coordinates_from_file" ]; then
        sed -i "/$right_x $lastShot_y/d" $cells_to_shoot_on_player2_board_file
        lastShot="$right_x $lastShot_y"
        echo "$number_of_player $right_x $lastShot_y" > $pipe_name
        MODE="non"
        # echo "Shooting right coordinates"
        # echo "Player 2 shot $right_x $lastShot_y"
        # echo 
        break
      fi

      if [ ! -z "$lower_coordinates_from_file" ]; then
        sed -i "/$lastShot_x $lower_y/d" $cells_to_shoot_on_player2_board_file
        lastShot="$lastShot_x $lower_y"
        echo "$number_of_player $lastShot_x $lower_y" > $pipe_name
        # echo "Shooting lower coordinates"
        # echo "Player 2 shot $lastShot_x $lower_y"
        # echo
        MODE="non"
        break
      fi

      if [ ! -z "$left_coordinates_from_file" ]; then
        sed -i "/$left_x $lastShot_y/d" $cells_to_shoot_on_player2_board_file
        lastShot="$left_x $lastShot_y"
        echo "$number_of_player $left_x $lastShot_y" > $pipe_name
        # echo "Shooting left coordinates"
        # echo "Player 2 shot $left_x $lastShot_y"
        # echo 
        MODE="non"
        break
      fi
    done
  fi
done



