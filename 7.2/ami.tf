resource "aws_ami_from_instance" "std17_ami" {
    count = 1
    name = "std17-ami"
    source_instance_id = aws_instance.std17_ec2.id

    snapshot_without_reboot = false

    tags = { Name = "std17-ami" }

    depends_on = [aws_instance.std17_ec2]

}