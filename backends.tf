terraform { 
  cloud { 
    
    organization = "siwoww-terransible" 

    workspaces { 
      name = var.environment
    }

  } 
}