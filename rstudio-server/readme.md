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

The machine can be launched as an EC2 instance through the EC2 launch panel. 
Select the following AMI (e.g. under "my AMI's" or search for it):

## Scripts 

Where we modified the AMI above, we used the scripts in this dir. 
