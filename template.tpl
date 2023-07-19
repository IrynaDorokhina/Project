#!/bin/bash

DB_NAME="Wordpress-DB"
DB_USER="Maxey"
DB_PASSWORD="Yq5jk8tGXhP33kHM"
WP_PASSWORD="JH3zLgM34gm77tGZ"


sudo yum update -y

sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

sudo yum install -y wget php-fpm php-mysqli php-json php-devel php

sudo systemctl start php-fpm
sudo systemctl enable php-fpm

sudo amazon-linux-extras enable php7.4
sudo yum clean metadata
sudo yum install -y php

sudo yum install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

sudo mv wordpress/* /var/www/html/

mysql -u root -p -e "CREATE DATABASE \`$DB_NAME\` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci; GRANT ALL ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD'; FLUSH PRIVILEGES;"

sudo chmod u+w /var/www/html/wp-config.php

sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sudo sed -i "s/database_name_here/$DB_NAME/g" /var/www/html/wp-config.php
sudo sed -i "s/username_here/$DB_USER/g" /var/www/html/wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/g" /var/www/html/wp-config.php

sudo chmod u-w /var/www/html/wp-config.php

sudo systemctl restart httpd