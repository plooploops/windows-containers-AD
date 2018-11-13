#######################
# Configure the variables below
#######################
# Local SQL instance using Windows authentication of the user running the script
$LocalSQLInstance = "sqlvm.win.local"
# Remote SQL named instance using SQL server login
$RemoteSQLInstance = "SQL16-VM01.lab.local\INSTANCE01"
$RemoteSQLUser = "localsqluser"
$RemoteSQLPassword = "Srt1234!"
# Remote SQL default MSSQLSERVER instance using sa login
$RemoteDefaultSQLInstance  = "sqlvm.win.local"
$RemoteDefaultSQLInstanceUser = "sa"
$RemoteDefaultSQLInstancePassword = "Password123!"
#####################################################################
# Nothing to change below this line, commented throughout to explain
#####################################################################
##############################################
# Checking to see if the SqlServer module is already installed, if not installing it for the current user
##############################################
$SQLModuleCheck = Get-Module -ListAvailable SqlServer
if ($SQLModuleCheck -eq $null)
{
write-host "SqlServer Module Not Found - Installing"
# Not installed, trusting PS Gallery to remove prompt on install
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# Installing module
Install-Module -Name SqlServer –Scope CurrentUser -Confirm:$false -AllowClobber
}
##############################################
# Importing the SqlServer module
##############################################
Import-Module SqlServer
##############################################
# Creating SQL Query to get the size of all DBs on each Instance
##############################################
# Change this to whatever you want to test, but this is a good one to start with!
$SQLDBSizeQuery = "SELECT
    DB_NAME(db.database_id) DatabaseName,
    (CAST(mfrows.RowSize AS FLOAT)*8)/1024 DBSizeMB,
    (CAST(mflog.LogSize AS FLOAT)*8)/1024 LogSizeMB
FROM sys.databases db
    LEFT JOIN (SELECT database_id, SUM(size) RowSize FROM sys.master_files WHERE type = 0 GROUP BY database_id, type) mfrows ON mfrows.database_id = db.database_id
    LEFT JOIN (SELECT database_id, SUM(size) LogSize FROM sys.master_files WHERE type = 1 GROUP BY database_id, type) mflog ON mflog.database_id = db.database_id"
#$SQLDBSizeQuery = "SELECT * FROM [testdb].[dbo].[testdata]"

###############################################################################
# Example 1 - Local SQL with Windows Authentication
###############################################################################
##############################################
# Testing query against Local SQL instance using Windows auth
##############################################
# Running the SQL Query, setting result of query to $False if any errors caught
Try 
{
# Setting to null first to prevent seeing previous query results
$SQLDBSizeResult = $null
# Running the query
$SQLDBSizeResult = Invoke-SqlCmd -Query $SQLDBSizeQuery -ServerInstance $LocalSQLInstance
# Setting the query result
$SQLQuerySuccess = $TRUE
}
Catch 
{
# Overwriting result if it failed
$SQLQuerySuccess = $FALSE
}
# Output of the results for you to see
"SQLInstance: $LocalSQLInstance"
"SQLQueryResult: $SQLQuerySuccess"
"SQLQueryOutput:"
$SQLDBSizeResult
###############################################################################
# Example 2 - Remote SQL with SQL User Authentication
###############################################################################
##############################################
# Testing query against Remote SQL named instance using SQL server login
##############################################
# Running the SQL Query, setting result of query to $False if any errors caaught
Try 
{
# Setting to null first to prevent seeing previous query results
$SQLDBSizeResult = $null
# Running the query
$SQLDBSizeResult = Invoke-SqlCmd -Query $SQLDBSizeQuery -ServerInstance $RemoteSQLInstance -Username $RemoteSQLUser -Password $RemoteSQLPassword
# Setting the query result
$SQLQuerySuccess = $TRUE
}
Catch 
{
# Overwriting result if it failed
$SQLQuerySuccess = $FALSE
}
# Output of the results for you to see
"SQLInstance: $RemoteSQLInstance"
"SQLQueryResult: $SQLQuerySuccess"
"SQLQueryOutput:"
$SQLDBSizeResult
###############################################################################
# Example 3 - Remote SQL with SA Authentication
###############################################################################
##############################################
# Testing query against Remote SQL default MSSQLSERVER instance using sa login
##############################################
# Running the SQL Query, setting result of query to $False if any errors caaught
Try 
{
# Setting to null first to prevent seeing previous query results
$SQLDBSizeResult = $null
# Running the query
$SQLDBSizeResult = Invoke-SqlCmd -Query $SQLDBSizeQuery -ServerInstance $RemoteDefaultSQLInstance -Username $RemoteDefaultSQLInstanceUser -Password $RemoteDefaultSQLInstancePassword
# Setting the query result
$SQLQuerySuccess = $TRUE
}
Catch 
{
# Overwriting result if it failed
$SQLQuerySuccess = $FALSE
}
# Output of the results for you to see
"SQLInstance: $RemoteDefaultSQLInstance"
"SQLQueryResult: $SQLQuerySuccess"
"SQLQueryOutput:"
$SQLDBSizeResult
##############################################
# End of script
##############################################