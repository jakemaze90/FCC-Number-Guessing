#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

# create intro message 
echo -e "\nEnter your username:"

# get SECRET_NUMBER and USERNAME
SECRET_NUMBER=$(( $RANDOM % 1000 + 1))
read USERNAME

# get value for returning user
RETURNING_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

# if no returning user
if [[ -z $RETURNING_USER ]]
then
    # insert user
    INSERTED_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    # create message for inserted user
    echo "Welcome, $USERNAME! It looks like this is your first time here."
else
    # create message for existing user
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
    BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# grab user_id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")


# create message for guess
TRIES=1

GUESSING_MACHINE() {
    # get guess and count tries
    read GUESS
    
    # create while loop to validate the guess
    while true
    do
        # check if GUESS is a number
        if [[ ! $GUESS =~ ^[0-9]+$ ]]
        then
            echo "That is not an integer, guess again:"
            read GUESS
        # check if GUESS is the correct number
        elif [[ $GUESS -eq $SECRET_NUMBER ]]
        then
            break
        # give feedback on the guess
        elif [[ $GUESS -gt $SECRET_NUMBER ]]
        then
            echo "It's lower than that, guess again:"
            read GUESS
        elif [[ $GUESS -lt $SECRET_NUMBER ]]
        then
            echo "It's higher than that, guess again:"
            read GUESS
        fi
        TRIES=$(($TRIES + 1))
    done
}

# prompt user for the first guess
echo "Guess the secret number between 1 and 1000:"
GUESSING_MACHINE

# insert data from game
INSERTED_GAME=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $TRIES);")
echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"

