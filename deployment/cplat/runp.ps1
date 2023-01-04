echo runp
if ($env:podID -eq $null) {
  if (($env:snpMode -eq $null) -or ($env:snpMode -eq 'non-snp'))
  {
    echo 'non SNP mode'
    $env:podID = C:\ContainerPlat\crictl.exe runp --runtime runhcs-lcow .\pod.json
  }
  else
  {
    echo 'SNP mode'
    $env:podID = C:\ContainerPlat\crictl.exe runp --runtime runhcs-lcow .\pod.snp.json
  }
  echo "POD ID = $env:podID"
}
  else
{
  echo "There is alread a pod running, ID = $env:podID"
}

