#!/bin/bash

### Set default parameters
action=$1
domain=$2
port=$3
rootDir=$4
owner=$(who am i | awk '{print $1}')
sitesEnable='/etc/nginx/sites-enabled/'

if [ "$domain" == "" ] || [ "$port" == ""] || [ "rootDir" == "" ]; then
	echo $"You have to enter 4 arguments"
	echo $"Example : virtualhost create domain.dev 1337 /home/user/sites/coucou"
	exit 1;
fi

if [ "$(whoami)" != 'root' ]; then
	echo $"You have no permission to run $0 as non-root user. Use sudo"
	exit 1;
fi

if [ "$action" != 'create' ] && [ "$action" != 'delete' ]; then
	echo $"You need to prompt for action (create or delete) -- Lower-case only"
	exit 1;
fi

while [ "$domain" == "" ]
do
	echo -e $"Please provide domain. e.g.dev,staging"
	read domain
done

if [ "$action" == 'create' ]; then
	### check if domain already exists
	if [ -e $sitesEnable$domain ]; then
		echo -e $"This domain already exists.\nPlease Try Another one"
		exit;
	fi

	### check if directory exists or not
	if ! [ -d $rootDir ]; then
		### create the directory
		mkdir $rootDir
		### give permission to root dir
		chmod 755 $rootDir
		### write test file in the new domain dir
		if ! echo "<?php echo phpinfo(); ?>" > $rootDir/phpinfo.php
			then
				echo $"ERROR: Not able to write in file /$rootDir/phpinfo.php. Please check permissions."
				exit;
		else
				echo $"Added content to $rootDir/phpinfo.php."
		fi
	fi

	### create virtual host rules file
	if ! echo "server {
		listen 80;
		listen $port;
		server_name $domain www.$domain;
		root $rootDir/web;

		client_max_body_size 1152M;

		# strip app.php/ prefix if it is present
		rewrite ^/app_dev.php/?(.*)$ /$1 permanent;

		#    Do not log access to robots.txt, to keep the logs cleaner
		location = /robots.txt { access_log off; log_not_found off; }

		#    Do not log access to the favicon, to keep the logs cleaner
		location = /favicon.ico { access_log off; log_not_found off; }

		location @rewriteapp {
			rewrite ^(.*)$ /app_dev.php/$1 last;
		}

		location / {
			index app_dev.php index.php;
			try_files \$uri @rewriteapp;
		}

		# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
		location ~ ^/(.+).php(/|$) {
			fastcgi_pass 127.0.0.1:9000;
			fastcgi_split_path_info ^(.+.php)(/.*)$;
			include fastcgi_params;
			fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
			fastcgi_param HTTPS off; #on;
			fastcgi_read_timeout 300;
		}

	}" > $sitesEnable$domain
	then
		echo -e $"There is an ERROR create $domain file"
		exit;
	else
		echo -e $"\nNew Virtual Host Created\n"
	fi

	### Add domain in /etc/hosts
	if ! echo "127.0.0.1	$domain	// $port" >> /etc/hosts
		then
			echo $"ERROR: Not able write in /etc/hosts"
			exit;
	else
			echo -e $"Host added to /etc/hosts file \n"
	fi

	chown -R florian:users $rootDir

	### restart Nginx
	systemctl restart nginx

	### show the finished message
	echo -e $"Complete! \nYou now have a new Virtual Host \nYour new host is: http://$domain \nAnd its located at $rootDir"
	exit;
else
	### check whether domain already exists
	if ! [ -e $sitesEnable$domain ]; then
		echo -e $"This domain doesn't exist.\nPlease try another one"
		exit;
	else
		### Delete domain in /etc/hosts
		newhost=${domain//./\\.}
		sed -i "/$newhost/d" /etc/hosts

		### restart Nginx
		systemctl restart nginx

		### Delete virtual host rules files
		rm $sitesEnable$domain
	fi

	### check if directory exists or not
	if [ -d $rootDir ]; then
		echo -e $"Delete host root directory ? (y/n)"
		read deldir

		if [ "$deldir" == 'y' -o "$deldir" == 'Y' ]; then
			### Delete the directory
			rm -rf $rootDir
			echo -e $"Directory deleted"
		else
			echo -e $"Host directory conserved"
		fi
	else
		echo -e $"Host directory not found. Ignored"
	fi

	### show the finished message
	echo -e $"Complete!\nYou just removed Virtual Host $domain"
	exit 0;
fi
