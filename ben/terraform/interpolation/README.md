### format
```
"${argument1.argument2.argument3}"
```

**argument1**: Which resource type are we getting information from?

**argument2**: What is the unique identifier of the resource type?

**argument3**: What is the attribute that we are using from that resource?

### basic interpolation

```
resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr}"
}

resource "aws_subnet" "public_ca-central-1a" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.public_ca-central-1a_cidr}"
}
```

### interpolation functions

```
element(list, index)
```

Returns the item in the specified index within the list provided. 

```
lookup(map, "key")
```

Returns the value for the given key

