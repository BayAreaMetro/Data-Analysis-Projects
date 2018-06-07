# Goal

Document data processing scripts and packages deployed to AWS Lambda. 

<!-- MarkdownTOC autolink="true" -->

- [Deployment-Packages](#deployment-packages)
	- [Python-2.7](#python-27)
		- [mssql-to-csv](#mssql-to-csv)
			- [packages:](#packages)
		- [vta_expresslanes.zip](#vta_expresslaneszip)
			- [packages:](#packages-1)
	- [Python-3.6](#python-36)
		- [pandas-redshift-feedparser-geomet](#pandas-redshift-feedparser-geomet)
- [Example](#example)

<!-- /MarkdownTOC -->


## Deployment-Packages

### Python-2.7

Based on [this blog post](http://www.perrygeo.com/running-python-with-compiled-code-on-aws-lambda.html).

#### [mssql-to-csv](https://s3-us-west-2.amazonaws.com/mtc-lambda-packages-west-2/mssql_to_csv.zip)

Pulls a table from MSSSQL Server and outputs to a CSV in an s3 bucket. 

##### packages:
- geomet (geojson)   
- pandas.  
- pymssql

#### [vta_expresslanes.zip](https://s3-us-west-2.amazonaws.com/mtc-lambda-packages-west-2/vta_expresslanes.zip)

Logs status from the VTA expresslanes RSS feed. 

##### packages:

- pandas    
- pg8000 (postgres)  

### Python-3.6

We roughly followed [this guide](https://gist.github.com/niranjv/f80fc1f488afc49845e2ff3d5df7f83b), except following the comment instructions. 

A rough sketch of how we set it up is in `install_python_3_aws_lambda_linux_v2.sh` in this directory. 

#### [pandas-redshift-feedparser-geomet](https://s3-us-west-2.amazonaws.com/mtc-lambda-packages-west-2/pandas-redshift-feedparser-geomet.zip)

packages 
- geomet (geojson)   
- pandas.  
- pandas_redshift. 
- psycopg2 (postgres)

example application: [waze-redshift-2.zip](https://s3-us-west-2.amazonaws.com/mtc-lambda-packages-west-2/waze-redshift-2.zip)

Drops Waze RSS feed into redshift table. 

## Example

1) Update script in subdirectory (e.g. waze.py in `/waze-rss`)

Uncomment `__main__` to test execution of the script

```
python waze.py
```

Note that here __main__ performs the same function as the `handler` function. 

AWS lambda allows you to call any function by name, and we set it up to call `handler`. 

2) Update deployment package

Add the updated script to the deployment packages. 

```
zip waze-redshift.zip waze.py
```

3) Copy deployment package to S3

```
aws s3 cp waze-redshift-2.zip s3://mtc-lambda-packages-west-2
```

4) Update function on AWS with updated zip from s3

```
aws lambda update-function-code --function-name \
waze-redshift --region us-west-2 --s3-bucket mtc-lambda-packages-west-2 \
--s3-key waze-redshift-2.zip
```
