#!/bin/bash

<<comment
 An Automated script for the ansible controller machine & Ansible playbook run.
 By Gil Shwartz @2022
 
 Stages:
	1. Update OS packages
	2. Installing Ansible's original package
	3. Upgrading Ansible
	4. Installing Ansible Community General Collection
	5. Creating hosts file
	8. Add host key checking defaults in under /etc/ansible/ansible.cfg
	9. Run ansible playbook
comment

# Show Help Information
function get_help () {
	clear
	echo "
███████╗██████╗░███████╗░██████╗██╗░░██╗
██╔════╝██╔══██╗██╔════╝██╔════╝██║░░██║
█████╗░░██████╔╝█████╗░░╚█████╗░███████║
██╔══╝░░██╔══██╗██╔══╝░░░╚═══██╗██╔══██║
██║░░░░░██║░░██║███████╗██████╔╝██║░░██║
╚═╝░░░░░╚═╝░░╚═╝╚══════╝╚═════╝░╚═╝░░╚═╝"
	echo "##|$(tput setaf 2)Nodes$(tput setaf 7) = number of endpoints to manage"
	echo "##============================================="
	echo "##|$(tput setaf 2)VM Username$(tput setaf 7) = the username for the nodes"
	echo "##============================================="
	echo "##|$(tput setaf 2)Starting IP Address$(tput setaf 7) = the IP address for the first node.- the script will then"
	echo "##|create a nodes list that ends with the number of nodes passed earlier."
	echo "##|$(tput setaf 3)Example$(tput setaf 7): ./fresh.sh -n 2 -s 192.168.100.11 will create a hosts file that will look like:"
	echo "##[webservers]"
	echo "##192.168.100.11"
	echo "##192.168.100.12"
	echo "##============================================="
	echo "##|$(tput setaf 2)VM Password$(tput setaf 7) = password for the nodes"
	echo "##============================================="
	echo "##|$(tput setaf 2)Controller root password$(tput setaf 7) = password for the fresh controller so the script"
	echo "##|could run updates and installs"
	echo "##============================================="
	echo "##|$(tput setaf 2)env filename$(tput setaf 7) = name of the env file you copied to this machine. (Example: 'env-prod')"
	echo "##$(tput setaf 3)***Make sure the env file is NOT HIDDEN (no . in the filename).$(tput setaf 7)"
	echo "##============================================="
	echo "##|$(tput setaf 2)playbook filename$(tput setaf 7) = name of the playbook file you copied to this machine ('Example: playbook.yml')"
	echo "##============================================="
	echo "##$(tput setaf 3)FLAGS & ARGUMENTS$(tput setaf 7)    ##"				
	echo "##$(tput setaf 6)=-=-=-=-=-=-=-=-=-=-=-=$(tput setaf 7)"
	echo "-h, --help               Show Script information and usage details"
	echo "-n, --nodes              Number of remote machines."
	echo "-e, --env                Name of the env file (Example: 'env-production')."
	echo "-p, --playbook           Name of the playbook file (Example: 'playbook.yml')."
	echo "-u, --user               Username to be used on the remote machines."
	echo "-i, --ip-address         Starting IP Address of the remote machines."
	echo "-s. --skip               Skip initial updates and packages installs."
	echo ""
	echo "##|$(tput setaf 3)If no arguments passed then the script will prompt for the information when executing.$(tput setaf 7)"
	echo "##|$(tput setaf 3)Usage Examples:$(tput setaf 7)"
	echo "##|./fresh -n <N of Nodes> -e <envfile> -p <playbookfile> -s <startingipaddress> -u <vmusername>"
	
	
	if [ "$1" == "error" ]
	then
		exit 1
		
	else
		exit 0
	
	fi
}

# Get env filename & validate it exists
function get_env () {
	# ENV filename
	while :
	do
		echo "env filename (Example: 'env-prod'): "
		read ENVFILENAME
			
		if ! [ -f ./"$ENVFILENAME" ]
		then
			echo "[$(tput setaf 1)!$(tput setaf 7)]No such file '$(tput setaf 1)$ENVFILENAME'$(tput setaf 7)"
			continue
			
		else
			echo "$(tput setaf 2)env file: OK! $(tput setaf 7)"
			break
			
		fi
	
	done

}

# Get playbook filename & validate it exists
function get_playbook () {
	# Playbook filename
	while :
	do
		echo "playbook filename (Example: 'playbook.yml'): "
		read PLAY
		
		if ! [ -f ./"$PLAY" ]
		then
			echo "[$(tput setaf 1)!$(tput setaf 7)]No such file '$(tput setaf 1)$PLAY'$(tput setaf 7)"
			continue
			
		else
			echo "$(tput setaf 2)playbook file: OK! $(tput setaf 7)"
			break
			
		fi
	
	done

}

# Get Number of Nodes
function get_nodes () {
	while :
	do
		echo "Number of nodes: "
		read NODES
		
		if ! [[ $NODES -gt 0 ]]
		then
			echo "[$(tput setaf 1)!$(tput setaf 7)]Must be at least 2 nodes"
			continue
		
		fi
		
		if [[ $NODES -eq 1 ]]
		then
			echo "[$(tput setaf 1)!$(tput setaf 7)]Must be at least 2 nodes"
			continue
		
		else
			break
		
		fi
	
	done
}

# Get Starting IP Address
function get_ip () {
	while :
	do
		echo "Staring IP Address (Example: 10.0.0.2 | 192.168.1.11): "
		read SUBNET
		
		if [[ $SUBNET =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
		then
			echo "[$(tput setaf 1)!$(tput setaf 7)]Wrong IP Address. (Example IP: 192.168.100.11 | 192.168.100.5 | 192.168.100.100)"
			continue
		
		else
			break
			
		fi
		
	done
	
	NETWORK="${SUBNET##*.}"
	INDEX=`echo $SUBNET | cut -d"." -f1-3`
	COUNT=$(( ($NETWORK + $NODES - 1) )) 

}

# Get user inputs 
function get_input () {
	# Number of endpoints
	if [ ${#NODES} -eq 0 ]
	then
		get_nodes
	
	fi

	# IP Address
	if [ ${#SUBNET} -eq 0 ]
	then
		get_ip
	
	fi
	
	# Cluster VMs Username
	if [ ${#USER} -eq 0 ]
	then
		echo "VM Username:"
		read USER	
	
	fi
	
	# Get env filename
	if [ ${#ENVFILENAME} -eq 0 ]
	then
		get_env
	
	fi

	# Get playbook filename
	if [ ${#PLAY} -eq 0 ]
	then
		get_playbook
	
	fi
	
	# Cluster VNs Password
	read -s -p "VM Password: " PASS
	echo ""
	
	# Controller Root Password
	read -s -p "Controller root password: " ROOT
	echo ""
	
}

# Update & Upgrade
function update_upgrade () {
	echo ""
	echo ""
	echo "$(tput setaf 3)========================================================================$(tput setaf 7)"
	echo "Installing OS Updates & Upgrades"
	echo "$(tput setaf 3)========================================================================$(tput setaf 7)"
	echo $ROOT | sudo -S apt update && sudo apt upgrade -y;
}

# Install Ansible
function ans_install () {
	echo ""
	echo ""
	echo "$(tput setaf 3)========================================================================$(tput setaf 7)"
	echo "Installing Ansible"
	echo "$(tput setaf 3)========================================================================$(tput setaf 7)"
	echo $ROOT | sudo apt install ansible -y
}

# Upgrade Ansible version, Update & Upgrade packages
function upgrade_ansible () {
	echo ""
	echo ""
	echo "$(tput setaf 3)========================================================================$(tput setaf 7)"
	echo "Upgrading Ansible"
	echo "$(tput setaf 3)========================================================================$(tput setaf 7)"
	echo $ROOT | sudo apt-add-repository ppa:ansible/ansible
	echo $ROOT | sudo apt update
	echo $ROOT | sudo -S apt upgrade -y
}

# Install Ansible Community Modules
function install_ansible_collection () {
	echo ""
	echo ""
	echo "$(tput setaf 3)========================================================================$(tput setaf 7)"
	echo "Installing Andible Community General Collection"
	echo "$(tput setaf 3)========================================================================$(tput setaf 7)"
	ansible-galaxy collection install community.general
}

# Create hosts file under ~/
function create_hosts () {
	echo "$(tput setaf 3)========================================================================$(tput setaf 7)"
	echo "Creating hosts file in /etc/ansible/hosts "
	echo "$(tput setaf 3)========================================================================$(tput setaf 7)"
	
	echo "$PASS" | sudo -S rm /etc/ansible/hosts
	touch ./hosts
	
	seq -f "$INDEX.%g" $NETWORK $COUNT >> ./hostss
	sed -i "s/$/ $PATTERN/" ./hostss
	sed -i '1s/^/[webservers]\n/' ./hostss
	echo "" >> ./hostss
	echo "[webservers:vars]" >> ./hostss
	echo "ansible_connection=ssh" >> ./hostss
	echo "ansible_ssh_user=$USER" >> ./hostss
	echo "ansible_ssh_pass=$PASS" >> ./hostss
	echo "ansible_sudo_pass=$ROOT" >> ./hostss
	
	mv ./hostss ./hosts
	sudo mv ./hosts /etc/ansible/hosts

}

# Configure Ansible to connect with Username & Password
function define_login_method () {
	# Define Login with User&Password
	echo "$(tput setaf 3)========================================================================$(tput setaf 7)"
	echo "Adding host key checking to /etc/ansible/ansible.cfg"
	echo "$(tput setaf 3)========================================================================$(tput setaf 7)"
	
	sudo rm /etc/ansible/ansible.cfg
	touch ~/ansible.cfg
	sudo echo "[defaults]" >> ~/ansible.cfg
	sudo echo "host_key_checking = false" >> ~/ansible.cfg
	
	# Overwrite the original /etc/ansible/ansible.cfg
	sudo mv ~/ansible.cfg /etc/ansible/ansible.cfg
}

# Run playbook
function run_playbook () {
	# Run Ansible playbook on Staging enviroment
	ansible-playbook "$PLAY" --extra-vars="env=$ENVFILENAME"

}

# Run the post updates & installs stages of the script
function play_skipped () {
	# Create hosts file
	create_hosts
	
	# Enable login with username & password
	define_login_method
	
	# Run ansible playbook.
	run_playbook
}

# Run Updates & Installs before running the playbook
function play_full () {
	# Update controller's OS packages
	update_upgrade

	# Installing Ansible
	ans_install

	# Upgrade Ansible
	upgrade_ansible

	# Install Ansible Community General Collection
	install_ansible_collection

	# Create hosts file
	create_hosts

	# Define Login Method
	define_login_method

	# Run ansible playbook.
	run_playbook

}

# Look for arguments | flags
while [[ $# -gt 0 ]]
do
	case "$1" in
		-h|--help)
			get_help
			shift
			shift
			;;
		
		-n|--nodes)
			NODES="$2"
			shift
			shift
			;;
			
		-e|--env)
			ENVFILENAME="$2"
			if ! [ -f ./"$ENVFILENAME" ]
			then
				echo "[$(tput setaf 1)!$(tput setaf 7)]No such file '$(tput setaf 1)$ENVFILENAME'$(tput setaf 7)"
				exit 1
			fi
			shift
			shift
			;;
		
		-p|--playbook)
			PLAY="$2"
			if ! [ -f ./"$PLAY" ]
			then
				echo "[$(tput setaf 1)!$(tput setaf 7)]No such file '$(tput setaf 1)$PLAY'$(tput setaf 7)"
				exit 1
			fi
			shift
			shift
			;;
		
		-u|--user)
			USER="$2"
			shift
			shift
			;;
		
		-i|--ip-address)
			SUBNET="$2"
						
			NETWORK="${SUBNET##*.}"
			INDEX=`echo $SUBNET | cut -d"." -f1-3`
			COUNT=$(( ($NETWORK + $NODES - 1) )) 
			shift
			shift
			;;
		
		-s|--skip)
			skip="yes"
			shift
			shift
			;;
		
		*)
			break
			
	esac
done

# If not arguments passed then the script will ask for the information
# The get_input function checks if any input was passed from the cli and if so
# it skips the variable.
get_input

# Print summerization before executing
echo ""
echo "========================================================"
echo "$(tput setaf 3)Nodes$(tput setaf 7): $NODES"
echo "$(tput setaf 3)ENV File$(tput setaf 7): $ENVFILENAME"	
echo "$(tput setaf 3)Playbook file$(tput setaf 7): $PLAY"
echo "$(tput setaf 3)VM Username$(tput setaf 7): $USER"
echo "$(tput setaf 3)Starting IP Address$(tput setaf 7): $SUBNET"
echo "$(tput setaf 3)END IP Address$(tput setaf 7): $INDEX.$COUNT"
echo "========================================================"
echo ""
echo "Continue? [Y/n]: " 
read CON

counter=0
while :
do
	if [[ "CON" == "Y" ]] || [[ "$CON" == "y" ]]
	then
		echo "
		███████╗██████╗░███████╗░██████╗██╗░░██╗
		██╔════╝██╔══██╗██╔════╝██╔════╝██║░░██║
		█████╗░░██████╔╝█████╗░░╚█████╗░███████║
		██╔══╝░░██╔══██╗██╔══╝░░░╚═══██╗██╔══██║
		██║░░░░░██║░░██║███████╗██████╔╝██║░░██║
		╚═╝░░░░░╚═╝░░╚═╝╚══════╝╚═════╝░╚═╝░░╚═╝"
		
		if [[ "$skip" == "yes" ]] || [[ "$skip" == "YES" ]]
		then
			echo "$(tput setaf 2)========================================================$(tput setaf 7)"
			echo "Running the short version"
			echo "$(tput setaf 2)========================================================$(tput setaf 7)"
			echo ""
			play_skipped
		
		else
			echo "$(tput setaf 2)========================================================$(tput setaf 7)"
			echo "Running everything"
			echo "$(tput setaf 2)========================================================$(tput setaf 7)"
			echo ""
			play_full
		
		fi
			
		break

	elif [[ "CON" == "N" ]] || [[ "$CON" == "n" ]]
	then
		echo "Exiting..."
		exit 1
		
	
	else
		echo "[$(tput setaf 1)!$(tput setaf 7)]Wrong Input."
		counter++
		
		if [ $counter -eq 3 ]
		then
			"[$(tput setaf 1)!$(tput setaf 7)]That's enough... cya!"
			exit 1
		
		fi
		
		continue
		
	fi
	
done

# Removing the unsecured env file
echo "$(tput setaf 3)========================================================================$(tput setaf 7)"
echo "Removing unsecured files"
echo "$(tput setaf 3)========================================================================$(tput setaf 7)"
if [ -f "$ENVFILENAME" ]
then
	rm "$ENVFILENAME"

fi

echo "$(tput setaf 2)FIN!$(tput setaf 7)"