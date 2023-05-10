resource "aws_secretsmanager_secret" "extend-interview" {
  name = "extend-interview/donaho"
}

resource "aws_secretsmanager_secret_version" "value" {
  secret_id     = aws_secretsmanager_secret.extend-interview.id
  secret_string = formatdate("03/20/2023", timestamp())
}

resource "aws_iam_user" "interview-developer" {
  name = "interview-developer"
 

  tags = {
    tag-key = "interview-developer"
  }
}

resource "aws_iam_user" "interview-bot" {
  name = "interview-bot"
 

  tags = {
    tag-key = "interview-bot"
  }
}

resource "aws_iam_access_key" "interview-bot" {
  user = aws_iam_user.interview-bot.name
  
}
#giving read-access policy
data "aws_iam_policy_document" "bot-policy" {
  statement {
    sid    = "EnableAnotherAWSAccountToReadTheSecret"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_user.interview-bot.arn}"]
    }

    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}

resource "aws_secretsmanager_secret_policy" "bot-policy" {
  secret_arn = aws_secretsmanager_secret.extend-interview.arn
  policy     = data.aws_iam_policy_document.bot-policy.json
}