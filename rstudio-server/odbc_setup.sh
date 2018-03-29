# borrowed from http://digitalitility.com/tutori-alitility/postgresql/odbc-setup-on-ubuntu-for-postgresql/
sudo apt-get install unixodbc-bin unixodbc
#ODBC drivers for PostgreSQL:
sudo apt-get install odbc-postgresql
#Apply the template file provided to setup driver entries:
sudo odbcinst -i -d -f /usr/share/psqlodbc/odbcinst.ini.template
#Setup the a sample DSN
sudo odbcinst -i -s -l  -n sample-dsn-name -f /usr/share/doc/odbc-postgresql/examples/odbc.ini.template
#Now modify /etc/odbc.ini according to your DB:
sudo nano /etc/odbc.ini
sudo Rscript install_db_packages.R
