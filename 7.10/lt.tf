resource "aws_launch_template" "std17_lt" {
    image_id = aws_ami_from_instance.std17_ami.id
    name_prefix = "std17-lt-"
    instance_type = "t3.micro"
    key_name = "std17-key"

    vpc_security_group_ids = [
        aws_security_group.std17_test_sg.id
    ]

    update_default_version = true
    description = "Launch template for ASG using custom AMI"

    tag_specifications {
        resource_type = "instance"
        tags = { Name = "std17-private-asg-instance" }
    }
}