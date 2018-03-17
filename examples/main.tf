variable "aws_account_id" {
  description = "AWS account id"
}

variable "aws_access_key" {
  description = "AWS access key"
}

variable "aws_secret_key" {
  description = "AWS secret key"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
}

# where should this API deployed to
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}


# main configuration
module "dynamic-secgroup" {
  source          = "../"

  name            = "example-terraform-aws-authenticating-secgroup"

  # Description of this secgroup
  description     = "example usage of terraform-aws-authenticating-secgroup"

  # Time to expiry for every rule.
  time_to_expire  = 600

  security_groups = [
    {
      "group_ids"   = [
        "sg-df7a88a3",
        "sg-c9c72eb5"
      ],
      "rules"       = [
        {
          "type"      = "ingress",
          "from_port" = 22,
          "to_port"   = 22,
          "protocol"  = "tcp"
        }
      ],
      "region_name" = "us-west-2"
    },
    {
      "group_ids"   = [
        "sg-c9c72eb5"
      ],
      "rules"       = [
        {
          "type"      = "ingress",
          "from_port" = 24,
          "to_port"   = 24,
          "protocol"  = "tcp"
        }
      ],
      "region_name" = "us-west-2"
    },
    {
      "group_ids"   = [
        "sg-a1a9d8d8"
      ],
      "rules"       = [
        {
          "type"      = "ingress",
          "from_port" = 24,
          "to_port"   = 24,
          "protocol"  = "tcp"
        },
        {
          "type"      = "ingress",
          "from_port" = 25,
          "to_port"   = 25,
          "protocol"  = "tcp"
        }
      ],
      "region_name" = "us-west-1"
    }
  ]
}

# policy
resource "aws_iam_policy" "this" {
  description = "Policy Developer SSH Access"
  policy      = "${data.aws_iam_policy_document.access_policy_doc.json}"
}

data "aws_iam_policy_document" "access_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = [
      "execute-api:Invoke"
    ]
    resources = [
      "${module.dynamic-secgroup.execution_resources}"]
  }
}

# some outputs
output "dynamic-secgroup-api-invoke-url" {
  value = "${module.dynamic-secgroup.invoke_url}"
}
