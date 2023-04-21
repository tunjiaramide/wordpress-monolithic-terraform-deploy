#!/bin/bash

# Install Wordpress on Ubuntu 22.04

# Set up dabatase variables - Please change the passwords
DBName='a4lwordpress'
DBUser='a4lwordpress'
DBPassword='4n1m4l4L1f3'
DBRootPassword='4n1m4l4L1f3'

# Install Apache
apt update -y
apt install apache2 -y

# Enable firewall
ufw allow OpenSSH # To allow ssh
ufw allow in "Apache" # To allow http
ufw enable

# Install mysql, php and php extensions
sudo apt install mysql-server -y
sudo apt install php libapache2-mod-php php-mysql -y
sudo apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y

# Start apache and mysql
systemctl start apache2
systemctl enable apache2
systemctl start mysql
systemctl enable mysql

# Set root password for mysql
echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DBRootPassword';" >> /tmp/dbpass.setup
sudo mysql < /tmp/dbpass.setup
sudo mysql_secure_installation
sudo rm /tmp/dbpass.setup

# Enabling .htaccess Overrides and Rewrite Module
sudo sed -i '/DocumentRoot/a <Directory /var/www/html/>\nAllowOverride All\n</Directory>' /etc/apache2/sites-available/000-default.conf
sudo a2enmod rewrite
sudo systemctl restart apache2


# Install Wordpress
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
touch /tmp/wordpress/.htaccess
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
rm -rf /var/www/html/*
sudo cp -a /tmp/wordpress/. /var/www/html
sudo chown -R www-data:www-data /var/www/html
sudo find /var/www/html/ -type d -exec chmod 750 {} \;
sudo find /var/www/html/ -type f -exec chmod 640 {} \;


# Set up Wordpress database 
echo "CREATE DATABASE $DBName;" >> /tmp/db.setup
echo "CREATE USER '$DBUser'@'localhost' IDENTIFIED BY '$DBPassword';" >> /tmp/db.setup
echo "GRANT ALL ON $DBName.* TO '$DBUser'@'localhost';" >> /tmp/db.setup
echo "FLUSH PRIVILEGES;" >> /tmp/db.setup
mysql -u root --password=$DBRootPassword < /tmp/db.setup
sudo rm /tmp/db.setup


# Insert details into wordpress config file
sudo sed -i "s/'database_name_here'/'$DBName'/g" /var/www/html/wp-config.php
sudo sed -i "s/'username_here'/'$DBUser'/g" /var/www/html/wp-config.php
sudo sed -i "s/'password_here'/'$DBPassword'/g" /var/www/html/wp-config.php
sudo sed -i "/<?php/a define('FS_METHOD', 'direct');" /var/www/html/wp-config.php

