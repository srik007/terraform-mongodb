data "aws_ami" "image" {
  most_recent      = true
  owners           = ["self"]
	
	filter {
    name   = "name"
    values = [join("_", [var.platform, "mongodb-${var.mongodb_version}",var.version])]
  }
}

data "template_file" "script" {
  template = file("${path.module}/init.cfg")
}

data "template_cloudinit_config" "userdata" {
  
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.script.rendered}"
  }

	 part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/user-data.sh")
  }

}


resource "aws_instance" "mongodb" {
	 	count = var.instance_count
	 	ami = var.ami == "" ? var.ami : data.aws_ami.image.id
		instance_type = var.instance_type
		subnet_id = var.subnet_id
    vpc_security_group_ids = var.vpc_security_group_ids
		key_name = var.key_name
		associate_public_ip_address = var.associate_public_ip_address
		tags = var.tags
		user_data= data.template_cloudinit_config.userdata.rendered
	}
		
