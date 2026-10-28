# function ConvertSubtitleNamesToVideoNames ([string]$VideoPath, [string]$SubtitlesPath)
# {

While($true){
    $VideoPath = Read-Host "Enter path for video file(s)"
    $SubtitlesPath = Read-Host "Enter path for subtitle file(s)"

    $VideoFiles = ls $VideoPath\*.mp4
    $SubtitleFiles = ls $SubtitlesPath\*.srt
    
    # check if count of videos is equal to count of subs
    if($VideoFiles.Count -ne $SubtitleFiles.Count){
      Write-Host "The number of video files $($VideoFiles.Count) is not equal to the number of subtitle files $($SubtitleFiles.Count)"
      Return
    }
    
    
    # print final check of matching files
    for($i = 0; $i -lt $VideoFiles.Count; $i++){
     $checkFileMatch = $VideoFiles[$i].BaseName + " ###->-### " + $SubtitleFiles[$i].BaseName
     echo $checkFileMatch
    }
    
    # ask for final ok
    $confirmation = Read-Host "Are you Sure You Want To Proceed"
    if ($confirmation -ne 'y') {
        Return
    }
    
    # copy paste subs to folder with new name
    
    Write-Host "so far so good, but not doing anything yet"
    
    
    for($i = 0; $i -lt $VideoFiles.Count; $i++){
    
        $newSubtitleFileName = $VideoFiles[$i].BaseName + ".srt"
        $destination = $VideoPath + "\" + $newSubtitleFileName
        Write-Host "New subtitle file path and name = $destination"
        cp $SubtitleFiles[$i] $destination
    }

    Return
}

# }