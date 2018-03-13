## D&V R Studio Server Environment

[Demo URL](http://ec2-34-214-74-186.us-west-2.compute.amazonaws.com/)

## Environment

Modified version of [this Amazon Machine Image](http://www.louisaslett.com/RStudio_AMI/).

## Scripts 

Where we modified the AMI above, we used the scripts in this directory. 

## Data Transfer

The server has an interface to MTC's Box accounts through the [boxr](https://github.com/brendan-r/boxr) package. 

## Adding FileGDB Support

Rough example:

```
wget https://github.com/Esri/file-geodatabase-api/raw/master/FileGDB_API_1.5.1/FileGDB_API_1_5_1-64clang.zip
wget http://download.osgeo.org/gdal/2.2.3/gdal223.zip
unzip gdal223.zip
unzip FileGDB_API_1_5_1-64clang.zip
cd gdal223
./configure --with-fgdb=../FileGDB_API_1_5_1-64clang
make
make install
```
