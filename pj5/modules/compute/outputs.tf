output "cluster_name" {
    value = aws_ecs_cluster.std17.name
}

output "db_instance_id" {
    value = aws_instance.std17_db_node.id
}