import os
import crypt
import sys

# Function to get username and password from the user
def get_credentials():
    username = input("Enter a username: ")
    password = input("Enter a password: ")
    return username, password

# Function to create the password hash
def create_password_hash(password):
    salt = os.urandom(12)
    salt_encoded = salt.hex()
    password_hash = crypt.crypt(password, f"$6${salt_encoded}")
    return password_hash

# Function to write the password file
def write_password_file(username, password_hash, file_path):
    with open(file_path, "a") as file:
        file.write(f"{username}:{password_hash}\n")

def main():
    print("Nginx Password File Generator")

    # Check for a file path argument
    file_path = "password.txt"
    if len(sys.argv) > 1:
        file_path = sys.argv[1]

    username, password = get_credentials()
    password_hash = create_password_hash(password)
    write_password_file(username, password_hash, file_path)
    print(f"Password file '{file_path}' has been created.")

if __name__ == "__main__":
    main()
