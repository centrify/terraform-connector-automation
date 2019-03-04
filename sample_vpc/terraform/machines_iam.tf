// An IAM policy used by machines so they can access S3 etc
resource "aws_iam_policy" "cfy_machine_iam_policy" {
    name = "cfy_machine_iam_policy-${random_id.instance.hex}"
    path = "/"
    policy = "${data.template_file.cfy_machine_iam_policy.rendered}"    
}

data "template_file" "cfy_machine_iam_policy" {
  template = "${file("${path.module}/../data/cfy_machine_iam_policy.json.template")}"
}

// An IAM role that uses the policy 
resource "aws_iam_role" "cfy_machine_iam_role" {
    name = "cfy_machine_iam_role-${random_id.instance.hex}"
    assume_role_policy = "${file("${path.module}/../data/cfy_machine_role_policy.json.template")}"
}

// Attach machine policy to machine role
resource "aws_iam_policy_attachment" "cfy_machine_iam_policy_attach" {
    name = "cfy_machine_iam_policy_attach-${random_id.instance.hex}"
    roles = ["${aws_iam_role.cfy_machine_iam_role.name}"]
    policy_arn = "${aws_iam_policy.cfy_machine_iam_policy.arn}"
}

// And finally create profile
resource "aws_iam_instance_profile" "cfy_machine_iam_instance_profile" {
    name = "cfy_machine_iam_instance_profile-${random_id.instance.hex}"
    role = "${aws_iam_role.cfy_machine_iam_role.name}"
}
