<img width="1440" height="1240" alt="image" src="https://github.com/user-attachments/assets/dc7f31f7-3d55-4962-83cf-6f207095dcd9" />

Terraform provisioners are used to execute scripts or commands on a local machine or remote server after a resource is created or destroyed.

Provisioners are mainly used for:

* Installing software
* Copying files
* Running configuration scripts
* Bootstrapping servers

Terraform provisioners are:

1. `local-exec`
2. `remote-exec`
3. `file`

---

# 1. local-exec Provisioner

Runs commands on your local machine where Terraform is executed.

## Real-Time Use Case

* Send notification
* Store logs
* Backup Terraform outputs
* Trigger scripts locally

## Example

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> server_ips.txt"
  }
}
```

## Workflow

1. Terraform creates EC2 instance
2. After creation, command runs on local machine
3. Public IP is stored in `server_ips.txt`

---

# 2. remote-exec Provisioner

Runs commands inside the remote server (EC2/Linux VM).

## Real-Time Use Case

* Install packages
* Start services
* Configure applications
* Run shell scripts

## Example

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"
  key_name      = "my-key"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("my-key.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]
  }
}
```

## Workflow

1. Terraform creates EC2
2. SSH connection established
3. Commands execute inside EC2
4. Apache installed and started

---

# 3. file Provisioner

Copies files from local machine to remote server.

## Real-Time Use Case

* Copy shell scripts
* Upload configuration files
* Move application files
* Transfer backup files

## Example

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"
  key_name      = "my-key"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("my-key.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "app.sh"
    destination = "/tmp/app.sh"
  }
}
```

## Workflow

1. Terraform creates EC2
2. SSH connection established
3. `app.sh` copied to server

---

# Complete Real-Time Example

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"
  key_name      = "my-key"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("my-key.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "install.sh"
    destination = "/tmp/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install.sh",
      "/tmp/install.sh"
    ]
  }

  provisioner "local-exec" {
    command = "echo Server IP: ${self.public_ip} >> output.txt"
  }
}
```

---

# Provisioner Execution Order

Terraform executes provisioners in this order:

1. `file`
2. `remote-exec`
3. `local-exec`

---

# Important Concepts

## `self`

Used to access current resource attributes.

Example:

```hcl
${self.public_ip}
```

---

# Connection Block

Used by `remote-exec` and `file`.

## SSH Example

```hcl
connection {
  type        = "ssh"
  user        = "ec2-user"
  private_key = file("my-key.pem")
  host        = self.public_ip
}
```

---

# Destroy-Time Provisioner

Runs before resource deletion.

## Example

```hcl
provisioner "local-exec" {
  when    = destroy
  command = "echo Resource Destroyed"
}
```

---

# Common Interview Questions

## Why provisioners are not recommended?

Because:

* Not idempotent
* Hard to manage
* Less reliable
* Configuration drift issue

Preferred tools:

* Ansible
* User data
* Cloud-init
* Packer

---

# Difference Between local-exec and remote-exec

| Feature    | local-exec         | remote-exec          |
| ---------- | ------------------ | -------------------- |
| Runs Where | Local Machine      | Remote Server        |
| SSH Needed | No                 | Yes                  |
| Use Case   | Logging/Automation | Server Configuration |

---

# Best Practice

Use:

* `user_data` for EC2 bootstrapping
* Ansible for configuration management
* Provisioners only for small automation tasks

---

# How to Practice

## Practice 1

* Create EC2
* Install Apache using `remote-exec`

## Practice 2

* Copy HTML file using `file`
* Move to `/var/www/html`

## Practice 3

* Store EC2 public IP locally using `local-exec`

## Practice 4

* Upload backup file to S3 using AWS CLI in `local-exec`

Example:

```hcl
provisioner "local-exec" {
  command = "aws s3 cp backup.zip s3://mybucket/"
}
```

---

# Terraform Commands for Practice

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
terraform fmt
```

---

# Simple Interview Answer

“Terraform provisioners are used to execute scripts or commands locally or on remote servers after infrastructure creation. Mainly we use local-exec, remote-exec, and file provisioners for automation tasks like software installation, file copy, and server configuration.”
