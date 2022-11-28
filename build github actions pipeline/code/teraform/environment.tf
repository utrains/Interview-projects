resource "aws_elastic_beanstalk_application" "application" {
  name        = "nodejsapp"
}
resource "aws_elastic_beanstalk_environment" "Devel" {
  name                = "Devel"
  application         = aws_elastic_beanstalk_application.application.name
  solution_stack_name = "64bit Amazon Linux 2 v5.6.1 running Node.js 14"
setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name      = "IamInstanceProfile"
        value     = "aws-elasticbeanstalk-ec2-role"
      }
}

resource "aws_elastic_beanstalk_environment" "Staging" {
  name                = "Staging"
  application         = aws_elastic_beanstalk_application.application.name
  solution_stack_name = "64bit Amazon Linux 2 v5.6.1 running Node.js 14"
setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name      = "IamInstanceProfile"
        value     = "aws-elasticbeanstalk-ec2-role"
      }
}

resource "aws_elastic_beanstalk_environment" "Prod" {
  name                = "Prod"
  application         = aws_elastic_beanstalk_application.application.name
  solution_stack_name = "64bit Amazon Linux 2 v5.6.1 running Node.js 14"
setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name      = "IamInstanceProfile"
        value     = "aws-elasticbeanstalk-ec2-role"
      }
}