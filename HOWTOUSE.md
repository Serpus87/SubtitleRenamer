# How to Use Subtitle Renamer

`Scripts/RenameSrtFiles.ps1` defines the `Rename-SrtFiles` PowerShell function. The function scans a video folder and a subtitle folder, builds a proposed mapping, and asks for confirmation before changing any files.

## Requirements

- Windows PowerShell or PowerShell (PowerShell 5.1 or later is recommended).
- Video files directly inside the video folder. The script does not search subfolders.
- `.srt` subtitle files directly inside the subtitle folder. The script does not search subfolders.

The recognized video extensions are `.mp4`, `.mkv`, `.avi`, `.mov`, `.wmv`, `.flv`, `.webm`, `.m4v`, `.mpeg`, `.mpg`, `.ts`, `.m2ts`, `.3gp`, and `.ogv`.

## Load the Function

The file defines a function; it does not run the function automatically. Load the definition into the current PowerShell session by **dot-sourcing** the script:

```powershell
. "C:\Users\Cesar\source\repos\SubtitleRenamer\Scripts\RenameSrtFiles.ps1"
```

Replace the example path with the location where you checked out this project. The dot-source operator is the period followed by a space and then the script path. Keep the quotes if the path contains spaces.

After dot-sourcing, call the function by name:

```powershell
Rename-SrtFiles
```

Dot-sourcing makes the function available in the current PowerShell session. If you open a new session, load the file again, or configure your PowerShell profile as described below.

## Function Parameters

The function accepts two optional parameters:

| Parameter | Positional order | Default | Purpose |
| --- | ---: | --- | --- |
| `-VideoPath` | First | The current working directory | Folder containing the video files. |
| `-SubtitlePath` | Second | The value of `-VideoPath` | Folder containing the `.srt` files. |

Paths must refer to existing folders. You can use named parameters, which are easiest to read, or positional arguments.

### Use the Current Folder

With no arguments, both videos and subtitles are read from the current working directory:

```powershell
Rename-SrtFiles
```

The current working directory is the folder shown by `Get-Location`, not necessarily the folder containing the `.ps1` file.

### Specify the Video Folder

If `-SubtitlePath` is omitted, subtitles are also read from the video folder:

```powershell
Rename-SrtFiles -VideoPath "D:\Media\Season 1"
```

The equivalent positional form is:

```powershell
Rename-SrtFiles "D:\Media\Season 1"
```

### Specify Separate Video and Subtitle Folders

Use both parameters when the `.srt` files are stored elsewhere:

```powershell
Rename-SrtFiles -VideoPath "D:\Media\Season 1" -SubtitlePath "D:\Downloads\Subtitles"
```

Positional form:

```powershell
Rename-SrtFiles "D:\Media\Season 1" "D:\Downloads\Subtitles"
```

### Choose the Subtitle Folder While Using the Current Folder for Videos

To use the current folder for videos but a different folder for subtitles, specify the video folder explicitly as `.`:

```powershell
Rename-SrtFiles -VideoPath . -SubtitlePath "D:\Downloads\Subtitles"
```

## Matching and File Changes

The function sorts the video and subtitle filenames and tries to match available subtitles to each video. For episodic filenames, it first looks for a season-and-episode token such as `S01E10` in both names. The season and episode numbers are compared numerically, so `S1E10` also matches `S01E10`. For example, `Show.S01E10.1080p.mkv` can match `Show.S01E10.English.srt` even if other parts of their names differ.

If no available subtitle has the same season-and-episode token, the function checks for a direct filename match: the subtitle filename (without `.srt`) must exactly match the video filename (without its video extension), or start with that video name followed by a space, period, underscore, or hyphen. For example, `Film.en.srt` is a candidate for `Film.mkv`.

If multiple subtitles match by season and episode or by filename, the function lists them and asks you to choose one. Enter the displayed number, or enter `0` to cancel the operation.

If neither the season-and-episode nor filename checks find a candidate, the function assigns the first remaining subtitle in alphabetical order. This fallback cannot determine the true pairing from filenames alone, so carefully review the displayed plan before confirming.

If the number of video files and subtitle files differs, the function shows a warning and asks whether to continue. Answer `y` or `yes` to continue; any other response cancels. Some videos may then have no subtitle, or some subtitle files may remain unused.

Before changing anything, the function displays the proposed operations and asks for confirmation. Answer `y` or `yes` to proceed. Any other response cancels.

The resulting `.srt` files always go in the video folder:

- If the subtitle folder is the same as the video folder, the selected subtitle file is renamed in place.
- If the folders differ, the selected subtitle file is copied into the video folder with the video-matching name. The original in the subtitle folder is not changed.

The function stops before making changes if a proposed destination already exists or if multiple videos would produce the same destination filename. It does not overwrite existing files.

## Add the Function to Your PowerShell Profile

PowerShell can run commands from a profile script whenever a session starts. Adding the dot-source command to your profile loads `Rename-SrtFiles` automatically in future sessions.

First, check which profile file is used by the current PowerShell host:

```powershell
$PROFILE
```

Create the profile file if it does not exist, then open it in Notepad:

```powershell
if (-not (Test-Path -LiteralPath $PROFILE)) {
	New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}
notepad $PROFILE
```

Add this line to the profile, changing it to the actual location of the project:

```powershell
. "C:\Users\Cesar\source\repos\SubtitleRenamer\Scripts\RenameSrtFiles.ps1"
```

Save the profile. To load the change immediately into the current session, run:

```powershell
. $PROFILE
```

In new sessions, the profile runs automatically and the function is available without manually dot-sourcing the script. Windows PowerShell and PowerShell 7 can use different profile files; run `$PROFILE` in each host where you want the function available and configure that host's profile.

## Troubleshooting

**`Rename-SrtFiles` is not recognized.** The function has not been loaded into the current session. Dot-source `RenameSrtFiles.ps1` using the command above, or check that the profile contains the correct script path and has been loaded.

**A folder cannot be found.** Confirm that the paths are existing directories and that quoted paths are spelled correctly.

**A destination already exists.** The function does not overwrite an existing subtitle file. Review the files in the video folder and resolve the name conflict before running it again.

**PowerShell reports that scripts are disabled.** This is an execution-policy restriction on loading the `.ps1` file. Follow your organization's PowerShell policy or consult your administrator; avoid changing the machine-wide execution policy just for this script.
