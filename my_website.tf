provider "aws" {
 region = "ap-south-1"
 profile = "shivi"
}

resource "aws_instance" "web" {
 ami = "ami-0447a12f28fddb066"
 instance_type = "t2.micro"
 key_name = "newseckey"
 security_groups = [ "mysecgrp" ]

 connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("C:/Users/Shivangi/Downloads/AWS-keys/newseckey.pem")
    host = aws_instance.web.public_ip
 }
 provisioner "remote-exec" {
    inline = [
                "sudo yum install httpd php git -y",
                "sudo systemctl start httpd",
                "sudo systemctl enable httpd",
             ]
 }
 tags = {
    name = "first_web"
 }
}


resource "aws_ebs_volume" "web_ebs" {
  availability_zone = aws_instance.web.availability_zone
  size = 1
  tags = {
    name = "web_ebs"
     }
} 


resource "aws_volume_attachment" "web_ebs_attach" {
  device_name = "/dev/sdh"
  volume_id = "${aws_ebs_volume.web_ebs.id}"
  instance_id = "${aws_instance.web.id}"
  force_detach = true
}
 

output "web_ip" {
  value = aws_instance.web.public_ip
}

resource "null_resource" "null1" {
  
  depends_on = [ 
     aws_volume_attachment.web_ebs_attach,
       ]
  connection{
    type = "ssh"
    user = "ec2-user"
    private_key =file("C:/Users/Shivangi/Downloads/AWS-keys/newseckey.pem")
    host = aws_instance.web.public_ip
   }  
  provisioner "remote-exec" {
    inline= [
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo mount /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/ShivangiSharma77/terraform_AWS.git /var/www/html/"
      ]
     
   }
}

resource "null_resource" "null2" {
 depends_on = [
     null_resource.null1
   ] 
 provisioner "local-exec"{
       command= "start chrome ${aws_instance.web.public_ip}"
          }
}

  
   



  


