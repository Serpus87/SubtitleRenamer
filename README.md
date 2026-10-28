# Subtitle Renamer

Subtitle Renamer is a PowerShell utility that matches `.srt` subtitle files to video files and names the subtitles to match the videos. This helps media players automatically recognize the corresponding subtitle.

The `Rename-SrtFiles` function supports video files with common extensions such as `.mp4`, `.mkv`, `.avi`, `.mov`, and `.wmv`. It previews the proposed matches and asks for confirmation before making changes.

Subtitle output is always placed in the video folder. When the source subtitles are already in that folder, the selected files are renamed in place. When subtitles are in another folder, matching files are copied to the video folder and the originals are left unchanged.

For setup, parameter details, examples, and PowerShell profile configuration, see [HOWTOUSE.md](HOWTOUSE.md).
