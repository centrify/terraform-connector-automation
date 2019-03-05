Copyright 2019 Centrify Corporation
 
This Terraform set of scripts is provided as an example of how to automatically deploy a Centrify Connector within a new VPC. This example will create a VPC across 2 Availability Zones where Centrify Connectors will be created within the Private Subnet in each avilability zone. 

When you run this set of script in the terraform directory via "terraform apply" command, you will be asked for an account and password for your Centrify Privileged Access Service Tenant along with the URL for the Tenant. When the script completes, you should then find the 2 new Connectors have been created and added to your Tenant. 

Please send any feedback to david.mcneely@centrify.com. 
