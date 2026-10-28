function Rename-SrtFiles {
	[CmdletBinding()]
	param(
		[Parameter(Position = 0)]
		[string]$VideoPath = (Get-Location).Path,

		[Parameter(Position = 1)]
		[string]$SubtitlePath
	)

	$videoExtensions = @('.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.mpeg', '.mpg', '.ts', '.m2ts', '.3gp', '.ogv')

	if (-not (Test-Path -LiteralPath $VideoPath -PathType Container)) {
		throw "Video folder does not exist: $VideoPath"
	}

	$resolvedVideoPath = (Resolve-Path -LiteralPath $VideoPath).Path
	if ([string]::IsNullOrWhiteSpace($SubtitlePath)) {
		$resolvedSubtitlePath = $resolvedVideoPath
	}
	elseif (Test-Path -LiteralPath $SubtitlePath -PathType Container) {
		$resolvedSubtitlePath = (Resolve-Path -LiteralPath $SubtitlePath).Path
	}
	else {
		throw "Subtitle folder does not exist: $SubtitlePath"
	}
	$sameSubtitleFolder = [System.IO.Path]::GetFullPath($resolvedVideoPath).TrimEnd('\', '/') -ieq
		[System.IO.Path]::GetFullPath($resolvedSubtitlePath).TrimEnd('\', '/')

	$videoFiles = @(
		Get-ChildItem -LiteralPath $resolvedVideoPath -File |
			Where-Object { $videoExtensions -contains $_.Extension.ToLowerInvariant() } |
			Sort-Object Name
	)
	$subtitleFiles = @(
		Get-ChildItem -LiteralPath $resolvedSubtitlePath -File -Filter '*.srt' |
			Sort-Object Name
	)

	if ($videoFiles.Count -eq 0) {
		Write-Warning "No supported video files were found in '$resolvedVideoPath'."
		return
	}
	if ($subtitleFiles.Count -eq 0) {
		Write-Warning "No .srt files were found in '$resolvedSubtitlePath'."
		return
	}

	if ($videoFiles.Count -ne $subtitleFiles.Count) {
		Write-Warning "Found $($videoFiles.Count) video file(s) and $($subtitleFiles.Count) subtitle file(s). Some videos may remain unmatched or some subtitles unused."
		if ((Read-Host 'Continue anyway? (y/N)') -notmatch '^(y|yes)$') {
			return
		}
	}

	$availableSubtitles = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
	foreach ($subtitleFile in $subtitleFiles) {
		$availableSubtitles.Add($subtitleFile)
	}

	$matchPlan = [System.Collections.Generic.List[object]]::new()
	foreach ($videoFile in $videoFiles) {
		$matchingCandidates = @(
			$availableSubtitles | Where-Object {
				$_.BaseName.Equals($videoFile.BaseName, [System.StringComparison]::OrdinalIgnoreCase) -or
				$_.BaseName.StartsWith($videoFile.BaseName, [System.StringComparison]::OrdinalIgnoreCase) -and
				$_.BaseName.Length -gt $videoFile.BaseName.Length -and
				$_.BaseName[$videoFile.BaseName.Length] -match '[ ._-]'
			}
		)

		$selectedSubtitle = $null
		if ($matchingCandidates.Count -gt 1) {
			Write-Host "`nMultiple subtitle files could match '$($videoFile.Name)':"
			for ($index = 0; $index -lt $matchingCandidates.Count; $index++) {
				Write-Host "  $($index + 1). $($matchingCandidates[$index].Name)"
			}

			do {
				$selection = Read-Host "Select a subtitle number, or 0 to cancel"
				$selectionNumber = 0
				$validSelection = [int]::TryParse($selection, [ref]$selectionNumber) -and
					$selectionNumber -ge 0 -and $selectionNumber -le $matchingCandidates.Count
				if (-not $validSelection) {
					Write-Host 'Enter one of the listed numbers.'
				}
			} until ($validSelection)

			if ($selectionNumber -eq 0) {
				Write-Host 'Cancelled; no files were renamed.'
				return
			}
			$selectedSubtitle = $matchingCandidates[$selectionNumber - 1]
		}
		elseif ($matchingCandidates.Count -eq 1) {
			$selectedSubtitle = $matchingCandidates[0]
		}
		elseif ($availableSubtitles.Count -gt 0) {
			$selectedSubtitle = $availableSubtitles[0]
		}

		if ($null -ne $selectedSubtitle) {
			$null = $availableSubtitles.Remove($selectedSubtitle)
		}

		$matchPlan.Add([pscustomobject]@{
			Video    = $videoFile
			Subtitle = $selectedSubtitle
		})
	}

	Write-Host "`nPlanned subtitle operations:"
	foreach ($match in $matchPlan) {
		$subtitleName = if ($null -eq $match.Subtitle) { '(no subtitle)' } else { $match.Subtitle.Name }
		$operation = if ($sameSubtitleFolder) { 'rename' } else { 'copy as' }
		Write-Host "  $($match.Video.Name)  <-  $subtitleName ($operation $($match.Video.BaseName).srt)"
	}
	if ($availableSubtitles.Count -gt 0) {
		Write-Host "Unused subtitle files: $((@($availableSubtitles | ForEach-Object Name)) -join ', ')"
	}

	$renamePlan = @(
		foreach ($match in $matchPlan) {
			if ($null -ne $match.Subtitle) {
				$destinationPath = Join-Path $resolvedVideoPath ($match.Video.BaseName + '.srt')
				if (-not $match.Subtitle.FullName.Equals($destinationPath, [System.StringComparison]::OrdinalIgnoreCase)) {
					[pscustomobject]@{
						Source      = $match.Subtitle
						Destination = $destinationPath
						NewName     = $match.Video.BaseName + '.srt'
						Copy        = -not $sameSubtitleFolder
					}
				}
			}
		}
	)

	$duplicateDestinations = @($renamePlan | Group-Object Destination | Where-Object Count -gt 1)
	if ($duplicateDestinations.Count -gt 0) {
		throw 'Multiple videos would produce the same subtitle filename. No files were renamed.'
	}

	foreach ($rename in $renamePlan) {
		if (Test-Path -LiteralPath $rename.Destination) {
			throw "Target already exists: $($rename.Destination). No files were renamed."
		}
	}

	if ($renamePlan.Count -eq 0) {
		Write-Host 'No renames are needed.'
		return
	}

	if ((Read-Host 'Rename these subtitle files? (y/N)') -notmatch '^(y|yes)$') {
		Write-Host 'Cancelled; no files were renamed.'
		return
	}

	foreach ($rename in $renamePlan) {
		if ($rename.Copy) {
			Copy-Item -LiteralPath $rename.Source.FullName -Destination $rename.Destination -ErrorAction Stop
			Write-Host "Copied '$($rename.Source.Name)' to '$($rename.Destination)'"
		}
		else {
			Rename-Item -LiteralPath $rename.Source.FullName -NewName $rename.NewName -ErrorAction Stop
			Write-Host "Renamed '$($rename.Source.Name)' to '$($rename.NewName)'"
		}
	}
}
