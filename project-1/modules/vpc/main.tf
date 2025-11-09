resource "aws_vpc" "demo-vpc" {
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = merge(
    var.tags,
    {
        Name = var.vpc_name
    }
  )

}

resource "aws_subnet" "public" {
  for_each = {for idx, cidr in var.public_subnet_cidrs : idx => cidr}

  vpc_id = aws_vpc.demo-vpc.id
  cidr_block = each.value
  availability_zone = var.azs[each.key]
  map_public_ip_on_launch = true
  tags = merge (
    var.tags,
    {
        Name = "${var.vpc_name}-public-${var.azs[each.key]}"
    }

  )
}



resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }

  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = each.value
  availability_zone = var.azs[ each.key ]
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-${var.azs[each.key]}"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-igw"
    }
  )
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-rt-public"
    }
  )
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway && var.single_nat_gateway ? 1 : length(var.azs)
  #vpc   = true
}
resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway && var.single_nat_gateway ? 1 : length(var.azs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[ tostring(count.index) ].id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-nat-${count.index}"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-rt-private"
    }
  )
}

resource "aws_route" "private_outbound" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.enable_nat_gateway ? aws_nat_gateway.this[0].id : null
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
