-- File:Ora_Aud_GrayLog_01_00_00_Uninstall.sql
-- Author:DATAPLUS
-- Name:Oracle Audit Add-on for Graylog 01.00.00 Uninstall
-- Doc. README.txt
-- Warranty: This script is provided as it its, without warranty of any kind.
-- -------------------------------------------------------------------------
-- Notes:
-- 1. Do not change or modify this script without contacting support.
-- 2. Run only with SYS/SYSDBA privileges!
-- -------------------------------------------------------------------------
   
   
SPOOL Ora_Aud_GrayLog_01_00_00_Uninstall.log
   
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK


prompt
prompt 01. Oracle Audit Add-on for Graylog - Drop Graylog Job
prompt =========================================================
prompt

begin
     dbms_scheduler.disable(
     name => 'AUDORAGRAYLOG.LMS_GRAYLOG',
     force => TRUE	
     );
end;
/

begin
     dbms_scheduler.drop_job(
     job_name => 'AUDORAGRAYLOG.LMS_GRAYLOG',
     force => TRUE	
     );
end;
/


-- 02. Oracle Audit Add-on for Graylog - Repository Uninstall

prompt
prompt 03. Oracle Audit Add-on for Graylog - Repository Uninstall
prompt ==========================================================
prompt

drop user AUDORAGRAYLOG cascade;


-- Purge Recycle Bin
purge recyclebin;
   
SPOOL OFF
