# Deploy Wordpress on Ubuntu 22.04 server using terraform

With this repo, with just terraform apply --auto-approve you can have a fresh wordpress installation on AWS.

## Prerequisites
It is assumed you have terraform installed on your system

You must have set up AWS credentials on your system

## Steps

Clone the repo and cd into the folder

run terraform init

run terraform apply --auto-approve

Congrats you will get a public IP to view your website.


### Notes
You can change the default password used in the bash script in userdata.tpl

After terraform finishs, AWS takes time to provision the server, so be patient until checks get to 2/2 from the console to view website.