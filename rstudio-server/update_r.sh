# copied parts much of "Building a new RStudio Server AMI"
# at https://gist.github.com/jaeddy/5d564005c39aa608b4c28850e03fcb45
# by www.github.com/jaeddy

# turn the server off:
sudo rstudio-server offline
sudo rstudio-server force-suspend-all

#Change the CRAN mirror and update R install using the commands below (taken from this post: 
codename=$(lsb_release -c -s)
echo "deb http://cran.fhcrc.org/bin/linux/ubuntu $codename/" | sudo tee -a /etc/apt/sources.list > /dev/null
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo add-apt-repository ppa:marutter/rdev
sudo apt-get update
sudo apt-get upgrade

#turn the server back on
sudo rstudio-server online

#install dependencies for R packages
sudo apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev && \
    sudo apt-get clean && \
    sudo apt-get purge && \
    sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
