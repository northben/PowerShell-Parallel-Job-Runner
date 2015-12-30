$parallelCount = 2
$jobList = New-Object System.Collections.ArrayList
$jobStatus = New-Object System.Collections.ArrayList

# Create 3 jobs
$command = "start-sleep -seconds 10"
1..3 | % { $null = $jobList.Add([ScriptBlock]::Create($command)) }

$eventLogParams = @{
  'LogName' = 'Application';
  'Source' = "PowerShell Job Runner";
  'EntryType' = 'Information';
}

Write-EventLog @eventLogParams -EventId 1 -Message "starting jobs"

while ($jobList.Count -gt 0 -or $jobStatus.Count -gt 0) {
    $runCount = $([Math]::Min($parallelCount,$jobList.Count))
    foreach($i in 1..$runCount) {
        if($runCount -gt 0) {
            $j = Start-Job -ScriptBlock $jobList[0]
            $null = $jobStatus.Add($j)
            Write-EventLog @eventLogParams -EventId 2 -Message "started job: $($jobList[0])"
            $jobList.Remove($jobList[0])
        }
    }
    $null = Wait-Job -Job $jobStatus -Any
    $completedJob = $jobStatus | ? {$_.State -eq "Completed"}
    if($completedJob) {
        Write-EventLog @eventLogParams -EventId 3 -Message "Finished job: $($($completedJob.Command))"
        $runTime = $completedJob.PSEndTime - $completedJob.PSBeginTime
        Write-EventLog @eventLogParams -EventId 5 -Message "Total run time: $runTime. job: $($($completedJob.Command))"
        Receive-Job -Job $completedJob
        $completedJob | % { $jobStatus.Remove($_) }
    }
}
Write-EventLog @eventLogParams -EventId 4 -Message "Finished"
