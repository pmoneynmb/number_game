#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

IS_INTEGER() {
  [[ "$1" =~ ^[0-9]+$ ]] && return 0 || return 1
}

IS_IN_RANGE() {
  local num=$1
  (( $num >= 1 && $num <= 1000 )) && return 0 || return 1
}

LOG_DATA(){
  local attempts=$1
  local username=$2
  
  existing_user=$($PSQL "SELECT username, least_guesses, games_played FROM users WHERE username='$username'")
  if [[ -z $existing_user ]]
  then 
    NONEXISTINGRESULT=$($PSQL "INSERT INTO users(username, least_guesses, games_played) VALUES('$username', $attempts, 1)")
  else 
   EXISTINGRSEULT=$($PSQL "UPDATE users SET least_guesses = LEAST($attempts, least_guesses), games_played = games_played + 1 WHERE username='$username'")
  fi
}

PLAY_GAME(){
  local secret_number=$(( RANDOM % 1000 + 1 ))
  local attempts=1
  

  echo "Guess the secret number between 1 and 1000:"
  
  while true; 
  do 
    read guess
    if ! IS_INTEGER "$guess"
    then 
      echo "That is not an integer, guess again:"
    elif ! IS_IN_RANGE "$guess"
    then 
      echo "That is not in range, guess again:"
    else
      (( attempts++ ))

      if (( $guess < $secret_number ))
      then 
        echo "It's higher than that, guess again:" 
      elif (( $guess > $secret_number ))
      then
        echo "It's lower than that, guess again:"
      elif (( $guess == $secret_number ))
      then
        echo "You guessed it in $attempts tries. The secret number was $secret_number. Nice job!"
        LOG_DATA "$attempts" "$username"
        break;
      fi 
    fi
  done

  
  exit 0
}


  echo "Enter your username:"
  read username
  existing_user=$($PSQL "SELECT username, least_guesses, games_played FROM users WHERE username='$username'")

  if [[ -z $existing_user ]]
  then 
    echo "Welcome, $username! It looks like this is your first time here."
  else
    IFS="|" read -r username LEAST GAMES <<< "$existing_user"
    
    echo "Welcome back, $username! You have played $GAMES games, and your best game took $LEAST guesses."
  fi
  PLAY_GAME
  
