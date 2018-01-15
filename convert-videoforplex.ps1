$moviesAlreadyProcessed = "X:\Users\anoop\OneDrive\WindowsPowerShell\Convert-MoviesForPlex\alreadyProcessed.txt"
$moviesToBeProcessed = "X:\Users\anoop\OneDrive\WindowsPowerShell\Convert-MoviesForPlex\ToBeProcessed.txt"
$SourceFolder = "X:\users\anoop\Videos\Movies"
$handbrakecli = "C:\Program Files\Handbrake\HandBrakeCLI.exe"
$handbrakepreset = "Xbox 1080p30 Surround"

New-Item -ItemType File $moviesToBeProcessed -Force

if (Test-Path $moviesAlreadyProcessed) {
    $alreadyProcessed = Get-Content $moviesAlreadyProcessed | Sort-Object
} else {
    New-Item -ItemType File $moviesAlreadyProcessed
    "" | Out-File $moviesAlreadyProcessed
    $alreadyProcessed = Get-Content $moviesAlreadyProcessed | Sort-Object
}

$files = Get-ChildItem $SourceFolder  -recurse -Exclude *converted].mp4, *agplex.mp4  | Where-Object {$_.length -ge 100MB}

$filecount = ($files | Measure-Object).count

foreach ($file in $files){
    $file.fullname | Out-File -Append $moviesToBeProcessed
}

$toBeProcessed = get-content $moviesToBeProcessed | Sort-Object

if ($alreadyProcessed -eq $null) {
    $cmp = $toBeProcessed
}
else{
    $cmp = Compare-Object -ReferenceObject $toBeProcessed -DifferenceObject $alreadyProcessed -PassThru
}

#$files = get-childitem $SourceFolder -include *.mkv,*.avi,*.m4v,*.mp4 -recurse | where {$_.length -ge 100MB} | foreach ($_) {$_.fullname} | sort

if ($cmp) {
    $i = 0
    ForEach ($file in $cmp)
    {
        if($file.Length -gt 10){
            $fileInfo = Get-ChildItem $file

            $i++


            $oldfile = $fileInfo.DirectoryName + "\" + $fileInfo.BaseName + $fileInfo.Extension;
            $newfile = $fileInfo.DirectoryName + "\" + $fileInfo.BaseName + "[converted].mp4";
            
            #$newfile = $file + ".[converted].mp4"
            
            $progress = ($i / $filecount) * 100
            $progress = [Math]::Round($progress,2)
        
            #Clear-Host
            Write-Host -------------------------------------------------------------------------------
            Write-Host Handbrake Batch Encoding
            Write-Host "Processing - $oldfile"
            Write-Host "Writing to $newfile"
            Write-Host "File $i of $filecount - $progress%"
            Write-Host -------------------------------------------------------------------------------
            
            #Start-Process "C:\Program Files\HandBrake\HandBrakeCLI.exe" -ArgumentList "-i `"$file`" -t 1 --angle 1 -c 1 -o `"$newfile`" -f mp4  -O  --decomb --modulus 16 -e x264 -q 32 --vfr -a 1 -E lame -6 dpl2 -R Auto -B 48 -D 0 --gain 0 --audio-fallback ffac3 --x264-preset=veryslow  --x264-profile=high  --x264-tune=`"animation`"  --h264-level=`"4.1`"  --verbose=0" -Wait -NoNewWindow


            #start-process "$handbrakecli"  -ArgumentList "-i `"$file`" -o `"$newfile`" --use-opencl --preset `"$handbrakepreset`"" -Wait -NoNewWindow

            start-process "$handbrakecli"  -ArgumentList "-i `"$file`" -o `"$newfile`" --verbose=0 --preset `"$handbrakepreset`"" -Wait -NoNewWindow

            

            "$file" | Out-File -FilePath $moviesAlreadyProcessed -Append

            start-sleep 2
        }
    }
}
