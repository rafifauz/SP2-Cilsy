echo "-----------Create VPC--------------"
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=VPC-Rafi}]'
aws ec2 describe-vpcs --filters Name=tag-value,Values=VPC-Rafi | grep -w "Value\|VpcId" | tr -d '"'','| awk '{print $2}'| uniq 

echo "-----------Subnet--------------"
vpcId=$(aws ec2 describe-vpcs --filters Name=tag-value,Values=VPC-Rafi | grep -w "VpcId" | tr -d '"'','| awk '{print $2}'| uniq)
aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.1.0/24 --availability-zone ap-southeast-1a --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public-Subnet-Sp2}]'
aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.2.0/24 --availability-zone ap-southeast-1b --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private1-Subnet-Sp2}]'
aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.3.0/24 --availability-zone ap-southeast-1c --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private2-Subnet-Sp2}]'

aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpcId | grep -w "Value\|SubnetId" | tr -d '"'',' | awk '{print $2}' | uniq 
# aws ec2 describe-subnets --filters Name=vpc-id,Values=vpc-0b2156ec449d1899c | grep -w "Value\|SubnetId" | tr -d '"'',' | awk '{print $2}' | uniq 

echo "-----------Internet Gateway--------------"
aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=IGW-SP2}]'
aws ec2 describe-internet-gateways --filters Name=tag-value,Values=IGW-SP2 | grep -w "Value\|InternetGatewayId" | tr -d '"'',' | awk '{print $2}' | uniq 

igwId=$(aws ec2 describe-internet-gateways --filters Name=tag-value,Values=IGW-SP2 | grep -w "InternetGatewayId" | tr -d '"'',' | awk '{print $2}' | uniq )
aws ec2 attach-internet-gateway --vpc-id $vpcId --internet-gateway-id $igwId
# aws ec2 attach-internet-gateway --vpc-id vpc-0b2156ec449d1899c --internet-gateway-id igw-07b93e61b141b2db8

echo "-----------Routing Table--------------"
RouteTableId1=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$vpcId | grep -w "RouteTableId" | tr -d '"'',' | awk '{print $2}' | uniq)
aws ec2 create-tags --resources $RouteTableId1 --tags Key=Name,Value=Public-Route-SP2
aws ec2 create-route-table --vpc-id $vpcId --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Private-Route-SP2}]'
#aws ec2 create-route-table --vpc-id vpc-0b2156ec449d1899c --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Private-Route-SP2}]'

echo "-----------Elastic IP--------------"
aws ec2 allocate-address --domain vpc --network-border-group ap-southeast-1 
# ElasticIP=$(aws ec2 describe-addresses --filters Name=tag-value,Values=ElasticIP-Sp2 | grep -w "AllocationId" | tr -d '"'',' | awk '{print $2}' | uniq)
ElasticIP=$(aws ec2 describe-addresses | grep -w "AllocationId" | tr -d '"'',' | awk '{print $2}' | uniq)
aws ec2 create-tags --resources $ElasticIP --tags Key=Name,Value=ElasticIP-Sp2

echo "-----------NAT Gateway--------------"
PublicSubnet=$(aws ec2 describe-subnets --filters Name=tag-value,Values=Public-Subnet-Sp2 | grep -w "SubnetId" | tr -d '"'',' | awk '{print $2}' | uniq)
aws ec2 create-nat-gateway --subnet-id $PublicSubnet --allocation-id $ElasticIP --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=NAT-Sp2}]'

#aws ec2 describe-subnets --filters Name=tag-value,Values=Public-Subnet-Sp2 | grep -w "Value\|SubnetId" | tr -d '"'',' | awk '{print $2}' | uniq


echo "-----------Edit Routing Table--------------"
PublicRT=$(aws ec2 describe-route-tables --filters Name=tag-value,Values=Public-Route-SP2 | grep -w "RouteTableId" | tr -d '"'',' | awk '{print $2}' | uniq)
igwId=$(aws ec2 describe-internet-gateways --filters Name=tag-value,Values=IGW-SP2 | grep -w "InternetGatewayId" | tr -d '"'',' | awk '{print $2}' | uniq)
PrivateRT=$(aws ec2 describe-route-tables --filters Name=tag-value,Values=Private-Route-SP2 | grep -w "RouteTableId" | tr -d '"'',' | awk '{print $2}' | uniq)
NatId=$(aws ec2 describe-nat-gateways --filter Name=tag-value,Values=NAT-Sp2 | grep -w "NatGatewayId" | tr -d '"'',' | awk '{print $2}' | uniq)
aws ec2 create-route --route-table-id $PublicRT --destination-cidr-block 0.0.0.0/0 --gateway-id $igwId
aws ec2 create-route --route-table-id $PrivateRT --destination-cidr-block 0.0.0.0/0 --gateway-id $NatId

# echo "-----------Create S3 Bucket--------------"
# aws s3api create-bucket --bucket buket-sp2 --region ap-southeast-1 --create-bucket-configuration LocationConstraint=ap-southeast-1

# awk '{print $3}' ~/.aws/credentials |tr '\n' ':'|sed 's/^.//'|sed 's/.$//'

echo "-----------Create Security Groups--------------"
#vpcId=$(aws ec2 describe-vpcs --filters Name=tag-value,Values=VPC-Rafi | grep -w "VpcId" | tr -d '"'','| awk '{print $2}'| uniq)
#PublicSubnet=$(aws ec2 describe-subnets --filters Name=tag-value,Values=Public-Subnet-Sp2 | grep -w "SubnetId" | tr -d '"'',' | awk '{print $2}' | uniq)
aws ec2 create-security-group --group-name SP2-SecurityGroup --description "My security group" --vpc-id $vpcId --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=SP2-SecurityGroup}]'
SgId=$(aws ec2 describe-security-groups --filters Name=tag-value,Values=SP2-SecurityGroup | grep -w "GroupId" | tr -d '"'',' | awk '{print $2}' | uniq)
aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 22 --cidr 0.0.0.0/0


echo "-----------Create Instance Nginx --------------"
aws ec2 run-instances --image-id ami-06fb5332e8e3e577a --count 1 --instance-type t2.micro --subnet-id $PublicSubnet  --key-name CilsyAWS --security-group-ids $SgId --associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Web_SP2}]' 'ResourceType=volume,Tags=[{Key=Name,Value=Web_SP2}]' --user-data '#!/bin/bash
sudo apt update
sudo apt install nginx -y
sudo apt install mysql-server -y
sudo apt install php-fpm -y
sudo apt-get install -y php-mysqli 
sudo apt-get install unzip
sudo apt install s3fs awscli -y'

echo "---------Hasil Public IP tiap Instance------------"
aws ec2 describe-instances | grep -w "Value\|PrivateIpAddress\|PublicIpAddress" | tr -d '"'','| awk '{print $2}'| uniq -u

echo -e "\n---------Silahkan jalankan scrip berikun di tab baru ------------"
aws ec2 describe-instances | grep "PublicIpAddress"| tr -d '"'','| awk '{print "sudo ssh -i \"CilsyAWS.pem\" ubuntu@"$2}' 




