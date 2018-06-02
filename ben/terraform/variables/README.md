### variable types
```
string = "Test string"

list = ["value1", "value2", "value3"]

map ={
    "key1" = "value1"
    "key2" = "value2"
}
```
### Declaring Variables

```
variable "string" {}

variable "list" {
    type = "list"
}

variable "map"{
    type = "map"
}
```

### Declaring Variables with default Values

```
variable "string" {
    default "Test String"
}

variable "list" {
    type = "list"
    default = ["value1", "value2", "value3"]
}

variable "map"{
    type = "map"
    default = {
        "key1" = "value1"
        "key2" = "value2"
    }
}
```

### Interpolating variables
```
varible "region" {
    default = "ca-central-1"
}

resource "aws_vpc" "vpc" {
    cidr_block = "10.10.10.0/24"

    tags {
        Name = "${var.region}"
    }
}
```

### Variable files

End in .tfvars

can be loaded with -var-file=VARFILE.tfvars