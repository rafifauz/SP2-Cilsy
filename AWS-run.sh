echo "-----------Create VPC--------------"
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=VPC-Rafi}]'
aws ec2 describe-vpcs | grep -w "Value\|VpcId" | tr -d '"'','| awk '{print $2}'| uniq -u

echo "-----------Subnet--------------"
read -p "Enter VPCId: " vpcId
aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.1.0/24 --availability-zone ap-southeast-1a --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public-Subnet-Sp2}]'
aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.2.0/24 --availability-zone ap-southeast-1b --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private1-Subnet-Sp2}]'
aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.3.0/24 --availability-zone ap-southeast-1c --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private2-Subnet-Sp2}]'

echo "-----------Internet Gateway--------------"
