terraform { 
  cloud { 
    
    organization = "siwoww-terransible" 

    workspaces { 
      name = "dev"
    }

  } 
}