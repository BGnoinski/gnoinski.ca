### count key, exists for all resources

Tells terraform to create count = # of resources as described

```
resource "aws_vpc" "vpc" {
  count = 2
  cidr_block = "10.10.0.0/16"
}
```

### count.index

On each iteration of count, terraform provides count.index which is zero indexed. We can use the index with either element() or lookup() to get values from lists or maps.

```
resource "aws_vpc" "vpc" {
  count = 2
  cidr_block = "${lookup(var.cidrs, count.index)}"

  tags {
    "Name" = "${element(var.vpcs, count.index)}"
  }
}
```

On iteration 1 it would look like
```
# count.index = 0
resource "aws_vpc" "vpc" {
  cidr_block = "${lookup(var.cidrs, 0)}"

  tags {
    "Name" = "${element(var.vpcs, 0)}"
  }
}
```

On iteration 2 it would look like
```
# count.index = 1
resource "aws_vpc" "vpc" {
  cidr_block = "${lookup(var.cidrs, 1)}"

  tags {
    "Name" = "${element(var.vpcs, 1)}"
  }
}
```

### using length to get a dynamic count

If we want to extend how useful count is we can use "${lenght(var.vps)}" to dynamically get the length of a list, or map. This means we can continually add more resources without having to manually update the count. 


```
resource "aws_vpc" "vpc" {
  count = "${length(var.vpcs)}"
  cidr_block = "${lookup(var.cidrs, count.index)}"

  tags {
    "Name" = "${element(var.vpcs, count.index)}"
  }
}
```