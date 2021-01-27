
echo "Jalankan program berikut di terminal linux anda untuk mendapat aws_access_key_id  & aws_secret_access_key"
echo 'cat ~/.aws/credentials | awk '"'"'{print $3}'"'"'| tr "\\n" '"':'"'| sed s/^.// | sed s/.$//'
#asli 
# cat ~/.aws/credentials | awk '{print $3}'| tr '\n' ':'| sed s/^.// | sed s/.$//

echo "----------------Masukan Data terlebih dahulu---------------"
#read -p "Enter IP Mysql: " IpMysql
#read -p "Enter User database: " UserDB
read -p "Enter aws_access_key_id:aws_secret_access_key  : " AccesKey

IpMysql=$(cat /home/ubuntu/Webserver-Nginx-Mysql-using-AWS-Loadbalancer/ip.txt | head -1 | tail -1)
UserDB=raxer

echo "----------------Installasi---------------"
sudo apt update
sudo apt install nginx -y
sudo apt install mysql-server -y
sudo apt install php-fpm -y
sudo apt-get install -y php-mysqli 
sudo apt-get install unzip


var1=$(dig +short myip.opendns.com @resolver1.opendns.com)
sudo mkdir /var/www/web_baru
echo "----------------Connect to S3---------------"
#cat .aws/credentials
sudo apt install s3fs awscli -y
sudo tee /home/ubuntu/.pass_S3 << EOL
$AccesKey
EOL
sudo chmod 600 /home/ubuntu/.pass_S3
sudo s3fs bucket-sp2 /var/www/web_baru -o passwd_file=/home/ubuntu/.pass_S3 -o url=https://s3.ap-southeast-1.amazonaws.com -ouid=1001,gid=1001,allow_other


echo "----------------Setting Nginx---------------"
sudo tee /etc/nginx/sites-available/web_baru <<EOL
server {
	listen 80;
	#bisa diganti dengan ip address localhostmu atau ip servermu, nanti kalau sudah ada domain diganti nama domainmu
	server_name $var1;
	#root adalah tempat dmn codingannya di masukkan index.html dll.
	root /var/www/web_baru;
	
	# Add index.php to the list if you are using PHP
	index index.php index.html index.htm ;

	location / {
	    try_files \$uri \$uri/ =404;
	}

	location ~ \.php$ {
	    include snippets/fastcgi-php.conf;
	    fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
	 }

	location ~ /\.ht {
	    deny all;
	}
}
EOL
sudo ln -s /etc/nginx/sites-available/web_baru /etc/nginx/sites-enabled
sudo unlink /etc/nginx/sites-enabled/default

echo "----------------Template WEB---------------"
cd /var/www/web_baru && sudo git clone https://github.com/rafifauz/SP1-Webserver-with-Nginx-Mysql.git && sudo mv mv SP1-Webserver-with-Nginx-Mysql/sosial-media-master/* ./ && sudo rm -rf ./SP1-Webserver-with-Nginx-Mysql/*

echo "----------------Review & Start Nginx---------------"
sudo nginx -t
#setelah update data harus dicek dengan restart nginx-t dulu sebelum restart nginx
sudo systemctl restart nginx

echo "----Cek apakah server_name sama dengan IP ini ----"
dig +short myip.opendns.com @resolver1.opendns.com
