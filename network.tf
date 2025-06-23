#VPC(Virtual Private Cloud) - la rete isolata che comprenderà tutta l'infrastruttura di rete definita dal cidr e sarà suddivisa in subnet
resource "aws_vpc" "main-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "main-vpc-${random_id.random.dec}-${var.environment}"
  }

  lifecycle {
    create_before_destroy = true #Essendo l-igw dipendente dalla vpc, nel momento in cui si prova a cambiare un attributo che comporta la distruzione/creazione,
                                 #la distruzione si blocca. Inserendo invece il create_before_destroy l'igw viene associato alla nuova risorsa creata, staccandola dalla vecchia,
                                 #rendendone possibile la distruzione
  } 
}

#Internet gw  - funge da gateway con l'esterno della VPC correlata
resource "aws_internet_gateway" "main-internet-gateway" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "terransible-igw-${random_id.random.dec}-${var.environment}"
  }
}

#Routing table per l'instradamento del traffico di rete della VPC
resource "aws_route_table" "main-public-rt" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "${var.environment}-public"
  }
}

#Singola regola di routing associata alla routing table - questa nello specifico crea la regola di instradamento verso il gateway permettendo connessioni internet
resource "aws_route" "default-route" {
  route_table_id = aws_route_table.main-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main-internet-gateway.id
}

#Routing table di default che viene assegnata automaticamente alle subnet senza associazioni
resource "aws_default_route_table" "main_private_rt" {
  default_route_table_id = aws_vpc.main-vpc.default_route_table_id
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = cidrsubnet(aws_vpc.main-vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true # associa IP pubblico alle istanze che ne fanno parte
  availability_zone = local.available_zone[count.index]

  count = var.public_subnets_number

  tags = {
    Name = "public-subnet-${count.index + 1}-${var.environment}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main-vpc.id
  #cidr_block = var.private_subnet_cidr[count.index]
  cidr_block = cidrsubnet(aws_vpc.main-vpc.cidr_block, 8, length(local.available_zone) + count.index)
  map_public_ip_on_launch = true # associa IP pubblico alle istanze che ne fanno parte
  availability_zone = local.available_zone[count.index]

  count = var.private_subnets_number

  tags = {
    Name = "private-subnet-${count.index + 1}-${var.environment}"
  }
}

#Associa le subnet alla routing table
resource "aws_route_table_association" "public_subnet_assoc" {
  count = length(local.available_zone)
  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.main-public-rt.id
}

resource "aws_security_group" "main-sg" {
  name = "public-sg"
  vpc_id = aws_vpc.main-vpc.id
  description = "Security group for public instances"

  tags = {
    Name = "public-sg-${var.environment}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_all" {
  security_group_id = aws_security_group.main-sg.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "egress_all" {
  security_group_id = aws_security_group.main-sg.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "random_id" "random" {
  byte_length = 2
}