# MTC R Studio Server

## Introduction

R studio Server is an Open Source web application that delivers [R Studio](https://www.rstudio.com/products/rstudio/) in a browser window. 

## Background

We modified [this Amazon Machine Image](http://www.louisaslett.com/RStudio_AMI/) to add support for database adapters, and multiple users.

Highlights:

- Common Open Database Connectivity (odbc) drivers and packages installed
- pre-configured to connect to MTC databases through using the "Connections" pane. 
- ESRI FileGDB support through the Geospatial Data Abstraction Library
- Box support through the boxr package. 

The AMI is private to DV staff and is in the US-West-Oregon region: [ami-95b0dfed](https://console.aws.amazon.com/ec2/home?region=us-west-2#launchAmi=ami-95b0dfed)

## Scripts 

Where we modified the AMI above, we used the scripts in this dir. 

These are rough notes for setting up the server. We expect a user to ssh in and follow along with them as a rough guide. 

```
gdal_filegdb_setup.sh
odbc_setup.sh
install_db_packages.R
```
