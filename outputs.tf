#Se funziona segnare - count non funziona
/*output "ssh-connect" {
    value = [
        for i in range(var.instance_number) :
        "ssh -i ${local_sensitive_file.private_key[idx].filename} ubuntu@${aws_instance.server[idx].public_ip}"
    ]
}*/

output "ssh-connect" {
        value = "ssh -i ${local_sensitive_file.private_key[count.index].filename} ubuntu@${aws_instance.server[count.index].public_ip}"
}