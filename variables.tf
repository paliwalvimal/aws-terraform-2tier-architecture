/*
  AWS Region List
  ===============
  us-east-1       (N. Virginia)
  us-east-2       (Ohio)
  us-west-1       (N. California)
  us-west-2       (Oregon)
  ca-central-1    (Canada)
  eu-west-1       (Ireland)
  eu-central-1    (Frankfurt)
  eu-west-2       (London)
  ap-southeast-1  (Singapore)
  ap-southeast-2  (Sydney)
  ap-northeast-1  (Tokyo)
  ap-northeast-2  (Seoul)
  ap-south-1      (Mumbai)
  sa-east-1       (São Paulo)
*/


variable "aws_region" {
  default = "ap-south-1"  #Select appropriate region from the above list
}
variable "aws_profile" {
  default = "default"
}
variable "instance_type" {
  default = "t2.micro"  #Provide appropriate instance type supported by the region
}
variable "key_pair_path" {
  default = "public-key"  #Must generate your own key pair and use them to SSH
}
variable "user_data_path" {
  default = "userdata.sh" #Feel free to make changes as per requirement
}
variable "db_engine" {
  default = "mysql"
}
variable "engine_version" {
  default = "5.6.37"  #Provide appropriate version supported by the mysql as per the region
}
variable "db_instance_class" {
  default = "db.t2.micro" #Provide appropriate db instance type supported by the region
}
variable "db_identifier" {
  default = "testdb"  #Use relevant name for db instance
}
variable "db_name" {
  default = "testdb"  #Use relevant name for db name
}
variable "db_username" {
  default = "testuser"  #Must not use this for production db
}
variable "db_password" {
  default = "testdb_pass" #Must not use this password for production db
}
variable "db_skip_final_snapshot" {
  default = "true"  #Change it to "true" for production db
}
variable "db_backup_retention_period" {
  default = "1" #Number of days you want to preserve automated backups. Maximum value is 35
}
variable "asg_health_check_gc" {
  default = "300"
}
variable "asg_health_check_type" {
  default = "ELB"
}
variable "asg_min_size" {
  default = "1" #Change the figure as per requirement
}
variable "asg_max_size" {
  default = "2" #Change the figure as per requirement
}
variable "asg_desired_size" {
  default = "1" #Change the figure as per requirement. Must be between min and max size
}
