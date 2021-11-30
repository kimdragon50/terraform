
variable "key_pair_name" {
    type        = string
    default     = "KYM-NDP"
    description = "keypair name"
}


variable "ec2_bastion_instnace_type" {
    type        = string
    default     = "t2.micro"
    description = "bastion instance type"
}


variable "vpc_name" {
    type        = string
    default     = "KYM-NDP"
    description = "vpc name"
}

variable "vpc_cidr" {
    type        = string
    default     = "10.10.0.0/16"
    description = "vpc cidr"
}

variable "vpc_azs" {
    type        = list
    default     = ["ap-northeast-2a", "ap-northeast-2c"]
    description = "vpc azs"
}

variable "public_cidr" {
    type        = list
    default     = ["10.10.1.0/24", "10.10.2.0/24"]
    description = "public cidr"
}

variable "private_cidr" {
    type        = list
    default     = ["10.10.3.0/24","10.10.4.0/24,","10.10.5.0/24","10.10.6.0/24","10.10.7.0/24","10.10.8.0/24","10.10.9.0/24","10.10.10.0/24","10.10.11.0/24","10.10.12.0/24","10.10.13.0/24","10.10.14.0/24"]
    description = "private cidr"
}



variable "gateway_private_cidr" {
    type        = list
    default     = ["10.10.3.0/24","10.10.4.0/24"]
    description = "gateway private cidr"
}

variable "frontend_private_cidr" {
    type        = list
    default     = ["10.10.5.0/24","10.10.6.0/24"]
    description = "frontend private cidr"
}

variable "backend_private_cidr" {
    type        = list
    default     = ["10.10.7.0/24","10.10.8.0/24"]
    description = "backend private cidr"
}

variable "db_private_cidr" {
    type        = list
    default     = ["10.10.9.0/24","10.10.10.0/24"]
    description = "db private cidr"
}

variable "managed_private_cidr" {
    type        = list
    default     = ["10.10.11.0/24","10.10.12.0/24"]
    description = "managed private cidr"
}

variable "bigdata_private_cidr" {
    type        = list
    default     = ["10.10.13.0/24","10.10.14.0/24"]
    description = "bigdata private cidr"
}


variable "gateway_node_instance_type" {
  # Smallest recommended, where ~1.1Gb of 2Gb memory is available for the Kubernetes pods after ‘warming up’ Docker, Kubelet, and OS
  default = "m5.large"
  type    = string
}


variable "frontend_node_instance_type" {
  # Smallest recommended, where ~1.1Gb of 2Gb memory is available for the Kubernetes pods after ‘warming up’ Docker, Kubelet, and OS
  default = "m5.large"
  type    = string
}


variable "backend_node_instance_type" {
  # Smallest recommended, where ~1.1Gb of 2Gb memory is available for the Kubernetes pods after ‘warming up’ Docker, Kubelet, and OS
  default = "m5.large"
  type    = string
}

variable "managed_node_instance_type" {
  # Smallest recommended, where ~1.1Gb of 2Gb memory is available for the Kubernetes pods after ‘warming up’ Docker, Kubelet, and OS
  default = "m5.large"
  type    = string
}
