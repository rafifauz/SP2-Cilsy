# echo "-----------Create VPC--------------"
# aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=VPC-Rafi}]'
# aws ec2 describe-vpcs | grep -w "Value\|VpcId" | tr -d '"'','| awk '{print $2}'| uniq 

# echo "-----------Subnet--------------"
# read -p "Enter VPCId: " vpcId
# aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.1.0/24 --availability-zone ap-southeast-1a --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public-Subnet-Sp2}]'
# aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.2.0/24 --availability-zone ap-southeast-1b --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private1-Subnet-Sp2}]'
# aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.3.0/24 --availability-zone ap-southeast-1c --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private2-Subnet-Sp2}]'

# aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpcId | grep -w "Value\|SubnetId" | tr -d '"'',' | awk '{print $2}' | uniq -u
# # aws ec2 describe-subnets --filters Name=vpc-id,Values=vpc-0b2156ec449d1899c | grep -w "Value\|SubnetId" | tr -d '"'',' | awk '{print $2}' | uniq 

# echo "-----------Internet Gateway--------------"
# aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=IGW-SP2}]'
# aws ec2 describe-internet-gateways | grep -w "Value\|InternetGatewayId" | tr -d '"'',' | awk '{print $2}' | uniq -u

# read -p "Enter IGW-ID: " igwId
# aws ec2 attach-internet-gateway --vpc-id $vpcId --internet-gateway-id $igwId
# # aws ec2 attach-internet-gateway --vpc-id vpc-0b2156ec449d1899c --internet-gateway-id igw-07b93e61b141b2db8

#echo "-----------Routing Table--------------"
#RouteTableId1=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=vpc-0b2156ec449d1899c | grep -w "RouteTableId" | tr -d '"'',' | awk '{print $2}' | uniq )
#aws ec2 create-tags --resources $RouteTableId1 --tags Key=Name,Value=Public-Route-SP2
#aws ec2 create-route-table --vpc-id $vpcId --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Private-Route-SP2}]'
# #aws ec2 create-route-table --vpc-id vpc-0b2156ec449d1899c --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Private-Route-SP2}]'

#echo "-----------NAT Gateway--------------"
