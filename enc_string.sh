#!/bin/bash

# Function for encryption
encrypt() {
  local plaintext="$1"
  local password="$2"
  local encrypted=$(echo -n "$plaintext" | openssl enc -pbkdf2 -e -aes-256-cbc -pass pass:"$password" | base64)
  
  if [ $? -eq 0 ]; then
    echo "Encryption successful."
  else
    echo "Error during encryption."
    exit 1
  fi

  echo "$encrypted"
}

# Function for decryption
decrypt() {
  local password="$1"
  local encrypted_text
  local decrypted

  echo "Enter the encrypted text (Ctrl+D to finish input):"
  encrypted_text=$(cat)
  decrypted=$(echo -n "$encrypted_text" | base64 -d | openssl enc -pbkdf2 -d -aes-256-cbc -pass pass:"$password")
  
  if [ $? -eq 0 ]; then
    echo "Decryption successful."
  else
    echo "Error during decryption."
    exit 1
  fi
  
  echo "Decrypted text: $decrypted"
}

# Checking for the presence of the decryption argument
if [ "$1" == "-d" ]; then
  if [ -z "$2" ]; then
    # If there is a decryption argument but no password, request the password
    read -s -p "Enter the password: " password
    echo
    decrypt "$password"
  else
    # If there is a decryption argument and the password is passed as the second argument
    decrypt "$2"
  fi
else
  # Prompt for text and password input for encryption
  read -p "Enter the text for encryption: " plaintext
  read -s -p "Enter the password: " password
  echo

  # Encryption
  encrypted=$(encrypt "$plaintext" "$password")

  # Print the encrypted text
  echo "Encrypted text: $encrypted"
fi
