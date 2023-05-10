output "aws_secretsmanager_secret" {
    value = aws_secretsmanager_secret.extend-interview
 
}

#data "aws_iam_access_key" "interview_bot" {
#  user_name = aws_iam_user.interview_bot.name
#}

output "user_id" {
  value = aws_iam_access_key.interview-bot.id
}



output "user_secret" {
  value     = nonsensitive(aws_iam_access_key.interview-bot.secret)
}

resource "local_file" "interview_bot_credentials" {
  content  = "Access key ID: ${aws_iam_access_key.interview-bot.id}\n  Secret access key: ${aws_iam_access_key.interview-bot.secret}\n"
  filename = "interview_bot_credentials.txt"
}