#/bin/bash
#Install nextcloud

if [[ "$EUID" -ne 0 ]]; then
	echo "Please run as root";
	exit;
fi

if [[ $# -ne 1 ]]; then
	echo "Insert Name User";
	exit;
fi

USER=$1
URL="https://download.nextcloud.com/server/releases/nextcloud-16.0.1.zip";
ARCHIVE="${URL:47}";
#SQLPATH="/home/bros/nextcloud.sql";
	
if [[ `cat /etc/passwd | grep $USER` ]]; then
	echo "User $1 already exist";
else
	/usr/sbin/adduser --disabled-login $1;
fi

dpkg -s gnupg;

if [[ $? -ne 0 ]]; then
	apt-get install gnupg;
fi

#Install PHP
if [[ `wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -` ]]; then
	echo "deb https://packages.sury.org/php/ `lsb_release -cs` main" | sudo tee /etc/apt/sources.list.d/php.list;
else
	exit;
fi

apt-get update && apt-get install -y php php-gd php-curl php-zip php-xml php-mbstring;

if [[ $? -ne 0 ]]; then
	echo "Problem install php";
	exit;
fi

#Install Apache2
apt-get install -y apache2 libapache2-mod-php;
if [[ $? -ne 0 ]]; then
	echo "Problem install apache";
	exit;
fi

#Install MySQL

apt-get install -y default-mysql-server php-mysql;
if [[ $? -ne 0 ]]; then
	echo "Problem install MySQL";
	exit;
fi;

#Install NextCloud

cd /tmp;

if [[ `wget -S --spider $URL  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
	echo "File found $URL";
	wget $URL;
else
	echo "File Not found Please set correct URL";
	exit;
fi;

#Extract archivie

cd /var/www/html;

unzip /tmp/$ARCHIVE;
chown -R www-data:www-data nextcloud;
chmod -R 755 nextcloud;

#Remove archive file
rm -f /tmp/$ARCHIVE;

#Create MySQL Database

#mysql -u user -p < $SQLPATH;