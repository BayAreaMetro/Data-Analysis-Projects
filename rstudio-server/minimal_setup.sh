apt-get update && apt-get install -y software-properties-common
add-apt-repository ppa:ubuntugis/ubuntugis-unstable

echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/  " >> /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

apt-get update
apt-get upgrade -y

#install gdal with filegdb support
wget https://github.com/Esri/file-geodatabase-api/raw/master/FileGDB_API_1.5/FileGDB_API_1_5_64gcc51.tar.gz
wget http://download.osgeo.org/gdal/2.2.3/gdal223.zip
unzip unzip gdal223.zip
tar xzvf FileGDB_API_1_5_64gcc51.tar.gz
cd FileGDB_API-64gcc51/
export LD_LIBRARY_PATH=/home/ubuntu/src/FileGDB_API-64gcc51/lib
sudo cp lib/*.so /usr/local/lib
cd gdal-2.2.3/
./configure --with-fgdb=/home/ubuntu/src/FileGDB_API-64gcc51
make
sudo make install

apt-get -y update apt-get install -y libcurl4-openssl-dev libgeos-dev libproj-dev libudunits2-dev make wget r-base-dev
