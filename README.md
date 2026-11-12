# Subtitle Renamer

Subtitle Renamer is a PowerShell utility that matches `.srt` subtitle files to video files and names the subtitles to match the videos. This helps media players automatically recognize the corresponding subtitle.

## Quick Start

```powershell
. .\Scripts\RenameSrtFiles.ps1
Rename-SrtFiles -VideoPath "D:\FavoriteShow\Season 2"
```

## How matching works

Files are assumed to belong together. A single video and subtitle always match, regardless of their names. With multiple files,
matching uses exact filenames, season/episode numbers, or filename prefixes; show names are ignored.

Subtitle output is always placed in the video folder. When the source subtitles are already in that folder, the selected files are renamed in place. When subtitles are in another folder, matching files are copied to the video folder and the originals are left unchanged.

## Documentation

See [USAGE.md](USAGE.md) for requirements, loading the function from your PowerShell profile, matching details, and troubleshooting.

## Tests

From the repository root, run the regression suite with Pester 3.4.0:

```powershell
Import-Module Pester -RequiredVersion 3.4.0
Invoke-Pester -Script .\Tests\RenameSrtFiles.Tests.ps1
```

The tests use isolated temporary files in Pester's `TestDrive`; no personal media files are needed.