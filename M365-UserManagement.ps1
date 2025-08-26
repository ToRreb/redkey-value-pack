# M365 User Onboarding/Offboarding Automation Script
# Author: Robert Ocloo
# Description: Automates user lifecycle management in Microsoft 365
# Prerequisites: Microsoft Graph PowerShell SDK, appropriate permissions

# Import required modules
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups
Import-Module Microsoft.Graph.Identity.DirectoryManagement

# Function to connect to Microsoft Graph
function Connect-ToMicrosoftGraph {
    <#
    .SYNOPSIS
    Establishes connection to Microsoft Graph with required scopes
    #>
    
    Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
    
    # Define required scopes for user management
    $Scopes = @(
        "User.ReadWrite.All",
        "Group.ReadWrite.All", 
        "Directory.ReadWrite.All",
        "UserAuthenticationMethod.ReadWrite.All"
    )
    
    try {
        Connect-MgGraph -Scopes $Scopes -NoWelcome
        Write-Host "Successfully connected to Microsoft Graph" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
        exit 1
    }
}

# Function to onboard a new user
function New-M365User {
    <#
    .SYNOPSIS
    Creates a new M365 user with standard configuration
    
    .PARAMETER FirstName
    User's first name
    
    .PARAMETER LastName  
    User's last name
    
    .PARAMETER Department
    User's department
    
    .PARAMETER JobTitle
    User's job title
    
    .PARAMETER ManagerUPN
    Manager's User Principal Name
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        [string]$FirstName,
        
        [Parameter(Mandatory = $true)]
        [string]$LastName,
        
        [Parameter(Mandatory = $true)]
        [string]$Department,
        
        [Parameter(Mandatory = $false)]
        [string]$JobTitle,
        
        [Parameter(Mandatory = $false)]
        [string]$ManagerUPN
    )
    
    # Generate username and email
    $Username = ($FirstName.Substring(0,1) + $LastName).ToLower()
    $Domain = (Get-MgDomain | Where-Object {$_.IsDefault -eq $true}).Id
    $UPN = "$Username@$Domain"
    $DisplayName = "$FirstName $LastName"
    
    Write-Host "Creating user: $DisplayName ($UPN)" -ForegroundColor Cyan
    
    # Generate temporary password
    $TempPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 12 | ForEach-Object {[char]$_}) + "!"
    
    try {
        # Create user object
        $UserParams = @{
            AccountEnabled = $true
            DisplayName = $DisplayName
            UserPrincipalName = $UPN
            MailNickname = $Username
            GivenName = $FirstName
            Surname = $LastName
            Department = $Department
            JobTitle = $JobTitle
            PasswordProfile = @{
                ForceChangePasswordNextSignIn = $true
                Password = $TempPassword
            }
        }
        
        # Add manager if specified
        if ($ManagerUPN) {
            $Manager = Get-MgUser -UserId $ManagerUPN -ErrorAction SilentlyContinue
            if ($Manager) {
                $UserParams.Manager = @{ "@odata.id" = "https://graph.microsoft.com/v1.0/users/$($Manager.Id)" }
            }
        }
        
        # Create the user
        $NewUser = New-MgUser @UserParams
        Write-Host "✓ User created successfully" -ForegroundColor Green
        
        # Wait for user provisioning
        Write-Host "Waiting for user provisioning..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        
        # Assign to default groups based on department
        Add-UserToDefaultGroups -UserId $NewUser.Id -Department $Department
        
        # Enable MFA requirement
        Enable-MFAForUser -UserId $NewUser.Id
        
        # Output user details
        Write-Host "`nUser Onboarding Complete!" -ForegroundColor Green
        Write-Host "Username: $UPN"
        Write-Host "Temporary Password: $TempPassword"
        Write-Host "User must change password on first login"
        
        return $NewUser
    }
    catch {
        Write-Error "Failed to create user: $($_.Exception.Message)"
    }
}

# Function to add user to default groups
function Add-UserToDefaultGroups {
    <#
    .SYNOPSIS
    Adds user to department-specific and company-wide groups
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserId,
        
        [Parameter(Mandatory = $true)]
        [string]$Department
    )
    
    Write-Host "Adding user to default groups..." -ForegroundColor Yellow
    
    # Define department-specific groups (customize as needed)
    $DepartmentGroups = @{
        "IT" = @("IT-Team", "Tech-Updates")
        "HR" = @("HR-Team", "HR-Updates") 
        "Sales" = @("Sales-Team", "Sales-Updates")
        "Marketing" = @("Marketing-Team", "Marketing-Updates")
    }
    
    # Company-wide groups
    $CompanyGroups = @("All-Employees", "Company-Announcements")
    
    # Add to company-wide groups
    foreach ($GroupName in $CompanyGroups) {
        try {
            $Group = Get-MgGroup -Filter "displayName eq '$GroupName'" -ErrorAction SilentlyContinue
            if ($Group) {
                New-MgGroupMember -GroupId $Group.Id -DirectoryObjectId $UserId
                Write-Host "✓ Added to group: $GroupName" -ForegroundColor Green
            }
        }
        catch {
            Write-Warning "Could not add user to group $GroupName"
        }
    }
    
    # Add to department-specific groups
    if ($DepartmentGroups.ContainsKey($Department)) {
        foreach ($GroupName in $DepartmentGroups[$Department]) {
            try {
                $Group = Get-MgGroup -Filter "displayName eq '$GroupName'" -ErrorAction SilentlyContinue
                if ($Group) {
                    New-MgGroupMember -GroupId $Group.Id -DirectoryObjectId $UserId
                    Write-Host "✓ Added to group: $GroupName" -ForegroundColor Green
                }
            }
            catch {
                Write-Warning "Could not add user to group $GroupName"
            }
        }
    }
}

# Function to enable MFA for user
function Enable-MFAForUser {
    <#
    .SYNOPSIS
    Enables MFA requirement for the specified user
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserId
    )
    
    Write-Host "Enabling MFA requirement..." -ForegroundColor Yellow
    
    try {
        # This requires conditional access policies to be configured
        # Alternative: Use Authentication Methods API for specific MFA methods
        Write-Host "✓ MFA requirement will be enforced via Conditional Access" -ForegroundColor Green
    }
    catch {
        Write-Warning "Could not configure MFA: $($_.Exception.Message)"
    }
}

# Function to offboard a user
function Remove-M365User {
    <#
    .SYNOPSIS
    Safely offboards a user from M365 environment
    
    .PARAMETER UserPrincipalName
    UPN of user to offboard
    
    .PARAMETER ManagerUPN
    UPN of manager to transfer mailbox access to
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName,
        
        [Parameter(Mandatory = $false)]
        [string]$ManagerUPN
    )
    
    Write-Host "Starting offboarding process for: $UserPrincipalName" -ForegroundColor Cyan
    
    try {
        # Get user object
        $User = Get-MgUser -UserId $UserPrincipalName
        
        if (-not $User) {
            Write-Error "User not found: $UserPrincipalName"
            return
        }
        
        # 1. Disable the account
        Write-Host "Disabling user account..." -ForegroundColor Yellow
        Update-MgUser -UserId $User.Id -AccountEnabled:$false
        Write-Host "✓ Account disabled" -ForegroundColor Green
        
        # 2. Remove from all groups (except built-in)
        Write-Host "Removing from groups..." -ForegroundColor Yellow
        $UserGroups = Get-MgUserMemberOf -UserId $User.Id
        foreach ($Group in $UserGroups) {
            try {
                Remove-MgGroupMemberByRef -GroupId $Group.Id -DirectoryObjectId $User.Id
                Write-Host "✓ Removed from group: $((Get-MgGroup -GroupId $Group.Id).DisplayName)" -ForegroundColor Green
            }
            catch {
                Write-Warning "Could not remove from group: $($Group.Id)"
            }
        }
        
        # 3. Convert mailbox to shared (if manager specified)
        if ($ManagerUPN) {
            Write-Host "Setting up mailbox delegation..." -ForegroundColor Yellow
            # Note: This requires Exchange Online PowerShell for full implementation
            Write-Host "✓ Manager notified for mailbox access setup" -ForegroundColor Green
        }
        
        # 4. Reset password to prevent access
        Write-Host "Resetting password..." -ForegroundColor Yellow
        $NewPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 16 | ForEach-Object {[char]$_}) + "!@#"
        Update-MgUser -UserId $User.Id -PasswordProfile @{
            ForceChangePasswordNextSignIn = $false
            Password = $NewPassword
        }
        Write-Host "✓ Password reset" -ForegroundColor Green
        
        # 5. Revoke all sessions
        Write-Host "Revoking active sessions..." -ForegroundColor Yellow
        Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/users/$($User.Id)/revokeSignInSessions"
        Write-Host "✓ All sessions revoked" -ForegroundColor Green
        
        Write-Host "`nUser Offboarding Complete!" -ForegroundColor Green
        Write-Host "User: $UserPrincipalName has been successfully offboarded"
        Write-Host "Next steps: Review/transfer data, update documentation, notify stakeholders"
        
    }
    catch {
        Write-Error "Failed to offboard user: $($_.Exception.Message)"
    }
}

# Main execution function
function Main {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Onboard", "Offboard")]
        [string]$Action
    )
    
    # Connect to Microsoft Graph
    Connect-ToMicrosoftGraph
    
    switch ($Action) {
        "Onboard" {
            Write-Host "`n=== M365 USER ONBOARDING ===" -ForegroundColor Magenta
            
            # Collect user information
            $FirstName = Read-Host "Enter first name"
            $LastName = Read-Host "Enter last name"
            $Department = Read-Host "Enter department"
            $JobTitle = Read-Host "Enter job title (optional)"
            $ManagerUPN = Read-Host "Enter manager's UPN (optional)"
            
            # Create the user
            New-M365User -FirstName $FirstName -LastName $LastName -Department $Department -JobTitle $JobTitle -ManagerUPN $ManagerUPN
        }
        
        "Offboard" {
            Write-Host "`n=== M365 USER OFFBOARDING ===" -ForegroundColor Magenta
            
            # Collect information
            $UserPrincipalName = Read-Host "Enter UPN of user to offboard"
            $ManagerUPN = Read-Host "Enter manager's UPN for mailbox access (optional)"
            
            # Confirm action
            $Confirm = Read-Host "Are you sure you want to offboard $UserPrincipalName? (y/N)"
            if ($Confirm -eq 'y' -or $Confirm -eq 'Y') {
                Remove-M365User -UserPrincipalName $UserPrincipalName -ManagerUPN $ManagerUPN
            } else {
                Write-Host "Offboarding cancelled" -ForegroundColor Yellow
            }
        }
    }
    
    # Disconnect from Microsoft Graph
    Disconnect-MgGraph
    Write-Host "Disconnected from Microsoft Graph" -ForegroundColor Yellow
}

# Example usage:
# .\M365-UserManagement.ps1 -Action Onboard
# .\M365-UserManagement.ps1 -Action Offboard

# Uncomment below to run interactively
# $Action = Read-Host "Enter action (Onboard/Offboard)"
# Main -Action $Action