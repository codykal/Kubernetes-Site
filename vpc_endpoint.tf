resource "aws_vpc_endpoint" "lambda_to_s3" {
  vpc_id          = aws_vpc.VPC_Main.id
  service_name    = "com.amazonaws.us-west-2.s3"
  route_table_ids = [aws_route_table.RT_Main.id]
}