$environmentVariables = Get-Content '.env'

$command = (
    "docker run --name functionapp -p 80:80 -d -e " + 
    ($environmentVariables -Join " -e ") + 
    " functionapp"
)
pwsh -c $command
