apt-get update && apt-get install -y software-properties-common
add-apt-repository ppa:ubuntugis/ubuntugis-unstable

echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/  " >> /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

apt-get update
apt-get upgrade -y

apt-get -y update apt-get install -y gdal-bin libcurl4-openssl-dev libgdal-dev libgeos-dev libproj-dev libudunits2-dev make wget r-base-dev