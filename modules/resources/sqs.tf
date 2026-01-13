resource "aws_sqs_queue" "aws_sqs" {
  name                      = "Togglemaster-sqs"
  delay_seconds             = 0
  max_message_size          = 1024
  message_retention_seconds = 240
  receive_wait_time_seconds = 0

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-sqs"
    }
  )
}