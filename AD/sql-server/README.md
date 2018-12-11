# Adding an SQL Server

At this time, we have not provided a template to add and configure an SQL server on the domain.  However we have provided some information about setting up a SQL Server to use as an resource to connect to.

You can add in the SQL server however you choose, however it must be domain joined.  If you use the SQL Server image that's available in Azure, you may have issue accessing the default instance after you join the server to the domain. It's recommended turn on SA access on before domain joining the machine.

However, if you have already domain joined the machine and can not access the SQL Server, there's a workaround for correcting access issues here: [SQL Server Access Notes](https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/connect-to-sql-server-when-system-administrators-are-locked-out?view=sql-server-2017).

## Setup for the SQL VM.

You can use the Portal to deploy a SQL VM.

![Pick SQL](../media/iis-sf-cluster/sf-cluster-deploy-sql-0.png)

Make sure we choose settings for size and network.

![Pick SQL Size](../media/iis-sf-cluster/sf-cluster-deploy-sql-1.png)

Make sure we choose settings for network.
![Pick SQL Network](../media/iis-sf-cluster/sf-cluster-deploy-sql-2.png)

Make sure we choose settings for SQL Server.
![Pick SQL Server Settings](../media/iis-sf-cluster/sf-cluster-deploy-sql-3.png)

Upon reviewing, we should be able to deploy SQL.
![Validate and Deploy](../media/iis-sf-cluster/sf-cluster-deploy-sql-4.png)

## SQL Server SQL Authentication

If we want to enable a System Administrator account in SQL, we could use T-SQL to accomplish it.

[Change SQL Server Authentication Mode](https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/change-server-authentication-mode?view=sql-server-2017)

```SQL
ALTER LOGIN sa ENABLE ;  
GO  
ALTER LOGIN sa WITH PASSWORD = '<enterStrongPasswordHere>' ;  
GO 
```
## Testing with SQL

From any other VM or cluster node, you can test SQL connectivity.

We can fill in the details to test SQL connectivity with this [Test Script](../AD/sf-cluster/testsql.ps1)

## Sample Data

The SQL Server must be populated with some sample data, schema, and logins. You can find some basic sample data in the [script](../AD/data/testdata.sql).  

We'll also want to include the backend gMSA account as part of the SQL logins and have "datareader/datawriter" rights to the testdb.

If we've populated it correctly, we should see our table with some data in it.

![SQL Sample data](../media/iis/data.png)

```SQL
SELECT *
  FROM [testdb].[dbo].[testdata]
```

## Test Users (Optional)
We can add test users to the DC. his is also in the [domain basics script](../AD/ad-new-forest-domain/domainbasics.ps1)

```powershell
New-ADUser -Name User1 -PasswordNeverExpires $true -AccountPassword ("Password123!" | ConvertTo-SecureString -AsPlainText -Force) -Enabled $true -UserPrincipalName User1@win.local	
	$user1 = Get-ADUser User1
	New-ADUser -Name User2 -PasswordNeverExpires $true -AccountPassword ("Password123!" | ConvertTo-SecureString -AsPlainText -Force) -Enabled $true -UserPrincipalName User2@win.local
	$user2 = Get-ADUser User2
	New-ADUser -Name User3 -PasswordNeverExpires $true -AccountPassword ("Password123!" | ConvertTo-SecureString -AsPlainText -Force) -Enabled $true -UserPrincipalName User3@win.local
	$user3 = Get-ADUser User3
```
T

