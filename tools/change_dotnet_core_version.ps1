param([int32]$dotnet_version=1, 
      [string]$root_path)

switch ($dotnet_version) {
    1 {
        $from_netstandard="netstandard2.0"
        $to_netstandard="netstandard1.3"
        $from_coreapp="netcoreapp2.0"
        $to_coreapp="netcoreapp1.1"
    }
    2 {
        $from_netstandard="netstandard1.3"
        $to_netstandard="netstandard2.0"
        $from_coreapp="netcoreapp1.1"
        $to_coreapp="netcoreapp2.0"
    }
    default { exit -1 }
}

$csproj_files = Get-ChildItem -Path $root_path -Filter *.csproj -Recurse | Select-Object -ExpandProperty FullName

foreach ($csproj_file in $csproj_files) 
{
    $file_content = (Get-Content $csproj_file)
    if ($file_content | Select-String -Pattern $from_netstandard, $from_coreapp -CaseSensitive) {
        ($file_content | ForEach-Object { 
        $_ -replace $from_netstandard, $to_netstandard `
           -replace $from_coreapp, $to_coreapp
        } | Set-Content $csproj_file)
    }
}