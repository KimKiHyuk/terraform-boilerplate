variable "name" {
  type = string
}

variable "lb" {
  type = object({
    dns_name = string
    zone_id  = string
  })
}
  