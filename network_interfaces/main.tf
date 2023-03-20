# custom policy 생성
resource "aws_iam_policy" "network_manager_policy" {
  name = "${var.name}-policy"
  path = "/"
  description = "Lambda using policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface",
          "ec2:DetachNetworkInterface",
          "tag:GetTagValues"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
# lambda에서 사용할 role 생성
resource "aws_iam_role" "network_manager_role" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}
# role에 policy 연결
resource "aws_iam_role_policy_attachment" "network_manager_custom_role_attach" {
  role = aws_iam_role.network_manager_role.name
  policy_arn = aws_iam_policy.network_manager_policy.arn
}
resource "aws_iam_role_policy_attachment" "network_manager_managed_role_attach" {
  count = length(var.role)
  role = aws_iam_role.network_manager_role.name
  policy_arn = var.role[count.index]
}
# lambda function 생성
resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.function_name}"
  description = "Network Interface manager for ec2 instances"
  s3_bucket = "binxio-public-${var.region}"
  s3_key = "${var.CFNCustomProviderZipFileName}"
  role = aws_iam_role.network_manager_role.arn
  runtime = "python3.7"
  handler = "network_interface_manager.handler"
  timeout = "900"
}
# lambda 권한 추가
resource "aws_lambda_permission" "allow_invoke" {
  function_name = aws_lambda_function.lambda_function.function_name
  action = "lambda:InvokeFunction"
  principal = "events.amazonaws.com"
}
# 5분마다 lambda function 실행
resource "aws_cloudwatch_event_rule" "sync_event" {
  name = "sync_event"
  description = "sync event rule"
  schedule_expression = "rate(5 minutes)"
}
resource "aws_cloudwatch_event_target" "sync_event_target" {
  rule = aws_cloudwatch_event_rule.sync_event.name
  arn = aws_lambda_function.lambda_function.arn
}
# ASG에서 이벤트 발생시 lambda function 실행
resource "aws_cloudwatch_event_rule" "asg_event" {
  name = "asg_event"
  description = "asg event rule"
  event_pattern = jsonencode({
    source = [
        "aws.ec2"
    ],
    detail-type = [
        "EC2 Instance State-change Notification"
    ]
  })
}
resource "aws_cloudwatch_event_target" "asg_event_target" {
  rule = aws_cloudwatch_event_rule.asg_event.name
  arn = aws_lambda_function.lambda_function.arn
}