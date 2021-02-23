#!/bin/bash
##################################################################
#			     LAMP + WordPress Installation for			     #
#				Ubuntu 18.04 | CentOS 8 | Debian 10   			 # 
#						********************
#				       Written by Gil Shwartz                    #       
#				      gilshwartzdjgs@gmail.com		             #
#				   www.linkedin.com/in/gilshwartz                #
##################################################################

clear

function main() {

	show_welcome
	choose_OS

}

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

function choose_OS {

	echo "Choose Operating System: "
	echo
	echo "$(tput setaf 5)1)$(tput setaf 7)Ubuntu Server 18.04 "
	echo "$(tput setaf 5)2)$(tput setaf 7)CentOS 8 "
	echo "$(tput setaf 5)3)$(tput setaf 7)Debian 10 "
	echo
	read os
	case $os in
		1) mainU ;;
		2) mainC ;;
		3) mainD ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
			choose_OS
			;;
	esac

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

# ================== Start Ubuntu Install ================== #

function mainU() {
		
		get_Uinfo
		
}

function get_Uinfo() {
	
	echo "$(tput setaf 2)[+]$(tput setaf 7)Starting installation for Ubuntu 18.04$(tput setaf 2)[+]$(tput setaf 7)"
	echo
	echo "$(tput setaf 3)[?]$(tput setaf 7)MySQL: "
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
	echo "$(tput setaf 3)[?]$(tput setaf 7)Domain: "
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter server name (ex: domain.com): "
	read sname
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter server alias (ex: www.domain.com): "
	read salias
	echo
	wp_Uinst
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

	inst_Uapache
	inst_UMySQL
	db_Ucreate
	inst_Uphp
	cfg_Uapache
	wpdb_Ucreate
	inst_Uwordpress
	show_bye
}

function cluster_skinU() {

	inst_Uapache
	inst_UMySQL
	db_Ucreate
	inst_Uphp
	cfg_Uapache
	inst_Uwordpress
	show_bye
}

function cluster_Uskin() {

	inst_Uapache
	inst_UMariaDB
	db_Ucreate
	inst_Uphp
	cfg_Uapache
	show_bye
}

function chk_Uinfo() {
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
		n) main_Ubuntu ;;
		N) main_Ubuntu ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
			main_Ubuntu
			;;
	esac
}

function inst_Uapache() {
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

function inst_UMySQL() {
	echo "<=== MySQL Install ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing MySql Database Server..."
	sleep 1s
	apt install mysql-server mysql-client -y > /dev/null 2> /dev/null >> /tmp/lamplog.log
	systemctl enable mysql > /dev/null 2> /dev/null >> /tmp/lamplog.log
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

}

function db_Ucreate() {
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

function inst_Uphp() {

	echo "<=== PHP7.3 Repo Install ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing PHP7.3 Repository..."
	sleep 1s
	yes '' | add-apt-repository ppa:ondrej/php > /dev/null >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Updating system..."
	apt-get update > /dev/null >> /tmp/lamplog.log
	echo "<=== PHP7.3 Repo Install Complete ===>\n" >> /tmp/lamplog.log
	echo "<=== PHP7.3 Install ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing PHP7.3..."
	apt install php7.3 php7.3-mysql libapache2-mod-php7.3 -y 2> /dev/null >> /tmp/lamplog.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)PHP7.3 installed successfully!"
	echo "<=== PHP7.3 Install Complete ===>" >> /tmp/lamplog.log
	
}

function cfg_Uapache() { 
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

function wp_Uinst() {
	echo "$(tput setaf 3)[?]$(tput setaf 7)WordPress: "
	echo "$(tput setaf 3)[?]$(tput setaf 7)Would you like to install WordPress? [Y/n] "
	read wp
	case $wp in
		y) wp_Udatabase ;;
		Y) wp_Udatabase ;;
		n) cluster_Uskin ;;
		N) cluster_Uskin ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
			wp_Uinst
			;;
	esac
}

function wp_Udatabase() {
	echo
	echo "$(tput setaf 3)[?]$(tput setaf 7)Would you like to install a WordPress database? [Y/n] "
	echo "$(tput setaf 1)[i]$(tput setaf 7)'n' will install WordPress on the initial database"
	read wpdb
	case $wpdb in
		y) wpUdb ;;
		Y) wpUdb ;;
		n) cluster_skinU ;;
		N) cluster_skinU ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
			wp_Udatabase
			;;
	esac
}

function wpdb_Ucreate() {
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

function wpUdb() {
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter database name (example: database1, wordpress): "
	read wpdbname
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter DB user: "
	read wpusername
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter DB User Password: "
	read -s wpuserpass
	echo
	chk_Uinfo
}

function inst_Uwordpress() {

	echo "<=== Start WordPress Install ===>\n" >> /tmp/lamplog.log
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
	cat << EOF > /etc/apache2/sites-available/wp.conf
<VirtualHost *:80>

	ServerName ${sname}
	ServerAlias ${salias}
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

	sed -i "s/sname/${sname}/" /etc/apache2/sites-available/wp.conf
	sed -i "s/salias/${salias}/" /etc/apache2/sites-available/wp.conf
	echo "$(tput setaf 6)[i]$(tput setaf 7)Creating syslink... "
	sleep 1s
	ln -s /etc/apache2/sites-available/wp.conf /etc/apache2/sites-enabled/wp.conf
	echo "<=== End WordPress Install ===>" >> /tmp/lamplog.log
	show_bye
}

# ================== End of Ubuntu Install ================== #

# ================= Start CentOS 8 Install ================= #

function mainC() {

	get_Cinfo

}

function get_Cinfo() {
	
	echo "$(tput setaf 2)[+]$(tput setaf 7)Starting installation for CentOS 8$(tput setaf 2)[+]$(tput setaf 7)"
	echo
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
	wpInstallC
	
}

function wpInstallC() {

	echo "$(tput setaf 3)[?]$(tput setaf 7)Would you like to install WordPress? [Y/n] "
	read wp
	case $wp in
	
		y) wp_MakeDatabaseC ;;
		Y) wp_MakeDatabaseC ;;
		n) cluster_skinC ;;
		N) cluster_skinC ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
			wpInstallC
			;;
	esac
	
}

function wp_MakeDatabaseC() {

	echo
	echo "$(tput setaf 3)[?]$(tput setaf 7)Would you like to install a WordPress database? [Y/n] "
	echo "$(tput setaf 1)[i]$(tput setaf 7)'n' will install WordPress on the initial database"
	read wpdb
	case $wpdb in
		y) wpCdb ;;
		Y) wpCdb ;;
		n) cluster_WPskinC ;;
		N) cluster_WPskinC ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
			wp_MakeDatabaseC
			;;
	esac
	
}

function wpCdb() {

	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter database name (example: database1, wordpress): "
	read wpdbname
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter DB user: "
	read wpusername
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter DB User Password: "
	read -s wpuserpass
	echo
	chk_Cinfo
	
}

function chk_Cinfo() {

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
		y) runC ;;
		Y) runC ;;
		n) mainC ;;
		N) mainC ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
			mainC
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

function mySQL_Cinstall() {

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

function mySQL_Csecure() {

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

function mySQL_CcreateDB() {

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

function httpd_CServer() {

	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing httpd server..."
	yum -y install httpd > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	systemctl start httpd
	systemctl enable httpd > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	systemctl status httpd --no-pager > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	netstat -ntulp | grep 80 > /dev/null 2> /dev/null >> /tmp/lAMpWP.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)httpd installed successfully!"
}

function phpCInstall() {

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

function wpdb_Ccreate() {

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

function wpCInstall() {

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

function runC() {
	
	case $wp in 
		y) clusterC ;;
		Y) clusterC ;;
		n) exit ;;
		N) exit ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!" ;;
			
	esac	
}

function clusterC() {

	yumYES
	seLinux
	fireWall
	mySQL_Cinstall
	mySQL_Csecure
	mySQL_CcreateDB
	httpd_CServer
	phpCInstall
	wpdb_Ccreate
	wpCInstall
	show_bye
	
}

function cluster_WPskinC() {

	yumYES
	seLinux
	fireWall
	mySQL_Cinstall
	mySQL_Csecure
	mySQL_CcreateDB
	httpd_CServer
	phpCInstall
	wpCInstall
	show_bye
	
}

function cluster_skinC() {

	yumYES
	seLinux
	fireWall
	mySQL_Cinstall
	mySQL_Csecure
	mySQL_CcreateDB
	httpd_CServer
	phpCInstall
	show_bye
	
}

# ================= END CentOS 8 Install ================= #

# ================= Start Debian 10 Install ================= #

function mainD() {
	
	get_Dinfo
	
}

function get_Dinfo() {
	
	echo "$(tput setaf 2)[+]$(tput setaf 7)Starting installation for Debian 10$(tput setaf 2)[+]$(tput setaf 7)"
	echo
	echo "$(tput setaf 3)[?]$(tput setaf 7)MariaDB: "
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter MariaDB root password: "
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
	echo "$(tput setaf 3)[?]$(tput setaf 7)Domain: "
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter server name (ex: domain.com): "
	read sname
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter server alias (ex: www.domain.com): "
	read salias
	echo
	wp_Dinst
}

function runD() {
	
	case $wp in 
		y) clusterD ;;
		Y) clusterD ;;
		n) exit ;;
		N) exit ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!" ;;
			
	esac	
}

function clusterD() {

	inst_Dapache
	inst_DmariaDB
	db_Dcreate
	inst_Dphp
	cfg_Dapache
	wpdb_Dcreate
	inst_Dwordpress
	show_bye
}

function cluster_Dskin() {

	inst_Dapache
	inst_DMariaDB
	db_Dcreate
	inst_Dphp
	cfg_Dapache
	inst_Dwordpress
	show_bye
}

function cluster_skinD() {

	inst_Dapache
	inst_DMariaDB
	db_Dcreate
	inst_Dphp
	cfg_Dapache
	show_bye
}

function chk_Dinfo() {
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
		y) runD ;;
		Y) runD ;;
		n) mainD ;;
		N) mainD ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
			mainD
			;;
	esac
}

function inst_Dapache() {
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

function inst_DmariaDB() {
	echo "<=== MariaDB Install ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing MariaDB Database Server..."
	apt install mariadb-server mariadb-client -y > /dev/null 2> /dev/null >> /tmp/lamplog.log
	systemctl start mariadb
	systemctl enable mariadb > /dev/null 2> /dev/null >> /tmp/lamplog.log
	echo "<=== MariaDB Secure Install ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Securing database... "
	mysql -u root <<EOF
		ALTER USER 'root'@'localhost' IDENTIFIED BY '$rootpasswd';
		DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
		DELETE FROM mysql.user WHERE User='';
		DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
		FLUSH PRIVILEGES;
EOF
	echo "$(tput setaf 2)[+]$(tput setaf 7)MariaDB installed successfully!"
	echo "<=== MariaDB Install Complete ===>" >> /tmp/lamplog.log
	sleep 1s
}

function db_Dcreate() {
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

function inst_Dphp() {
	echo "<=== PHP7.3 Repo Install ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing PHP7.3 Repository..."
	sleep 1s
	apt install -y curl wget gnupg2 ca-certificates lsb-release apt-transport-https 2> /dev/null >> /tmp/lamplog.log
	wget https://packages.sury.org/php/apt.gpg > /dev/null 2> /dev/null >> /tmp/lamplog.log
	apt-key add apt.gpg > /dev/null 2> /dev/null >> /tmp/lamplog.log
	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php7.list > /dev/null 2> /dev/null >> /tmp/lamplog.log
	apt update > /dev/null 2> /dev/null >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Updating system..."
	sleep 1s
	echo "<=== PHP7.3 Repo Install Complete ===>\n" >> /tmp/lamplog.log
	echo "<=== PHP7.3 Install ===>" >> /tmp/lamplog.log
	echo "$(tput setaf 6)[i]$(tput setaf 7)Installing PHP7.3..."
	sleep 1s
	apt install php7.3 php7.3-mysql libapache2-mod-php7.3 php7.3-common -y 2> /dev/null >> /tmp/lamplog.log
	echo "$(tput setaf 2)[+]$(tput setaf 7)PHP7.3 installed successfully!"
	sleep 1s
	echo "<=== PHP7.3 Install Complete ===>" >> /tmp/lamplog.log
}

function cfg_Dapache() { 
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

function wp_Dinst() {
	echo "$(tput setaf 3)[?]$(tput setaf 7)WordPress: "
	echo "$(tput setaf 3)[?]$(tput setaf 7)Would you like to install WordPress? [Y/n] "
	read wp
	case $wp in
		y) wp_Ddatabase ;;
		Y) wp_Ddatabase ;;
		n) cluster_skinD ;;
		N) cluster_skinD ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
			wp_Dinst
			;;
	esac
}

function wp_Ddatabase() {
	echo
	echo "$(tput setaf 3)[?]$(tput setaf 7)Would you like to install a WordPress database? [Y/n] "
	echo "$(tput setaf 1)[i]$(tput setaf 7)'n' will install WordPress on the initial database"
	read wpdb
	case $wpdb in
		y) wpDdb ;;
		Y) wpDdb ;;
		n) cluster_Dskin ;;
		N) cluster_Dskin ;;
		*) echo "$(tput setaf 1)[!]$(tput setaf 7)Wrong Input!"
			wp_Ddatabase
			;;
	esac
}

function wpdb_Dcreate() {
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

function wpDdb() {
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter database name (example: database1, wordpress): "
	read wpdbname
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter DB user: "
	read wpusername
	echo
	echo "$(tput setaf 5)[i]$(tput setaf 7)Enter DB User Password: "
	read -s wpuserpass
	echo
	chk_Dinfo
}

function inst_Dwordpress() {
	echo "<=== Start WordPress Install ===>\n" >> /tmp/lamplog.log
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
	cat << EOF > /etc/apache2/sites-available/wp.conf
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

	sed -i "s/sname/${sname}/" /etc/apache2/sites-available/wp.conf
	sed -i "s/salias/${salias}/" /etc/apache2/sites-available/wp.conf
	echo "$(tput setaf 6)[i]$(tput setaf 7)Creating syslink... "
	sleep 1s
	ln -s /etc/apache2/sites-available/wp.conf /etc/apache2/sites-enabled/wp.conf
	echo "<=== End WordPress Install ===>" >> /tmp/lamplog.log
	show_bye

}

# ================= END Debian 10 Install ================= #

if (( $EUID != 0 )); then
	echo "#######################################################"
    echo "$(tput setaf 1)[!]$(tput setaf 7)This script requires root privileges in order"
	echo "$(tput setaf 1)[!]$(tput setaf 7)to be able to write to /var/www/html/"
	echo "$(tput setaf 1)[!]$(tput setaf 7)Please run as root."
    echo "#######################################################"
	exit
	
fi

main