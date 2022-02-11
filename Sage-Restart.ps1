# Sage Restart Script

# Kill Sage processes
# Sage Control v24
Stop-Process -Name sg50CtrlSvc_v24 -Force

# Sage Service v24
Stop-Process -Name sg50svc_v24 -Force

# Sage Control v26
Stop-Process -Name sg50CtrlSvc_v26 -Force

# Sage Service v26
Stop-Process -Name sg50svc_v26 -Force

# Sage Control v27
Stop-Process -Name Sage.UK.Accounts50.Data.Service.Control_v27 -Force

# Sage Service v27
Stop-Process -Name sg50svc_v27 -Force

# Starting Services
# Sage Control v24
Start-Service -Name "Sage 50 Accounts Control v24"

# Sage Service v24
Start-Service -Name "Sage 50 Accunts Service v24"

# Sage Control v26
Start-Service -Name "Sage 50 Accounts Control v26"

# Sage Service v26
Start-Service -Name "Sage 50 Accunts Service v26"

# Sage Control v27
Start-Service -Name "Sage 50 Accounts Control v27"

# Sage Service v27
Start-Service -Name "Sage 50 Accunts Service v27"

Exit
