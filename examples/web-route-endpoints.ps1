$path = Split-Path -Parent -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Path)
Import-Module "$($path)/src/Pode.psm1" -Force -ErrorAction Stop

# or just:
# Import-Module Pode

# create a server, and start listening on port 8080 and 8443
Start-PodeServer {

    # listen on localhost:8080
    Add-PodeEndpoint -Address 127.0.0.1 -Port 8080 -Protocol Http
    Add-PodeEndpoint -Address 127.0.0.2 -Port 8080 -Protocol Http

    # set view engine to pode
    Set-PodeViewEngine -Type Pode

    # GET request for web page
    Add-PodeRoute -Method Get -Path '/' -ScriptBlock {
        Write-PodeViewResponse -Path 'simple' -Data @{ 'numbers' = @(1, 2, 3); }
    }

    # GET request to download a file
    Add-PodeRoute -Method Get -Path '/download' -ScriptBlock {
        Set-PodeResponseAttachment -Path 'Anger.jpg'
    }

    # GET request with parameters
    Add-PodeRoute -Method Get -Path '/:userId/details' -ScriptBlock {
        param($event)
        Write-PodeJsonResponse -Value @{ 'userId' = $event.Parameters['userId'] }
    }

    # ALL requests for 127.0.0.2 to 127.0.0.1
    Add-PodeRoute -Method * -Path * -Endpoint 127.0.0.2 -ScriptBlock {
        Move-PodeResponseUrl -Domain 127.0.0.1
    }

}