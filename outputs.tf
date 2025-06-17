#Se funziona segnare - count non funziona
output "ssh-connect" {
    value = [
        for i in range(var.instance_number) :
        "ssh -i ${local_sensitive_file.private_key[i].filename} ubuntu@${aws_instance.server[i].public_ip}"
    ]
}

output "grafana_url" {
    value = [
        for i in range(var.instance_number) :
        "http://${aws_instance.server[i].public_ip}:3000"
    ]
}

/*
output "ssh-connect" {
        value = "ssh -i ${local_sensitive_file.private_key[count.index].filename} ubuntu@${aws_instance.server[count.index].public_ip}"
}
#ERROR: The "count" object can only be used in "module", "resource", and "data" blocks, and only when the "count" argument is set.
*/