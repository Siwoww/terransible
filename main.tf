#VPC(Virtual Private Cloud) - la rete isolata che comprenderà tutta l'infrastruttura di rete definita dal cidr e sarà suddivisa in subnet
resource "aws_vpc" "main-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "main-vpc-${random_id.random.dec}"
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
    Name = "terransible-igw-${random_id.random.dec}"
  }
}

#Routing table per l'instradamento del traffico di rete della VPC
resource "aws_route_table" "main-public-rt" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "main-public"
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
  cidr_block = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true # associa IP pubblico alle istanze che ne fanno parte
  availability_zone = data.aws_availability_zones.available.names[count.index]

  count = 2

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = var.private_subnet_cidr

  tags = {
    Name = "private-subnet"
  }
}

resource "random_id" "random" {
  byte_length = 2
}