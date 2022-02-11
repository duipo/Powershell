<#
- Remove Windows Apps
- Revision: 1.0

Can be used to cycle through array and remove all Windows Apps
#>

$Apps = @(
  "*AdobeSystemsIncorporated.AdobePhotoshopExpress*",
  "*AdobeSystemsIncorporated.AdobePhotoshopExpress*",
  "*Microsoft.Asphalt8Airborne*",
  "*king.com.CandyCrushSodaSaga*",
  "*Microsoft.DrawboardPDF*",
  "*Facebook*",
  "*BethesdaSoftworks.FalloutShelter*",
  "*FarmVille2CountryEscape*",
  "*Microsoft.WindowsFeedbackHub*",
  "*Microsoft.Getstarted*",
  "*MinecraftUWP*",
  "*PandoraMediaInc*",
  "*Microsoft.BingNews*",
  "*Microsoft.MicrosoftOfficeHub*",
  "*Netflix*",
  "*flaregamesGmbH.RoyalRevolt2*",
  "*Microsoft.SkypeApp*",
  "*AutodeskSketchBook*",
  "*Twitter*",
  "*Microsoft.XboxApp*",
  "*XboxOneSmartGlass*",
  "*Microsoft.XboxSpeechToTextOverlay*"
)

ForEach ($App in $Apps)
{
  Get-AppxPackage & $App & | Remove-AppxPackage
}

Exit
