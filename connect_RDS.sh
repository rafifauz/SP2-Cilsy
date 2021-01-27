sudo mysql -h database-1.ccybmikezpmc.ap-southeast-1.rds.amazonaws.com -u devopscilsy -p --password=1234567890
CREATE DATABASE IF NOT EXISTS dbsosmed;


#sudo mysql -h database-1.ccybmikezpmc.ap-southeast-1.rds.amazonaws.com -u devopscilsy -p dbsosmed < dump.sql
sudo mysql -h database-1.ccybmikezpmc.ap-southeast-1.rds.amazonaws.com -u devopscilsy -p dbsosmed --password=1234567890 < /var/www/web_baru/dump.sql
sudo sed -i 's/localhost/database-1.ccybmikezpmc.ap-southeast-1.rds.amazonaws.com/g' /var/www/web_baru/config.php
