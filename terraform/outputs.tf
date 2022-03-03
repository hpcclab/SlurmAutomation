### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("inventory.tmpl",
  {
    master-dns = aws_instance.master-node.public_dns,
    master-ip = aws_instance.master-node.public_ip,
    master-private-ip = aws_instance.master-node.private_ip,
    master-id = aws_instance.master-node.id,
    master-name = aws_instance.master-node.tags.Name,
    worker-dns = aws_instance.worker-node.*.public_dns,
    worker-ip = aws_instance.worker-node.*.public_ip,
    worker-private-ip = aws_instance.worker-node.*.private_ip,
    worker-id = aws_instance.worker-node.*.id
    worker-name = aws_instance.worker-node.*.tags.Name
  }
  )
  filename = "../ansible/inventory"
}

resource "local_file" "AnsibleVariable" {
  content = templatefile("variable.tmpl",
  {
    master-dns = aws_instance.master-node.public_dns,
    master-ip = aws_instance.master-node.public_ip,
    master-private-ip = aws_instance.master-node.private_ip,
    master-id = aws_instance.master-node.id,
    master-name = aws_instance.master-node.tags.Name,
    worker-dns = aws_instance.worker-node.*.public_dns,
    worker-ip = aws_instance.worker-node.*.public_ip,
    worker-private-ip = aws_instance.worker-node.*.private_ip,
    worker-id = aws_instance.worker-node.*.id
    worker-name = aws_instance.worker-node.*.tags.Name
  }
  )
  filename = "../ansible/group_vars/all.yml"
}