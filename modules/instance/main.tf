#================ Fetching Latest AMI ================
data "aws_ami" "latest_amazon_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-*-gp2"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

#================ Key Pair ================
resource "aws_key_pair" "web_server_key" {
  key_name = "web_server_key"
  public_key = "${file("${var.key_pair_path}")}"
}

#================ Instance ================
resource "aws_instance" "web_server" {
  ami = "${data.aws_ami.latest_amazon_ami.id}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.pub_subnet_1_id}"
  iam_instance_profile = "${var.iam_instance_profile_name}"
  key_name = "${aws_key_pair.web_server_key.key_name}"
  user_data = "${file("${var.user_data_path}")}"
  vpc_security_group_ids = ["${var.web_server_sg_id}"]

  tags {
    Name = "Web Server"
  }
}

#================ DB Instance ================
resource "aws_db_instance" "rds_instance" {
  allocated_storage = 10
  storage_type = "gp2"
  engine = "${var.db_engine}"
  engine_version = "${var.engine_version}"
  instance_class = "${var.db_instance_class}"
  identifier = "${var.db_identifier}"
  name = "${var.db_name}"
  username = "${var.db_username}"
  password = "${var.db_password}"
  availability_zone = "${var.aws_region}a"
  vpc_security_group_ids = ["${var.rds_sg_id}"]
  skip_final_snapshot = "${var.db_skip_final_snapshot}"
  backup_retention_period = "${var.db_backup_retention_period}"
  db_subnet_group_name = "${var.rds_subnet_name}"
}

#================ Load Balancer ================
resource "aws_alb" "web_server_alb" {
  name = "webserveralb"
  internal = "false"
  security_groups = ["${var.lb_sg_id}"]
  subnets = ["${var.pub_subnet_1_id}", "${var.pub_subnet_2_id}"]

  tags {
    Name = "web_server_alb"
  }
}

#================ Load Balancer Listener ================
resource "aws_alb_listener" "alb_http_listener" {
  load_balancer_arn = "${aws_alb.web_server_alb.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.web_server_alb_tg.arn}"
    type = "forward"
  }
}

/*
  If you want your load balancer to listen on HTTPS port,
  you can uncomment this optional section
#================ Optional Start ================
#================ HTTPS Listener ================
resource "aws_alb_listener" "alb_https_listener" {
  load_balancer_arn = "${aws_alb.web_server_alb.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "arn:aws:iam::account-id:server-certificate/certificate-name"

  default_action {
    target_group_arn = "${aws_alb_target_group.web_server_alb_tg.arn}"
    type = "forward"
  }
}
#================ Optional End ================
*/

#================ Load Balancer TG ================
resource "aws_alb_target_group" "web_server_alb_tg" {
  name = "web-server-lb-tg"
  port = "80"
  protocol = "HTTP"
  vpc_id  ="${var.vpc_id}"
}

#================ Load Balancer TG Attach ================
resource "aws_alb_target_group_attachment" "web_server_alb_tg_attach" {
  target_group_arn = "${aws_alb_target_group.web_server_alb_tg.arn}"
  target_id = "${aws_instance.web_server.id}"
  port = "80"
}

#================ Launch Configuration ================
resource "aws_launch_configuration" "web_server_lc" {
  name = "web_server_lc"
  image_id = "${data.aws_ami.latest_amazon_ami.id}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile_name}"
  security_groups = ["${var.web_server_sg_id}"]
  key_name = "${aws_key_pair.web_server_key.key_name}"
  user_data = "${file("${var.user_data_path}")}"
  enable_monitoring = "false"   #For enhanced monitoring you can set this to "true"
}

#================ Auto Scaling Group ================
resource "aws_autoscaling_group" "web_server_asg" {
  launch_configuration = "${aws_launch_configuration.web_server_lc.id}"
  name = "web_server_asg"
  availability_zones = ["${var.pub_subnet_1_id}", "${var.pub_subnet_2_id}"]
  max_size = "${var.asg_max_size}"
  min_size = "${var.asg_min_size}"
  health_check_grace_period = "${var.asg_health_check_gc}"
  health_check_type = "${var.asg_health_check_type}"
  desired_capacity = "${var.asg_desired_size}"
  target_group_arns = ["${aws_alb_target_group.web_server_alb_tg.arn}"]
}

#================ CloudWatch Alarm ================
resource "aws_cloudwatch_metric_alarm" "web_server_add_alarm" {
  alarm_name = "web_server_add_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "70"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web_server_asg.name}"
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions = ["${aws_autoscaling_policy.web_server_asg_add_policy.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "web_server_minus_alarm" {
  alarm_name = "web_server_minus_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "30"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web_server_asg.name}"
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions = ["${aws_autoscaling_policy.web_server_asg_add_policy.arn}"]
}

#================ Auto Scaling Policies ================
resource "aws_autoscaling_policy" "web_server_asg_add_policy" {
  name = "web_server_asg_add_policy"
  autoscaling_group_name = "${aws_autoscaling_group.web_server_asg.name}"
  policy_type = "SimpleScaling"
  scaling_adjustment = "1"
  adjustment_type = "ChangeInCapacity"
}

resource "aws_autoscaling_policy" "web_server_asg_minus_policy" {
  name = "web_server_asg_minus_policy"
  autoscaling_group_name = "${aws_autoscaling_group.web_server_asg.name}"
  policy_type = "SimpleScaling"
  scaling_adjustment = "-1"
  adjustment_type = "ChangeInCapacity"
}

#================ Auto Scaling Notification ================
resource "aws_autoscaling_notification" "web_server_asg_notification" {
  group_names = ["${aws_autoscaling_group.web_server_asg.name}"]
  notifications = ["autoscaling:EC2_INSTANCE_LAUNCH", "autoscaling:EC2_INSTANCE_TERMINATE", "autoscaling:EC2_INSTANCE_LAUNCH_ERROR"]
  topic_arn = "${aws_sns_topic.web_server_sns.arn}"
}

#================ SNS ================
resource "aws_sns_topic" "web_server_sns" {
  name = "web_server_sns"
  display_name = "Web Server"
}

/*
  You need to manually add the subscribers to SNS topib as per your need
*/
