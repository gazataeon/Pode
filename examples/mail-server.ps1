$path = Split-Path -Parent -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Path)
Import-Module "$($path)/src/Pode.psm1" -Force -ErrorAction Stop

# or just:
# Import-Module Pode

# create a server, and start listening on port 25
Start-PodeServer -Threads 2 {

    Add-PodeEndpoint -Address localhost -Protocol SMTP

    # allow the local ip
    Add-PodeAccessRule -Access Allow -Type IP -Values 127.0.0.1

    # setup an smtp handler
    Add-PodeHandler -Type Smtp -Name 'Main' -ScriptBlock {
        param($e)
        Write-Host $e.Email.From
        Write-Host $e.Email.To
        Write-Host $e.Email.Data
    }

}