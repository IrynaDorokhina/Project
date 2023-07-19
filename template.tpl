 #!/bin/bash
sudo yum update -y
sudo yum install -y httpd mariadb-server php php-mysql
sudo systemctl start httpd
sudo systemctl start mariadb
sudo systemctl enable httpd
sudo systemctl enable mariadb
sudo mysql_secure_installation

"CREATE DATABASE my_wp_db";
"CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'password123'";
"GRANT ALL ON my_wp_db.* TO 'wp_user'@'localhost'";
"FLUSH PRIVILEGES";

cd var/www/html

cudo curl -0 https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress latest.tar.gz

sudo chown -R apache:apache /var/www/html

sudo mv wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/g" /var/www/html/wp-config.php
sudo sed -i "s/username_here/$DB_USER/g" /var/www/html/wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/g" /var/www/html/wp-config.php

sudo chmod u-w /var/www/html/wp-config.php

sudo systemctl restart httpd