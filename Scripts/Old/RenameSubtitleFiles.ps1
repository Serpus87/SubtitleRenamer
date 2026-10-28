# go to dir
cd ..

# get subtitle files and movie files
$originalSubtitles = ls *.srt
$videoFiles = ls *.avi
if($videoFiles.Count -eq 0){
    $videoFiles = ls *.mp4
}
if($videoFiles.Count -eq 0){
    $videoFiles = ls *.mkv
}

# use if statement to make idiot-proof
if($originalSubtitles.Count -eq $videoFiles.Count)
{
    # rename subtitle files to match video files with additional appendix
    For ($i=0; $i -lt $originalSubtitles.Count; $i++) {
        cp $originalSubtitles[$i].Name $($videoFiles[$i].Name+"_copy")
    }

    # rename additional appendix to correct file extension
    Get-ChildItem *.avi_copy | Rename-Item -NewName { $_.Name -replace '.avi_copy','.srt' }
    Get-ChildItem *.mp4_copy | Rename-Item -NewName { $_.Name -replace '.mp4_copy','.srt' }
    Get-ChildItem *.mkv_copy | Rename-Item -NewName { $_.Name -replace '.mkv_copy','.srt' }

    # remove original subtitle files
    rm $originalSubtitles
}

ls

