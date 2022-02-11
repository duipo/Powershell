# Check for idx.ini file in all hard drives

Get-ChildItem -Recurse -Filter "idx.ini" -File -Path "C:\" -ErrorAction SilentlyContinue > C:\asus_report.txt

Exit
