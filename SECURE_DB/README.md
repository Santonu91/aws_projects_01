# Deploying a Multi-Tier Website Using AWS EC2 
# Architecture details
# Front-end -HTML on EC2
# App -tier -phpmyadmin on docker on  EC2
# DB - tier -  MySQL DB
# AWS  MySQL RDS and Connecting Through PhpMyadmin | Connecting RDS Through CLI

Additional notes:

Connect thru cli
mysql -h db-endpoint  -u username -p(password not reqd here it will prompt for password)

Applications to be installed
mysql ,phpyadmin on docker,
yum install docker
systemctl start docker 
docker run --name phpmyadmin -d -e PMA_ARBITRARY=1 -p 8080:80 phpmyadmin


# Scenario
Company ABC wants to move their product to AWS. They have the following things set up right now:
1. MySQL DB
2. Website (PHP)
The company wants high availability on this product, therefore wants Auto Scaling to be enabled on this website.
Steps To Solve:
1. Launch an EC2 Instance
2. Enable Auto Scaling on these instances (minimum 2) 3. Create an RDS Instance
4. Create Database & Table in RDS instance:
a. Database name: intel
b. Table name: data
c. Database password: intel123
5. Change hostname in website
6. Allow traffic from EC2 to RDS instance 7. Allow all-traffic to EC2 instance

