
#! /bin/bash
sudo yum update -y
sudo yum install -y httpd mariadb105-server php php-mysqlnd unzip

sudo systemctl start httpd
sudo systemctl enable httpd

cd /var/www/html
sudo curl -LO https://wordpress.org/latest.zip
sudo unzip latest.zip
sudo mv -f wordpress/* ./

sudo cp wp-config-sample.php wp-config.php 
sudo sed -i 's/database_name_here/wordpress/' wp-config.php 
sudo sed -i 's/username_here/wpuser03/' wp-config.php 
sudo sed -i 's/password_here/wppassword/' wp-config.php

sudo amazon-linux-extras enable php8.0
sudo yum update -y
sudo service httpd restart