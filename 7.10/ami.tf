resource "aws_ami_from_instance" "std17_ami" {
    name = "std17-ami"
    source_instance_id = aws_instance.std17_private_ec2.id

    snapshot_without_reboot = false

    depends_on = [time_sleep.wait_for_userdata]

    tags = { Name = "std17-ami"}
}