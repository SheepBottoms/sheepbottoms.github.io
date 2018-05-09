[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") |
Out-Null

function openDatePicker()
{
    $form = New-Object Windows.Forms.Form 

    $form.Text = "Select a Date" 
    $form.Size = New-Object Drawing.Size @(243,230) 
    $form.StartPosition = "CenterScreen"

    $calendar = New-Object System.Windows.Forms.MonthCalendar 
    $calendar.ShowTodayCircle = $False
    $calendar.MaxSelectionCount = 1
    $form.Controls.Add($calendar) 

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(38,165)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Point(113,165)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = "Cancel"
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $CancelButton
    $form.Controls.Add($CancelButton)

    $form.Topmost = $True

    $result = $form.ShowDialog() 

    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $date = $calendar.SelectionStart
        return $date.ToString("yyyyMMdd")
    }
}

function Get-FileName($initialDirectory)
{   
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    ##$OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "Word Docs (*.docx)| *.docx"
    $OpenFileDialog.ShowDialog() | Out-Null
    return $OpenFileDialog.filename
}

function YesNoPrompt($title, $message, $yesMes)
{
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        $yesMes
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "Cancel."
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = $host.ui.PromptForChoice($title, $message, $options, 0)
    return $result
}

function gitCommit($commitText)
{
    git add .
    git commit -m $commitText
    git push
}

## Start Jekyll
Write-Host "Starting Jekyll..."
$jekyll = Start-Process jekyll -ArgumentList "serve" -WorkingDirectory "." -PassThru

$blogPostName = Read-Host -Prompt 'Input name of the blog post'
$tripName = 'Japan 2018'
$blogFileLocation = '.'

$wordDoc = Get-FileName -initialDirectory "C:\Users\james\repos"
$dateTag = openDatePicker

& .\BlogFormatter\BlogFormatter.exe $wordDoc $tripName $blogPostName $blogFileLocation $dateTag

$title = "Ready to publish the post? (http://localhost:4000/posts)"
$message = "Publish to GitHub?"
$yesMes = "Publishes to GitHub."
$result = YesNoPrompt($title, $message, $yesMes)

If ($result -eq 0)
{
    Write-Host "Checking post in..."
    $commitText = "New blog post: $blogPostName"
    gitCommit($commitText)    
}

Stop-Process -Id $jekyll.Id
