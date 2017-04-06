set verify off

DEFINE scriptPath=&1
DEFINE oracleSid=&2

@&&scriptPath/&&oracleSid.GusPrep.sql
@&&scriptPath/networkACL.sql

exit;