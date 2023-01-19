#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Klipper ~~~\n"

SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "How can I help you?"

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  
  APPOINTMENT_SERVICE
}

APPOINTMENT_SERVICE() {
  # ask the service
  read SERVICE_ID_SELECTED

  SERVICE_OPTION=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
  SERVICE_CHOSEN=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # if not a service
  if [[ -z $SERVICE_CHOSEN ]]
    then
      MAIN_MENU "That's not a valid option."
    else
      # ask the phone
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      PHONE_READ=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if not a phone
      if [[ -z $PHONE_READ ]]
        then
          # get a new customer
          echo -e "\nYou are not registered, please enter your name:"
          read CUSTOMER_NAME

          REGISTER_NAME=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_NAME_LIST=$($PSQL "SELECT name FROM customers WHERE customer_id = '$CUSTOMER_ID'")
    # ask the time
    echo -e "\nWhat time would you like to make the appointment, $(echo $CUSTOMER_NAME_LIST | sed -r 's/^ *| *$//g')?"
    read SERVICE_TIME

    SET_SERVICE_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  fi

  echo -e "\nI have put you down for a $(echo $SERVICE_OPTION | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME_LIST | sed -r 's/^ *| *$//g')."
}

MAIN_MENU