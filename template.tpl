 #!/bin/bash
    echo “CONSUL_ADDRESS = ${consul_address]” > /tmp/iplist
    sudo yum update -y
    sudo yum install -y nginx
    sudo service nginx start
    sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel
    sudo yum install mariadb105 server
    sudo systemctl status mariadb
    sudo mysql_secure_installation
    sudo systemctl start mariabd
    sudo mysql_secure_installation
    sudo mysql
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    mysql -u root -p
    cp wordpress/wp-config-sample.php wordpress/wp-config.php
    nano wordpress/wp-config.php






