Microsoft 365 Security Baseline Checklist
Overview
This checklist ensures your Microsoft 365 environment follows security best practices and baseline configurations. Review and implement these items regularly.

Identity & Access Management
Multi-Factor Authentication (MFA)

 Enable MFA for all admin accounts - Required for all privileged roles
 Enforce MFA for all users - Use Conditional Access policies
 Configure MFA methods - Allow app notifications, phone calls, SMS as backup
 Block legacy authentication - Disable basic auth protocols
 Review MFA bypass - Ensure no unnecessary trusted IPs or bypass policies

Conditional Access

 Create baseline Conditional Access policies

 Require MFA for all users
 Block access from unknown locations
 Require compliant devices for admin access


 Configure location-based policies - Define trusted locations
 Set device compliance requirements - Require managed/compliant devices
 Review and test policies regularly - Ensure policies work as expected

Privileged Access

 Enable Privileged Identity Management (PIM) - For eligible role assignments
 Configure admin role approvals - Require justification and approval
 Limit permanent admin assignments - Use time-bound access
 Regular admin access reviews - Quarterly review of privileged access
 Separate admin accounts - Don't use for daily activities


Email Security (Exchange Online)
Mailbox Protection

 Enable mailbox auditing - For all user mailboxes
 Configure retention policies - Meet compliance requirements
 Set up litigation hold - For key personnel if required
 Enable archive mailboxes - For long-term storage

Anti-Phishing & Spam

 Configure anti-phishing policies - Enable impersonation protection
 Set up Safe Attachments - Scan attachments for malware
 Enable Safe Links - Protect against malicious URLs
 Configure DKIM signing - Authenticate outbound emails
 Implement SPF records - Prevent email spoofing
 Set up DMARC policy - Email authentication and reporting

Mail Flow Security

 Review mail flow rules - Remove unnecessary transport rules
 Configure external sender warnings - Alert users to external emails
 Enable ATP for SharePoint/OneDrive - Scan files for threats
 Set up quarantine notifications - User and admin notifications


Data Protection
Information Protection

 Configure sensitivity labels - Classify and protect documents
 Enable auto-labeling - For sensitive content detection
 Set up data loss prevention (DLP) - Prevent data leakage
 Configure retention labels - Automatic document lifecycle
 Review sharing permissions - Limit external sharing

SharePoint & OneDrive

 Enable versioning - For document recovery
 Configure external sharing limits - Restrict to trusted domains
 Enable access reviews - Regular permission audits
 Set up alerts for sensitive activities - Monitor unusual access
 Configure device access restrictions - Limit unmanaged devices


Device Management
Microsoft Intune

 Enroll corporate devices - All company-owned devices
 Configure compliance policies - Set minimum requirements
 Deploy security baselines - Apply recommended settings
 Set up conditional access for devices - Require compliant devices
 Enable device encryption - Full disk encryption required

Application Management

 Configure app protection policies - For mobile applications
 Deploy approved applications - Standard software catalog
 Block risky applications - Prevent unauthorized software
 Regular application reviews - Remove unused applications


Monitoring & Incident Response
Logging & Monitoring

 Enable unified audit log - Capture all user activities
 Configure log retention - Meet compliance requirements
 Set up security alerts - For suspicious activities
 Enable Microsoft Defender for Office 365 - Advanced threat protection
 Configure SIEM integration - Forward logs to security tools

Security Monitoring

 Review security reports - Weekly security scorecard review
 Monitor sign-in activities - Check for unusual patterns
 Track permission changes - Alert on privilege escalation
 Review app registrations - Monitor new application approvals
 Check for data exfiltration - Large download activities

Incident Response

 Define incident response plan - Clear escalation procedures
 Test incident response - Regular tabletop exercises
 Configure emergency access accounts - Break-glass accounts
 Document recovery procedures - Step-by-step guides
 Regular security training - User awareness programs


Backup & Recovery
Data Backup

 Enable Microsoft 365 Backup - For critical data protection
 Configure backup policies - Regular automated backups
 Test restore procedures - Verify backup integrity
 Document recovery time objectives - RTO/RPO requirements
 Third-party backup solution - Consider additional protection

Business Continuity

 Create disaster recovery plan - Full environment restoration
 Test failover procedures - Regular DR testing
 Maintain offline documentation - Access during outages
 Train IT staff on procedures - Emergency response training


Compliance & Governance
Regulatory Compliance

 Identify compliance requirements - Industry-specific regulations
 Configure compliance policies - Meet regulatory standards
 Enable compliance reporting - Regular audit reports
 Conduct compliance assessments - Internal and external audits
 Maintain compliance documentation - Evidence and procedures

Governance Framework

 Define acceptable use policies - Clear user guidelines
 Regular policy reviews - Update security policies
 User training programs - Security awareness education
 Vendor management - Third-party access controls
 Change management process - Control system modifications


Review Schedule

Daily: Security alerts and incident monitoring
Weekly: Security scorecard and reports review
Monthly: Policy effectiveness review and user access audit
Quarterly: Full security assessment and policy updates
Annually: Complete security baseline review and penetration testing


Additional Resources

Microsoft 365 Security Documentation
Security Baseline for Microsoft 365
Microsoft Secure Score


Last Updated: 08/26/2025
Next Review: 09/26/2025
Document Owner: Robert Ocloo