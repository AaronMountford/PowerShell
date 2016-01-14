Function SearchForRars( $path, $searchTerm, $excludePaths ) {
    $arrOutput = @()

    Get-ChildItem $path | ForEach-Object {
        $pathParts = $_.FullName.substring($path.Length).split("\")
        If ( ! ($excludePaths | where { $pathParts -like $_ } ) ) { 
        #    Write-Host $_.FullName -ForegroundColor Cyan
        
            If (Test-Path $_.FullName -PathType Container) {
                    #Write-Host Folder: $_.Name -ForegroundColor Cyan
                    SearchForRars $_.FullName $searchTerm $excludePaths
            }
            ElseIf ( $_.Extension.ToLower() -eq $searchTerm.ToLower() ) { 
                
                If ( !  $_.Name.ToLower().Contains("-subs")) {
                    #Write-Host $_.FullName -ForegroundColor Green 
                    $arrOutput +=$_.FullName
                }
            }
            Else {
                #Write-Host $_.FullName -ForegroundColor gray
            }
        }
    }
    Return $arrOutput
} #End SearchForRars

Function Extract-Rar( $fileList, $removeIfSuccess ){

    ForEach ($rarFile in $fileList) {
        $fileObj = Get-Item $rarFile
        $rarFile = $fileObj.FullName
        $DestinationFolder = $fileObj.DirectoryName

        #Extract
        Write-Output "Extracting files into $DestinationFolder"
        &$unrar x -y $rarFile $DestinationFolder | tee-object -variable unrarOutput 
        
        #display the output of the rar process as verbose
        $unrarOutput | ForEach-Object { Write-Verbose $_ }

        if ( $LASTEXITCODE -ne 0 ) {
            # There was a problem extracting. 
            #Get-Content $unrarOutput 
            #Display errror
            Write-Error "Error extracting the .RAR file" 
        }
        else
        {
            # check $unrarOutput to remove files
            #"^All OK$"
            # Write-Host "Checking output for OK tag"  
            if ($unrarOutput -match "^All OK$" -ne $null) {
                if ($removeIfSuccess) {
                    Write-Verbose "Removing files"  
                
                    #remove rar files listed in output.
                    $unrarOutput -match "(?<=Extracting\sfrom\s)(?<rarfile>.*)$" | 
                    ForEach-Object {$_ -replace 'Extracting from ', ''} | 
                    foreach-object { get-item -LiteralPath $_ } | 
                    #Write-Host  
                    remove-item
                
                } 
            }
        }
    }
} #End Extract-Rar

Function Clean-Junk( $fileList, $toRemove ){

    ForEach( $item in $fileList) {
        $folderObj = Get-Item $item.Substring(0,$item.LastIndexOf("\"))

        Write-Host $folderObj.FullName

        Get-ChildItem $folderObj | ForEach-Object {

            Write-Host $_ -ForegroundColor Gray
        
            If (Test-Path $_.FullName -PathType Container) {
                $folderNameCheck=$_.Name
                if ( ($toRemove | where {  $folderNameCheck -like $_ } ) ) { 
                    #Write-Host $_.FullName -ForegroundColor Yellow
                    Remove-Item $_.FullName -Recurse
                }
            }

            Else {
                $extn = $_.Extension
                if ( ($toRemove | where {  $extn -like $_ } ) ) { 
                    Write-Host $_.FullName -ForegroundColor Cyan
                    Remove-Item $_.FullName
                }
            }
        }
    }
} #End Clean-Junk

$RemoveSuccessfull=$true
$unrar="C:\Program Files\WinRAR\UnRAR.exe"
$drivesToScan = Get-PSDrive
$excludes = @("Windows","Program Files","Program Files (x86)","Backup","Books","Farcry 3","virus","Games","Apps","Subs")
$includes = @(".nfo",".sfv","Sample")
$rarList = @()

# Search process
ForEach ( $drive in $drivesToScan){
    If ( ($drive.Name.Length -eq 1) -and ($drive.Used -gt 0 ) ) {
        Write-Host "Searching "($drive.Root)"..." -ForegroundColor Magenta
        $rarList += SearchForRars $drive.Root ".rar" $excludes
    }
}

$rarList | % { Write-Host $_ -ForegroundColor Green}

Extract-Rar $rarList $RemoveSuccessfull
Clean-Junk $rarList $includes

# Done
