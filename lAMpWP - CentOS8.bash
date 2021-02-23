#!/bin/bash
##################################################################
#			    AUTO LAMP + WordPress Installation				 #
#							CentOS 8							 #
#																 #
#			=============================================		 #
#			This assumes you know your way around seLinux		 #	
#					   and firewall-cmd							 #
#			=============================================		 #
#																 #
#					Written by Gil Shwartz                       #       
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

function main() {

	show_welcome
	get_info

}

function show_welcome() {

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

function get_info() {

	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter MySQL root password: "
	read -s rootpasswd
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter database name (example: database, wordpress): "
	read dbname
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter database user: "
	read username
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter database user password: "
	read -s userpass
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter server name (ex: domain.com): "
	read sname
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter server alias (ex: www.domain.com): "
	read salias
	echo
	wordpressInstall
	
}

function wordpressInstall() {

	echo "$(tput setaf 3)[?]$(tput setaf 7)Would you like to install WordPress? [Y/n] "
	read wp
	case $wp in
	
		y) wp_MakeDatabase ;;
		Y) wp_MakeDatabase ;;
		n) cluster_skin ;;
		N) cluster_skin ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
			wp_inst
			;;
	esac
	
}

function wp_MakeDatabase() {

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
			wp_MakeDatabase
			;;
	esac
	
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

function chk_info() {

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

function yumYES() {

	echo "assumeyes=1" >> /etc/yum.conf
	
}

function seLinux() {

	echo "$(tput setaf 6)[i]$(tput setaf 7)Disabling SeLinux..."
	sed -i "s/enforcing/disabled/" /etc/sysconfig/selinux
	sed -i "s/SELINUXTYPE/# SELINUXTYPE/" /etc/sysconfig/selinux
	echo "$(tput setaf 2)[+]$(tput setaf 7)Selinux Disabled!"
	
}

function fireWall() {

	echo "$(tput setaf 6)[i]$(tput setaf 7)Disabling Firewall..."
	systemctl stop firewalld 
	systemctl disable firewalld > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	systemctl status firewalld --no-pager > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)Firewall Disabled!"
	
}

function mySQL_install() {

	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing MySQL server..."
	yum install wget > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	wget http://repo.mysql.com/mysql-community-release-el7.rpm > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	rpm -ivh mysql-community-release-el7.rpm > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	yum update > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	yum -y install mysql-server > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	systemctl start mysqld
	netstat -ntulp > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	systemctl enable mysqld > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	systemctl status mysqld --no-pager > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)MySQL server installed successfully!"
	
}

function mySQL_secure() {

	echo "<=== MySQL Secure Install ===>" >> /tmp/lAMpWP.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Securing MySQL... "
	mysql -u root <<EOF
						ALTER USER 'root'@'localhost' IDENTIFIED BY '$rootpasswd';
						DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
						DELETE FROM mysql.user WHERE User='';
						DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
						FLUSH PRIVILEGES;
EOF
	echo "$(tput setaf 2)[+]$(tput setaf 7)MySQL installed successfully!"
	echo "<=== MySQL Install Complete ===>" >> /tmp/lAMpWP.log
	
}

function mySQL_createDB() {

	echo "<=== Create Initial Database ===>" >> /tmp/lAMpWP.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Creating database..."
	mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET = utf8 */;" 2> /dev/null >> /tmp/lAMpWP.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)Database created!"
	echo "$(tput setaf 6)[i]$(tput setaf 7)Creating user $username..."
	mysql -uroot -p${rootpasswd} -e "CREATE USER ${username}@localhost IDENTIFIED BY '${userpass}';" 2> /dev/null >> /tmp/lAMpWP.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)User Created!"
	echo "$(tput setaf 6)[i]$(tput setaf 7)Granting ALL privileges on ${dbname} to ${username}!"
	mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${username}'@'localhost';" 2> /dev/null >> /tmp/lAMpWP.log
	mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;" 2> /dev/null >> /tmp/lAMpWP.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)Database created successfully!"
	echo "<=== End Create Initial Database ===>" >> /tmp/lAMpWP.log
	sleep 1s
	
}

function httpd_Server() {

	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing httpd server..."
	yum -y install httpd > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	systemctl start httpd
	systemctl enable httpd > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	systemctl status httpd --no-pager > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	netstat -ntulp | grep 80 > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)httpd installed successfully!"
}

function phpInstall() {

	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing PHP7.3 Repository..."
	dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	dnf module install php:remi-7.3 > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)Repository installed successfully!"
	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing additional modules (Might take some time)..."
	dnf install php-cli php-json php-xml php-bcmath php-gd > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	dnf install php-gd php-imap php-ldap php-odbc php-pear > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	dnf install php-xmlrpc php-mbstring php-mcrypt php-mysql php-snmp php-soap php-tidy curl curl-devel > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)Modules installed successfully!"
	php -v > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Writing info.php..."
	echo "<?php" >> /var/www/html/info.php
	echo "	phpinfo();" >> /var/www/html/info.php
	echo "?>" >> /var/www/html/info.php
	echo "$(tput setaf 2)[+]$(tput setaf 7)Done!"
	echo "$(tput setaf 2)[+]$(tput setaf 7)PHP7.3 Installed successfully!"
	systemctl restart httpd
	
}

function wpdb_create() {

	echo "<=== Create WordPress Database ===>" >> /tmp/lAMpWP.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Creating $wpdbname database..."
	mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${wpdbname} /*\!40100 DEFAULT CHARACTER SET = utf8 */;" 2>/dev/null >> /tmp/lAMpWP.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)Database created!"
	echo "$(tput setaf 6)[i]$(tput setaf 7)Creating user $wpusername..."
	mysql -uroot -p${rootpasswd} -e "CREATE USER ${wpusername}@localhost IDENTIFIED BY '${wpuserpass}';" 2>/dev/null >> /tmp/lAMpWP.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Granting ALL privileges on ${wpdbname} to ${wpusername}!"
	mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${wpdbname}.* TO '${wpusername}'@'localhost';" 2>/dev/null >> /tmp/lAMpWP.log
	mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;" 2> /dev/null >> /tmp/lAMpWP.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)User Created!"
	echo "$(tput setaf 2)[+]$(tput setaf 7)WordPress database created successfully!"
	echo "<=== End Create WordPress Database ===>" >> /tmp/lAMpWP.log
	sleep 1s
	
}

function wpInstall() {

	echo "<=== Start WordPress Install ===>" >> /tmp/lAMpWP.log
		echo "$(tput setaf 6)[i]$(tput setaf 7)Installing Wordpress... "
		sleep 1s
		cd /var/www/html
		wget -c http://wordpress.org/latest.zip > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
		dnf install unzip > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
		echo "$(tput setaf 6)[i]$(tput setaf 7)Unzipping..."
		unzip latest.zip > /dev/null >> /tmp/lAMpWP.log
		sleep 1s
		echo "$(tput setaf 6)[i]$(tput setaf 7)Writing Permissions... "
		echo "$(tput setaf 6)[i]$(tput setaf 7)Removing zip file... "
		rm latest.zip
		sleep 1s
		cd /var/www/html/wordpress
		echo "$(tput setaf 6)[i]$(tput setaf 7)Writing php config... "
		mv wp-config-sample.php wp-config.php
		sed -i "s/database_name_here/${dbname}/" /var/www/html/wordpress/wp-config.php
		sed -i "s/username_here/${username}/" /var/www/html/wordpress/wp-config.php
		sed -i "s/password_here/${userpass}/" /var/www/html/wordpress/wp-config.php
		echo "$(tput setaf 6)[i]$(tput setaf 7)Writing Virtual Host..."
		touch /etc/httpd/conf/wp.conf
		cat <<EOF > /etc/httpd/conf/wp.conf
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
		sed -i 's/sname/${sname}/' /etc/httpd/conf/wp.conf
		sed -i 's/salias/${salias}/' /etc/httpd/conf/wp.conf
		systemctl reload httpd.service
		echo "$(tput setaf 2)[i]$(tput setaf 7)Virtual Host Created!"
		echo "<=== End WordPress Install ===>" >> /tmp/lAMpWP.log
		show_bye
		
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

	yumYES
	seLinux
	fireWall
	mySQL_install
	mySQL_secure
	mySQL_createDB
	httpd_Server
	phpInstall
	wpdb_create
	wpInstall
	show_bye
	
}

function cluster_skin() {

	yumYES
	seLinux
	fireWall
	mySQL_install
	mySQL_secure
	mySQL_createDB
	httpd_Server
	phpInstall
	wpInstall
	show_bye
	
}

function show_bye() {

	echo
	echo
	echo "*****************************************************"
	echo "$(tput setaf 2)[+]$(tput setaf 7)Installation Complete!"
	echo "$(tput setaf 2)[+]$(tput setaf 7)PHP - <IP>\server.com/info.php"
	echo "$(tput setaf 2)[+]$(tput setaf 7)WordPress - <IP>\server.com/wordpress"
	echo "$(tput setaf 1)[!]$(tput setaf 7)Firewall is disabled."
	echo "$(tput setaf 1)[!]$(tput setaf 7)SeLinux is disabled."
	echo "$(tput setaf 6)[i]$(tput setaf 7)You can view the installation log at /tmp/lAMpWP.log"
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

main