#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Deployment script
#
# Usage:
#   ./deploy.sh [-s (test|development|production)] [-d number]
#
#       -s:         the server where new changes will be deployed (default: development)
#       -d:         how old (in days) are the modified files to be deployed? (default: 1)
#
# Execution example:
#   ./deploy.sh -s development -d 3
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Import the passwords from a local file
# This file shall be located in a private user's directory
# The passwords shall be encoded (base64)
source ~/path/to/passwords.sh

# Default values
echo
SERVER=development
CONN=username@development.the_server.com
BASEDIR=/htdocs/
PASSWD=$PASSWD_development
DAYS=1

# Check the flags to choose server and days
while getopts ":s: :d:" opt; do
  case $opt in
    s)
      SERVER=$OPTARG
      if [ $SERVER = test ]; then
        CONN=username@test.the_server.com
        PASSWD=$PASSWD_test
      elif [ $SERVER = development ]; then
        CONN=username@development.the_server.com
        PASSWD=$PASSWD_development
      elif [ $SERVER = production ]; then
        CONN=username@the_server.com
        PASSWD=$PASSWD_production
      else
        echo "Invalid server. Cancelling..."
        exit 1
      fi
      ;;
    d)
      DAYS=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done


# Check if everything is ready to be deployed
# All changes shall be commited to the repository
if ! [ -z "$(git status --porcelain)" ]; then
    # Working directory ready for deployment

    echo "Files modified $DAYS days ago will be deployed to $SERVER server"
    echo "Creating temporal deployment directory..."

    # change to the name of your repository
    REPOSITORY=the_repository_directory
    TEMP=temp_dep

    cd ..
    rm -Rf $TEMP/
    find $REPOSITORY -mtime -$DAYS | cpio -pd $TEMP/

    echo "Removing unwanted files..."

    cd $TEMP/$REPOSITORY
    rm -Rf .git/ .idea/ docs/ vendor/ workbench/
    rm -f .gitignore .htaccess public/.htaccess composer.json readme.md deploy.sh
    find . -name ".DS_Store" -type f -delete

    echo "Do not forget to create a snapshot of the system"
    read -p "Press ENTER to continue "

    echo "Connecting to $SERVER server..."
    echo "Use the following command to transfer the files:"
    echo "    put -r * $BASEDIR"
    echo -n "    password: "
    echo $PASSWD | base64 -D
    echo

    sftp $CONN
    # once the transfer is finished, use the command <quit> or <bye> to close the connection

    echo "Deployment completed. Connexion closed."

else
    git status --porcelain
    echo
    echo "The files above have been modified locally."
    echo "All changes should be tested before deploying them,"
    echo "and before deployment, the repository must be updated."
    echo "So go ahead and test your changes, commit & push, then run this script again."
fi

echo
