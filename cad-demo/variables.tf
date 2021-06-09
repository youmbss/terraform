variable "public_cidr_blocks" {
    description = "these are public cidr blocks for your subnets" 
    default = ["10.0.11.0/24" , "10.0.12.0/24" , "10.0.13.0/24"]
}
variable "private_cidr_blocks" {
    description = "these are private cidr blocks for your subnets" 
    default = ["10.0.41.0/24"  , "10.0.42.0/24" , "10.0.43.0/24"]
}
 
variable "availability_zones" {
    description = "these are availabilty zones for your subnets"
    default = ["ca-central-1a" , "ca-central-1b" , "ca-central-1d"]  
}

variable "env_name" {
    description = "this is the name for your environments"
    default = "Dev"  
  
}
variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
}  
