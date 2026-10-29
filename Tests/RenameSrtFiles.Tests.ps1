. (Join-Path $PSScriptRoot '..\Scripts\RenameSrtFiles.ps1')

Describe 'Rename-SrtFiles matching' {
    BeforeEach {
        $caseDirectory = (New-Item -ItemType Directory -Path (Join-Path 'TestDrive:\' ([guid]::NewGuid().ToString()))).FullName
        $videoDirectory = (New-Item -ItemType Directory -Path (Join-Path $caseDirectory 'Videos')).FullName
        $subtitleDirectory = (New-Item -ItemType Directory -Path (Join-Path $caseDirectory 'Subtitles')).FullName
        Mock Read-Host {
            if ($Prompt -like 'Select*') {
                throw 'Unexpected ambiguous match in test.'
            }
            'y'
        }
        Mock Write-Host {}
        Mock Write-Warning {}
    }

    function New-MatchingFixture {
        param([string[]]$Videos, [string[]]$Subtitles)

        foreach ($videoName in $Videos){
            New-Item -ItemType File -Path (Join-Path $videoDirectory $videoName) | Out-Null
        }

        foreach ($subtitleName in $Subtitles){
            Set-Content -LiteralPath (Join-Path $subtitleDirectory $subtitleName) -Value $subtitleName
        }
    }

    It 'renames a subtitle file with a matching video file' {
        New-MatchingFixture -Videos @('Video.mkv') -Subtitles @('Subtitle.srt')

        Rename-SrtFiles -VideoPath $videoDirectory -SubtitlePath $subtitleDirectory

        Test-Path -LiteralPath (Join-Path $videoDirectory 'Subtitle.srt') | Should Be $false
        Test-Path -LiteralPath (Join-Path $videoDirectory 'Video.srt') | Should Be $true
    }
}