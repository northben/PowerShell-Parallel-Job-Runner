# PowerShell-Parallel-Task-Runner
Simple PowerShell script to run multiple commands concurrently

## Set up ##
1. This script writes to the Windows Application Event Log. So first, you'll need to create a log source: `New-EventLog -LogName Application -Source "PowerShell Job Runner"`
2. Customize how many jobs to run in parallel with the `$parallelCount` variable
3. I've included some sample jobs at the beginning of the file. Customize to your own needs.
