function New-HaloPSATicket {
  [CmdletBinding()]
  param (
    $title,
    $description,
    $client
  )
  #Get Halo PSA Token based on the config we have.
  $Table = Get-CIPPTable -TableName Extensionsconfig
  $Configuration = ((Get-CIPPAzDataTableEntity @Table).config | ConvertFrom-Json).HaloPSA

  $token = Get-HaloToken -configuration $Configuration
  $Object = [PSCustomObject]@{
    files                      = $null
    usertype                   = 1
    userlookup                 = @{
      id            = -1
      lookupdisplay = "Enter Details Manually"
    }
    client_id                  = $client
    site_id                    = $null
    user_name                  = $null
    reportedby                 = $null
    summary                    = $title
    details_html               = $description
    donotapplytemplateintheapi = $true
    attachments                = @()
  }

  if ($Configuration.TicketType) {
    $object | Add-Member -MemberType NoteProperty -Name "tickettype_id" -Value $Configuration.TicketType
  }
  #use the token to create a new ticket in HaloPSA
  $body = ConvertTo-Json -Compress -Depth 10 -InputObject @($Object)


  Write-Host "Sending ticket to HaloPSA"
  Write-Host $body

  $Ticket = Invoke-RestMethod -Uri "$($Configuration.ResourceURL)/Tickets" -ContentType 'application/json; charset=utf-8' -Method Post -Body $body -Headers @{Authorization = "Bearer $($token.access_token)" }


}