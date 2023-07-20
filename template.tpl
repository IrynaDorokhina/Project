 #!/bin/bash
sudo yum update -y
sudo yum install -y httpd mariadb105-server

sudo yum install -y php-mysqli
sudo amazon-linux-extras install -y epel
sudo yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo amazon-linux-extras enable php8.0
sudo yum clean metadata
sudo yum install -y php-cli php-pdo php-fpm php-json php-mysqlnd php php-{mbstring,json,xml,mysqlnd}

sudo systemctl start httpd
sudo systemctl start mariadb

sudo systemctl enable httpd
sudo systemctl enable mariadb

#sudo mysql_secure_installation

DB_NAME="my_wp_db"
DB_USER="wp_user"
DB_PASSWORD="password123"
WP_PASSWORD="HelloWordpress111!!!"

sudo mysql -e "CREATE DATABASE ${DB_NAME};"
sudo mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
sudo mysql -e "GRANT ALL ON my_wp_db.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

cd var/www/html

sudo curl -O https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress latest.tar.gz

sudo chown -R apache:apache /var/www/html

sudo mv wp-config-sample.php wp-config.php

sudo sed -i "s/database_name_here/${DB_NAME}" /var/www/html/wp-config.php
sudo sed -i "s/username_here/${DB_USER}" /var/www/html/wp-config.php
sudo sed -i "s/password_here/${DB_PASSWORD}" /var/www/html/wp-config.php

sudo chmod u-w /var/www/html/wp-config.php

sudo systemctl restart httpd