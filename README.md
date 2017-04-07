# PerfectWithSQL

Steps:
Download MySQL Workbench from the browser and install.
Also we need to set up the MySQL server -> download the MySQL server from the below link.
https://dev.mysql.com/downloads/file/?id=467574

Install the same. Then move to system preferences start the server from the extension
If not use the below terminal command to install
/usr/local/mysql/support-files/mysql.server start

//if permission error occurs use the below 

sudo /usr/local/mysql/support-files/mysql.server start

You will get the result as 
Starting MySQL
.. SUCCESS!


//
note: you may be able to install mysqlclient using your system-packager:

    brew install mysql

note: you may be able to install mysqlclient using your system-packager:

    brew install mysql


//below command to install brew

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

NOTE:-
After completion of this please do 
swift package update.
