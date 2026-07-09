resource "aws_ec2_instance_connect_endpoint" "std17_eice" {
  subnet_id         = aws_subnet.std17_private_subnets[0].id
  security_group_ids = [aws_security_group.std17_test_sg.id]

  tags = { Name = "std17-eice" }
}