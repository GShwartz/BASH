#!/bin/bash
##################################################################
#			    AUTO LAMP + WordPress Installation               # 
#				    Written by Gil Shwartz                       #       
#				   gilshwartzdjgs@gmail.com			             #
#				www.linkedin.com/in/gilshwartz                   #
##################################################################

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
LP='\033[1;35m'

clear

function show_welcome() {
	echo
	echo "************************************************************"
	echo
	echo "$(tput setaf 4)[=]$(tput setaf 7)Welcome to $(tput setaf 2)lAMpWP$(tput setaf 7) Installation!"
	echo
	echo "$(tput setaf 7)[*]$(tput setaf 7)Written by Gil Shwartz"
	echo
	echo "$(tput setaf 4)[=]$(tput setaf 7)https://www.linkedin.com/in/gilshwartz/"
	echo
	echo "************************************************************"
	echo
}

function main() {
	
	check_update
	case $update in
			y) 	get_info ;;
			Y) 	get_info ;;
			n) apt update && apt upgrade -y
				main
				;;
			N) apt update && apt upgrade -y
				main
				;;
			*) 	echo
				echo -e "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
				echo
				main
				;;
	esac
}

function check_update() {
	echo "$(tput setaf 3)[?]$(tput setaf 7)Is the system fully updated? [Y/n]?  "
	read update
}

function get_info() {

	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter MySQL root password: "
	read -s rootpasswd
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter database name (example: database1, wordpress): "
	read dbname
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter database user: "
	read username
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter database user password: "
	read -s userpass
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter server name (ex: server.com): "
	read sname
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter server alias (ex: www.server.com): "
	read salias
	echo
	wp_inst
}

function run() {
	
	case $wp in 
		y) cluster ;;
		Y) cluster ;;
		n) exit ;;
		N) exit ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!" ;;
			
	esac	
}

function cluster() {

	inst_apache
	inst_mysql
	db_create
	inst_php
	cfg_apache
	wpdb_create
	inst_wordpress
	show_bye
}

function cluster_skin() {

	inst_apache
	inst_mysql
	db_create
	inst_php
	cfg_apache
	inst_wordpress
	show_bye
}

function chk_info() {
	echo
	echo "******************************"
	echo "Initial database:"
	echo
	echo "$(tput setaf 6)[i]$(tput setaf 7)Database Name: $dbname"
	echo "$(tput setaf 6)[i]$(tput setaf 7)Database user: $username"
	echo
	echo "******************************"
	echo "WordPress database:"
	echo
	echo "$(tput setaf 6)[i]$(tput setaf 7)Database Name: $wpdbname"
	echo "$(tput setaf 6)[i]$(tput setaf 7)Database user: $wpusername"
	echo
	echo "******************************"
	echo "Server Info:"
	echo
	echo "$(tput setaf 6)[i]$(tput setaf 7)Server Name: $sname"
	echo "$(tput setaf 6)[i]$(tput setaf 7)Server Alias: $salias"
	echo
	echo "******************************"
	echo
	echo "$(tput setaf 3)[?]$(tput setaf 7)Is the information correct? [Y/n] "
	read inf
	case $inf in
		y) run ;;
		Y) run ;;
		n) main ;;
		N) main ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
			main
			;;
	esac
}

function inst_apache() {
	echo
	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing apache2..."
	sleep 1s
	echo "<=== Apache2 Install ===>" >> /tmp/lamplog.log
	apt install apache2 -y > /dev/null 2> /dev/null >> /tmp/lamplog.log
	systemctl start apache2
	systemctl enable apache2 > /dev/null 2> /dev/null >> /tmp/lamplog.log
	systemctl status apache2 >> /tmp/lamplog.log
	echo "<=== Apache2 Install Complete ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)apache2 installed successfully!"
	sleep 1s
}

function inst_mysql() {
	echo "<=== MySQL Install ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing MySql Database Server..."
	sleep 1s
	apt install mysql-server mysql-client -y > /dev/null 2> /dev/null >> /tmp/lamplog.log
	systemctl enable mysql > /dev/null 2> /dev/null >> /tmp/lamplog.log
	sleep 1s
	echo "<=== MySQL Secure Install ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Securing MySQL... "
	mysql -u root <<EOF
						ALTER USER 'root'@'localhost' IDENTIFIED BY '$rootpasswd';
						DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
						DELETE FROM mysql.user WHERE User='';
						DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
						FLUSH PRIVILEGES;
EOF
	echo "$(tput setaf 2)[+]$(tput setaf 7)MySQL installed successfully!"
	echo "<=== MySQL Install Complete ===>" >> /tmp/lamplog.log
	sleep 1s
}

function db_create() {
	echo "<=== Create Initial Database ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Creating database..."
	mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET = utf8 */;" 2> /dev/null >> /tmp/lamplog.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)Database created!"
	echo "$(tput setaf 6)[i]$(tput setaf 7)Creating user..."
	mysql -uroot -p${rootpasswd} -e "CREATE USER ${username}@localhost IDENTIFIED BY '${userpass}';" 2> /dev/null >> /tmp/lamplog.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)User Created!"
	echo "$(tput setaf 6)[i]$(tput setaf 7)Granting ALL privileges on ${dbname} to ${username}!"
	mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${username}'@'localhost';" 2> /dev/null >> /tmp/lamplog.log
	mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;" 2> /dev/null >> /tmp/lamplog.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)Database created successfully!"
	echo "<=== End Create Initial Database ===>" >> /tmp/lamplog.log
	sleep 1s
}

function inst_php() {
	echo "<=== PHP7.3 Repo Install ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing PHP7.3 Repository..."
	sleep 1s
	yes '' | add-apt-repository ppa:ondrej/php > /dev/null >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Updating system..."
	sleep 1s
	apt-get update > /dev/null >> /tmp/lamplog.log
	echo "<=== PHP7.3 Repo Install Complete ===>\n" >> /tmp/lamplog.log
	echo "<=== PHP7.3 Install ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing PHP7.3..."
	sleep 1s
	apt install php7.3 php7.3-mysql libapache2-mod-php7.3 -y 2> /dev/null >> /tmp/lamplog.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)PHP7.3 installed successfully!"
	sleep 1s
	echo "<=== PHP7.3 Install Complete ===>" >> /tmp/lamplog.log
}

function cfg_apache() { 
	echo "<=== Start Apache2 Config ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Updating config..."
	chown www-data:www-data /var/www/html/
	sed -i 's/index.html/index.html index.php/' /etc/apache2/mods-enabled/dir.conf
	echo "<?php" >> /var/www/html/info.php
	echo "	phpinfo();" >> /var/www/html/info.php
	echo "?>" >> /var/www/html/info.php
	systemctl restart apache2
	echo "<=== End Apache2 Config ===>" >> /tmp/lamplog.log
	sleep 1s
}

function wp_inst() {
	echo "$(tput setaf 3)[?]$(tput setaf 7)Would you like to install WordPress? [Y/n] "
	read wp
	case $wp in
		y) wp_database ;;
		Y) wp_database ;;
		n) cluster_skin ;;
		N) cluster_skin ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
			wp_inst
			;;
	esac
}

function wp_database() {
	echo
	echo "$(tput setaf 3)[?]$(tput setaf 7)Would you like to install a WordPress database? [Y/n] "
	echo "$(tput setaf 1)[i]$(tput setaf 7)'n' will install WordPress on the initial database"
	read wpdb
	case $wpdb in
		y) wpdb ;;
		Y) wpdb ;;
		n) cluster_skin ;;
		N) cluster_skin ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
			wp_database
			;;
	esac
}

function wpdb_create() {
	echo "<=== Create WordPress Database ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Creating database..."
	mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${wpdbname} /*\!40100 DEFAULT CHARACTER SET = utf8 */;" 2>/dev/null >> /tmp/lamplog.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)Database created!"
	echo "$(tput setaf 6)[i]$(tput setaf 7)Creating user..."
	mysql -uroot -p${rootpasswd} -e "CREATE USER ${wpusername}@localhost IDENTIFIED BY '${wpuserpass}';" 2>/dev/null >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Granting ALL privileges on ${wpdbname} to ${wpusername}!"
	mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${wpdbname}.* TO '${wpusername}'@'localhost';" 2>/dev/null >> /tmp/lamplog.log
	mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;" 2> /dev/null >> /tmp/lamplog.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)User Created!"
	echo "$(tput setaf 2)[+]$(tput setaf 7)WordPress database created successfully!"
	echo "<=== End Create WordPress Database ===>" >> /tmp/lamplog.log
	sleep 1s
}

function wpdb() {
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter database name (example: database1, wordpress): "
	read wpdbname
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter DB user: "
	read wpusername
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter DB User Password: "
	read -s wpuserpass
	echo
	chk_info
}

function inst_wordpress() {
	echo "<=== Start WordPress Install ===>\n" >> /tmp/lamplog.log
	if [[ "$wp" = "y" || "$wp" = "Y" ]]
	then
		echo "$(tput setaf 6)[i]$(tput setaf 7)Installing Wordpress... "
		sleep 1s
		cd /var/www/html
		wget -c http://wordpress.org/latest.zip > /dev/null 2> /dev/null >> /tmp/lamplog.log
		apt install unzip -y > /dev/null 2> /dev/null >> /tmp/lamplog.log
		echo "$(tput setaf 6)[i]$(tput setaf 7)Unzipping..."
		unzip latest.zip > /dev/null >> /tmp/lamplog.log
		sleep 1s
		echo "$(tput setaf 6)[i]$(tput setaf 7)Writing Permissions... "
		chown -R www-data:www-data wordpress
		echo "$(tput setaf 6)[i]$(tput setaf 7)Removing zip file... "
		rm latest.zip
		sleep 1s
		cd /var/www/html/wordpress
		echo "$(tput setaf 6)[i]$(tput setaf 7)Writing php config... "
		mv wp-config-sample.php wp-config.php
		sed -i "s/database_name_here/${dbname}/" /var/www/html/wordpress/wp-config.php
		sed -i "s/username_here/${username}/" /var/www/html/wordpress/wp-config.php
		sed -i "s/password_here/${userpass}/" /var/www/html/wordpress/wp-config.php
		sleep 1s
		touch /etc/apache2/sites-available/wp.conf
		cat <<EOF > /etc/apache2/sites-available/wp.conf
			<VirtualHost *:80>
	
				ServerName sname
				ServerAlias salias
				DocumentRoot /var/www/html/wordpress
	
				<Directory /var/www/html/wordpress>
					Options Indexes FollowSymLinks
					AllowOverride All
					Require all granted
				</Directory>
	
				ErrorLog ${APACHE_LOG_DIR}/your_domain.com_error.log
				CustomLog ${APACHE_LOG_DIR}/your_domain.com_access.log combined
			</VirtualHost>
EOF
		sed -i "s/sname/'${sname}'/" /etc/apache2/sites-available/wp.conf
		sed -i "s/salias/'${salias}'/" /etc/apache2/sites-available/wp.conf
		echo "$(tput setaf 6)[i]$(tput setaf 7)Creating syslink... "
		sleep 1s
		ln -s /etc/apache2/sites-available/wp.conf /etc/apache2/sites-enabled/wp.conf
		echo "<=== End WordPress Install ===>" >> /tmp/lamplog.log
		show_bye
	fi
}

function show_bye() {
	echo
	echo
	echo "*****************************************************"
	echo "$(tput setaf 2)[+]$(tput setaf 7)Installation Complete!"
	echo "$(tput setaf 2)[+]$(tput setaf 7)PHP - <IP>\server.com/info.php"
	echo "$(tput setaf 2)[+]$(tput setaf 7)WordPress - <IP>\server.com/wordpress"
	echo "$(tput setaf 6)[i]$(tput setaf 7)You can view the installation log at /tmp/lamplog.log"
	echo "*****************************************************"
	echo
	exit
}

if (( $EUID != 0 )); then
	echo "#######################################################"
    echo "$(tput setaf 1)[!]$(tput setaf 7)This script requires root privileges in order"
	echo "$(tput setaf 1)[!]$(tput setaf 7)to be able to write to /var/www/html/"
	echo "$(tput setaf 1)[!]$(tput setaf 7)Please run as root."
    echo "#######################################################"
	exit
	
fi

show_welcome
main
