-- File:Ora_Aud_GrayLog_01_00_00_Install.sql
-- Author:DATAPLUS
-- Name:Oracle Audit Add-on for Graylog 01.00.00 Install
-- Doc. README.txt
-- Warranty: This script is provided as it its, without warranty of any kind.
-- -------------------------------------------------------------------------
-- Notes:
-- 1. Do not change or modify this script without contacting support.
-- 2. Run only with SYS/SYSDBA privileges!
-- -------------------------------------------------------------------------
   
   
SPOOL Ora_Aud_GrayLog_01_00_00_Install.log
   
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK


-- 01. Oracle Audit Add-on for Graylog - Repository Schema
prompt 01. Oracle Audit Add-on for Graylog - Repository Schema
prompt =======================================================
prompt

-- Create Oracle Audit Add-on for Graylog Schema
create user AUDORAGRAYLOG 
identified by oraclegraylog123$
account lock
default tablespace USERS
quota unlimited on USERS;


-- 02. Oracle Audit Add-on for Graylog - Repository Schema Object Privileges
prompt 02. Oracle Audit Add-on for Graylog - Repository Schema Object Privileges
prompt =========================================================================
prompt
   
-- Grant Oracle Audit Add-on for Graylog Schema Object Privileges 
grant EXECUTE on SYS.UTL_TCP to AUDORAGRAYLOG;
grant SELECT on SYS.UNIFIED_AUDIT_TRAIL to AUDORAGRAYLOG;


-- 03. Oracle Audit Add-on for Graylog - Repository Schema Objects
prompt 03. Oracle Audit Add-on for Graylog - Repository Schema Objects 
prompt ===============================================================
prompt


-- Create table
create table AUDORAGRAYLOG.LMS_PARAM
(
  parameter_id   NUMBER(9) not null,
  parameter_name VARCHAR2(30) not null,
  parameter_desc VARCHAR2(250) not null,
  param_value    VARCHAR2(100) not null,
  param_type     NUMBER(2) not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column AUDORAGRAYLOG.LMS_PARAM.param_type
  is '1 String, 2 Integer, 3 Number, 4 Date, 5 Boolean (0,1)';
-- Create/Recreate primary, unique and foreign key constraints 
alter table AUDORAGRAYLOG.LMS_PARAM
  add constraint LMS_PARAM_PK primary key (PARAMETER_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
alter table AUDORAGRAYLOG.LMS_PARAM
  add constraint LMS_PARAM_UN unique (PARAMETER_NAME)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate check constraints 
alter table AUDORAGRAYLOG.LMS_PARAM
  add constraint LMS_PARAM_TYPE_CHCK
  check (PARAM_TYPE in (1,2,3,4,5));


-- Create table
create table AUDORAGRAYLOG.LMS_SRV
(
  lms_id        NUMBER(9) not null,
  db_name       VARCHAR2(100) not null,
  db_full_name  VARCHAR2(200) not null,
  lms_host      VARCHAR2(250) not null,
  lms_port      NUMBER(9) not null,
  lms_host_2    VARCHAR2(250) not null,
  lms_port_2    NUMBER(9) not null,
  lms_charset   VARCHAR2(200) not null,
  timestamp_lst TIMESTAMP(6),
  max_rows      NUMBER(9) not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table AUDORAGRAYLOG.LMS_SRV
  add constraint LMS_SRV_PK primary key (LMS_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );


create or replace package "AUDORAGRAYLOG"."ORACLE_GRAYLOG" is

--  ------------------------------------------------------------------------------------------
-- ORACLE AUDIT ADD-ON FOR GRAYLOG
-- Version 01.01.01
-- DATAPLUS

-- This source is part of the Oracle Audit Add-on for Graylog and is copyrighted by DATAPLUS.
--
-- All rights reserved. No part of this work may be reproduced, stored in a retrieval system,
-- adopted or transmitted in any form or by any means, electronic or otherwise, translated
-- in any language or computer language, without the prior written permission of DATAPLUS.
--
-- DATAPLUS.
-- Tirana, Albania.
-- Street Address: Bul. Zog I, P. Edicom, 8F.
-- Web:    www.dataplus-al.com
-- e-Mail: info@dataplus-al.com
-- Copyright © 2007-2021 by DATAPLUS
--  ------------------------------------------------------------------------------------------

-- ============================================================

FUNCTION F_LMS_JSON_ESC (
         p_data in clob
         )
return CLOB;  

-- ============================================================
  
PROCEDURE P_UNF_TRAIL_SEO(
          p_audit_type              in varchar2,
          p_dbusername              in varchar2,
          p_action_name             in varchar2,
          p_object_schema           in varchar2,
          p_object_name             in varchar2,
          p_return_code             in number,
          p_dv_return_code          in number,
          p_current_user            in varchar2,
          p_sys_app_schema          in varchar2,
          p_seo_sec                 out integer,
          p_seo_acc                 out integer,
          p_seo_ora                 out integer,
          p_seo_ddl                 out integer,
          p_seo_dml                 out integer,
          p_seo_se                  out integer,
          p_seo_err                 out integer,
          p_seo_app                 out integer,
          p_seo_curr_user           out integer
          );

PROCEDURE P_LMS_GRAYLOG;

-- ============================================================

END ORACLE_GRAYLOG;
-- END PACKAGE SPECIFICATIONS
/


create or replace package body "AUDORAGRAYLOG"."ORACLE_GRAYLOG" is

--  ------------------------------------------------------------------------------------------
-- ORACLE AUDIT ADD-ON FOR GRAYLOG
-- Version 01.01.01
-- DATAPLUS

-- This source is part of the Oracle Audit Add-on for Graylog and is copyrighted by DATAPLUS.
--
-- All rights reserved. No part of this work may be reproduced, stored in a retrieval system,
-- adopted or transmitted in any form or by any means, electronic or otherwise, translated
-- in any language or computer language, without the prior written permission of DATAPLUS.
--
-- DATAPLUS.
-- Tirana, Albania.
-- Street Address: Bul. Zog I, P. Edicom, 8F.
-- Web:    www.dataplus-al.com
-- e-Mail: info@dataplus-al.com
-- Copyright © 2007-2021 by DATAPLUS
--  ------------------------------------------------------------------------------------------
  
-- ============================================================

FUNCTION F_LMS_JSON_ESC (
         p_data in clob
         )
return clob is

v_data clob;

begin

v_data    := p_data;

v_data    := Replace(v_data, '\', '\\');
v_data    := Replace(v_data, '"', '\"');

return v_data;

end ; -- end proc

-- ============================================================

PROCEDURE P_UNF_TRAIL_SEO(
          p_audit_type              in varchar2,
          p_dbusername              in varchar2,
          p_action_name             in varchar2,
          p_object_schema           in varchar2,
          p_object_name             in varchar2,
          p_return_code             in number,
          p_dv_return_code          in number,
          p_current_user            in varchar2,
          p_sys_app_schema          in varchar2,
          p_seo_sec                 out integer,
          p_seo_acc                 out integer,
          p_seo_ora                 out integer,
          p_seo_ddl                 out integer,
          p_seo_dml                 out integer,
          p_seo_se                  out integer,
          p_seo_err                 out integer,
          p_seo_app                 out integer,
          p_seo_curr_user           out integer
          )

AS

v_str_DZ_Field      varchar2(1000);
v_DZ_pos            number;
v_start_pos         number;
v_app_schema_cmd    varchar2(2000);
v_app_schema_list   varchar2(2000);

begin

-- default
p_seo_sec       := 0;
p_seo_acc       := 0;
p_seo_ora       := 0;
p_seo_ddl       := 0;
p_seo_dml       := 0;
p_seo_se        := 0;
p_seo_err       := 0;
p_seo_app       := 0;
p_seo_curr_user := 0;


/* Begin Security */
if
p_audit_type = 'Standard' AND p_action_name IN 
('GRANT', 'REVOKE', 'AUDIT', 'NOAUDIT', 'CREATE AUDIT POLICY', 
'ALTER AUDIT POLICY', 'DROP AUDIT POLICY', 'ALTER USER', 'CREATE USER', 'DROP USER', 'BECOME USER',
'PASSWORD CHANGE', 'ALTER ROLE', 'CREATE ROLE', 'DROP ROLE', 'SET ROLE')
OR
p_audit_type = 'Standard' AND p_object_schema = 'SYS' AND p_object_name in ('DBMS_FGA', 'DBMS_CRYPTO', 'DBMS_OBFUSCATION_TOOLKIT')
OR
p_audit_type = 'Database Vault' and p_action_name IN ('GRANT', 'REVOKE', 'AUDIT', 'NOAUDIT', 
'CREATE AUDIT POLICY', 'ALTER AUDIT POLICY', 'DROP AUDIT POLICY', 'ALTER USER', 'CREATE USER', 'DROP USER', 
'CHANGE PASSWORD', 'ALTER ROLE', 'CREATE ROLE', 'DROP ROLE', 'SET ROLE')
OR
p_audit_type IN ('XS', 'Label Security')
then
p_seo_sec :=1;
end if;
/* End Security */


/* Begin Access */
if
p_audit_type = 'Standard' AND p_action_name IN ('LOGON', 'LOGOFF', 'LOGOFF BY CLEANUP', 'PROXY AUTHENTICATION')
OR
p_audit_type = 'Database Vault' AND p_action_name IN ('LOGON', 'LOGOFF')
OR
p_audit_type = 'XS' AND p_action_name IN ('CREATE SESSION', 'DESTROY SESSION')
then
p_seo_acc := 1;
end if;
/* End Access */


/* Begin Ora Dict*/
if
p_audit_type = 'Standard' AND p_object_schema = 'SYS'
then
p_seo_ora := 1;
end if;
/* End Ora Dict*/


/* Begin DDLs */
if
p_audit_type = 'Standard' AND NOT p_action_name IN ('GRANT', 'REVOKE', 'AUDIT', 'NOAUDIT', 
'CREATE AUDIT POLICY', 'ALTER AUDIT POLICY', 'DROP AUDIT POLICY', 'ALTER USER', 'CREATE USER', 'DROP USER', 'BECOME USER',
'PASSWORD CHANGE', 'ALTER ROLE', 'CREATE ROLE', 'DROP ROLE', 'SET ROLE', 
'LOGON', 'LOGOFF', 'LOGOFF BY CLEANUP', 'PROXY AUTHENTICATION',
'INSERT', 'DELETE', 'UPDATE', 'MERGE', 'COMMIT', 'ROLLBACK', 'SAVEPOINT', 'SET TRANSACTION', 'WRITE DIRECTORY', 
'SELECT', 'SELECT MINING MODEL', 'EXECUTE', 'PL/SQL EXECUTE', 'EXECUTE DIRECTORY', 'READ DIRECTORY', 'CALL METHOD', 'EXPLAIN')
OR
p_audit_type = 'Database Vault' AND NOT p_action_name IN ('GRANT', 'REVOKE', 'AUDIT', 'NOAUDIT', 
'CREATE AUDIT POLICY', 'ALTER AUDIT POLICY', 'DROP AUDIT POLICY', 'ALTER USER', 'CREATE USER', 'DROP USER', 'CHANGE PASSWORD',
'ALTER ROLE', 'CREATE ROLE', 'DROP ROLE', 'SET ROLE', 'LOGON', 'LOGOFF',
'INSERT', 'DELETE', 'UPDATE', 'MERGE', 'COMMIT', 'ROLLBACK', 'SAVEPOINT', 'SET TRANSACTION', 
'SELECT', 'EXECUTE', 'CALL METHOD', 'EXPLAIN')
then
p_seo_ddl := 1;
end if;
/* End DDLs */


/* Begin DMLs */
if
p_audit_type = 'Standard' AND p_action_name IN ('INSERT', 'DELETE', 'UPDATE', 'MERGE', 'COMMIT', 'ROLLBACK', 'SAVEPOINT', 'SET TRANSACTION', 'WRITE DIRECTORY')
OR 
p_audit_type = 'FineGrainedAudit' AND p_action_name IN ('INSERT', 'DELETE', 'UPDATE', 'MERGE')
OR 
p_audit_type = 'Database Vault' AND p_action_name IN ('INSERT', 'DELETE', 'UPDATE', 'MERGE', 'COMMIT', 'ROLLBACK', 'SAVEPOINT', 'SET TRANSACTION')
then
p_seo_dml := 1;
end if;
/* End DMLs */


/* Begin Select-Execute */
if
p_audit_type = 'Standard' AND p_action_name IN ('SELECT', 'SELECT MINING MODEL', 'EXECUTE', 'PL/SQL EXECUTE', 'EXECUTE DIRECTORY', 'READ DIRECTORY') 
OR 
p_audit_type = 'FineGrainedAudit' AND p_action_name = 'SELECT'
OR 
p_audit_type = 'Database Vault' AND p_action_name IN ('SELECT', 'EXECUTE')
then
p_seo_se := 1;
end if;
/* End Select-Execute */


/* Begin Error */
if
p_audit_type = 'Standard' AND p_return_code != 0
OR
p_audit_type = 'Database Vault' AND p_dv_return_code != 0
then
p_seo_err := 1;
end if;
/* End Error */


/* Begin App */
IF p_object_schema is not null THEN

-- Begin Make App-Schemas list

-- Init Vars
v_str_DZ_Field := '';
v_DZ_pos := 0;
v_start_pos := 1;

-- Begin Loop IN Operands
loop
-- param is null
if p_sys_app_schema is null then
  Exit;
end if;

v_DZ_pos := INSTR(p_sys_app_schema, '#', v_start_pos);

  -- Begin Make # not found
  if v_DZ_pos = 0 then
  v_str_DZ_Field := substr(p_sys_app_schema, v_start_pos);

  if v_str_DZ_Field is not null then
  if v_app_schema_list is null then
  v_app_schema_list := '''' || v_str_DZ_Field || '''';
  else
  v_app_schema_list :=
  v_app_schema_list || ', ' || '''' || v_str_DZ_Field || '''';
  end if;
  end if;

  -- Exit Loop
  exit;
  end if;
  -- End Make # not found

-- Begin Make # found
v_str_DZ_Field := substr(p_sys_app_schema, v_start_pos, (v_DZ_pos - v_start_pos));

if v_str_DZ_Field is not null then
if v_app_schema_list is null then
v_app_schema_list := '''' || v_str_DZ_Field || '''';
else
v_app_schema_list := v_app_schema_list || ', ' || '''' || v_str_DZ_Field || '''';
end if;
end if;

-- Incr Start Position
v_start_pos := v_DZ_pos + 1;
-- End Make # found

end loop;
-- End Loop IN Operands

-- End Make App-Schemas list


/* Make App */
if v_app_schema_list is not null then

-- Make App CMD
v_app_schema_cmd :=
'DECLARE
BEGIN
if ' || '''' || p_object_schema || '''' || ' in ' || '('
|| v_app_schema_list
|| ')' || ' then
:p1 := 1;
else
:p1 := 0;
end if;
END;';
EXECUTE IMMEDIATE v_app_schema_cmd using out p_seo_app;
end if;

END IF;
/* End App */


-- Begin Current User
if p_current_user is null then
-- Default empty Current User
p_seo_curr_user := 1;
else
  if p_dbusername = p_current_user
  then
  p_seo_curr_user := 1;
  else
  p_seo_curr_user := 0;
  end if;
end if;
-- End Current User

end;

-- ============================================================

PROCEDURE P_LMS_GRAYLOG
is

cursor c_unf (p_last_tst in timestamp, p_max_rows in integer) is

select * from
(
   select 
   -- Common
   CAST((event_timestamp at TIME zone 'UTC') AS TIMESTAMP) as EVENT_TIMESTAMP_UTC,
   AUDIT_TYPE,
   SESSIONID,
   PROXY_SESSIONID,
   OS_USERNAME,
   USERHOST,
   TERMINAL,
   INSTANCE_ID,
   DBID,
   AUTHENTICATION_TYPE,
   DBUSERNAME,
   DBPROXY_USERNAME,
   EXTERNAL_USERID,
   GLOBAL_USERID,
   CLIENT_PROGRAM_NAME,
   DBLINK_INFO,
   XS_USER_NAME,
   XS_SESSIONID,
   ENTRY_ID,
   STATEMENT_ID,
   EVENT_TIMESTAMP,
   ACTION_NAME,
   RETURN_CODE,
   OS_PROCESS,
   TRANSACTION_ID,
   SCN,
   EXECUTION_ID,
   OBJECT_SCHEMA,
   OBJECT_NAME,
   -- OBJECT_TYPE, -- Oracle 21c
   SQL_TEXT,
   SQL_BINDS,
   APPLICATION_CONTEXTS,
   CLIENT_IDENTIFIER,
   NEW_SCHEMA,
   NEW_NAME,
   OBJECT_EDITION,
   SYSTEM_PRIVILEGE_USED,
   SYSTEM_PRIVILEGE,
   AUDIT_OPTION,
   OBJECT_PRIVILEGES,
   ROLE,
   TARGET_USER,
   EXCLUDED_USER,
   EXCLUDED_SCHEMA,
   EXCLUDED_OBJECT,    
   ADDITIONAL_INFO,
   UNIFIED_AUDIT_POLICIES,
   FGA_POLICY_NAME,
   CURRENT_USER,
   -- XS
   XS_INACTIVITY_TIMEOUT,
   XS_ENTITY_TYPE,
   XS_TARGET_PRINCIPAL_NAME,
   XS_PROXY_USER_NAME,
   XS_DATASEC_POLICY_NAME,
   XS_SCHEMA_NAME,
   XS_CALLBACK_EVENT_TYPE,
   XS_PACKAGE_NAME,
   XS_PROCEDURE_NAME,
   XS_ENABLED_ROLE,
   XS_COOKIE,
   XS_NS_NAME,
   XS_NS_ATTRIBUTE,
   XS_NS_ATTRIBUTE_OLD_VAL,
   XS_NS_ATTRIBUTE_NEW_VAL,
   -- DV
   DV_ACTION_CODE,
   DV_ACTION_NAME,
   DV_EXTENDED_ACTION_CODE,
   DV_GRANTEE,
   DV_RETURN_CODE,
   DV_ACTION_OBJECT_NAME,
   DV_RULE_SET_NAME,
   DV_COMMENT,
   DV_FACTOR_CONTEXT,
   DV_OBJECT_STATUS,
   -- OLS
   OLS_POLICY_NAME,
   OLS_GRANTEE,
   OLS_MAX_READ_LABEL,
   OLS_MAX_WRITE_LABEL,
   OLS_MIN_WRITE_LABEL,
   OLS_PRIVILEGES_GRANTED,
   OLS_PROGRAM_UNIT_NAME,
   OLS_PRIVILEGES_USED,
   OLS_STRING_LABEL,
   OLS_LABEL_COMPONENT_TYPE,
   OLS_LABEL_COMPONENT_NAME,
   OLS_PARENT_GROUP_NAME,
   OLS_OLD_VALUE,
   OLS_NEW_VALUE,
   -- RMAN
   RMAN_SESSION_RECID,
   RMAN_SESSION_STAMP,
   RMAN_OPERATION,
   RMAN_OBJECT_TYPE,
   RMAN_DEVICE_TYPE,
   -- DP
   DP_TEXT_PARAMETERS1,
   DP_BOOLEAN_PARAMETERS1,
   -- DP_WARNINGS1, -- Oracle 21c
   -- DRP
   DIRECT_PATH_NUM_COLUMNS_LOADED,
   -- VPD
   RLS_INFO,
   -- KSACL
   KSACL_USER_NAME,
   KSACL_SERVICE_NAME,
   KSACL_SOURCE_LOCATION
   from sys.unified_audit_trail t
   where event_TIMESTAMP > p_last_tst
   order by event_TIMESTAMP ASC
)
where rownum <= p_max_rows;

conn                sys.utl_tcp.connection;
v_GL_record         clob;
v_SP_record_part    varchar2(32767);
ret_val             pls_integer;

-- External Log System
v_lms_db_name       lms_srv.db_name%TYPE;
v_lms_db_full_name  lms_srv.db_full_name%TYPE;
v_lms_db_host       varchar2(250);
v_lms_host          lms_srv.lms_host%TYPE;
v_lms_port          lms_srv.lms_port%TYPE;

v_tst_last          lms_srv.timestamp_lst%TYPE;
v_tst_new           lms_srv.timestamp_lst%TYPE;
v_lms_charset       lms_srv.lms_charset%TYPE;
v_max_rows          lms_srv.max_rows%TYPE;

v_sys_app_schema    lms_param.param_value%TYPE;

v_os_username       varchar2(1000);
v_userhost          varchar2(1000);
v_sql_binds         clob;
v_sql_text          clob;
v_rls_info          clob;

v_seo_sec           integer;
v_seo_acc           integer;
v_seo_ora           integer;
v_seo_ddl           integer;
v_seo_dml           integer;
v_seo_se            integer;
v_seo_err           integer;
v_seo_app           integer;
v_seo_curr_user     integer;

v_date_utc    date;
v_UNIX_sec    number;
v_UNIX_FF     varchar(100);
v_UNIX_time   varchar(100); 

begin

-- BEGIN MAIN BEGIN-EXCEPTION-END
BEGIN

-- LMS Graylog params
select db_name, db_full_name, lms_host, lms_port,
timestamp_lst, lms_charset, max_rows
into v_lms_db_name, v_lms_db_full_name, v_lms_host, v_lms_port,
v_tst_last, v_lms_charset, v_max_rows
from lms_srv
where lms_id = 1;

-- App Param
select param_value into v_sys_app_schema
from lms_param
where parameter_id = 1;

if v_lms_host = '*' then
raise_application_error(-20010, 'Graylog server Hostname or IP Address is not set!');
end if;

if v_lms_port = 0 then
raise_application_error(-20010, 'Graylog server TCP Port is not set!');
end if;

if v_lms_db_name = '*' then
v_lms_db_name := SYS_CONTEXT('USERENV', 'DB_NAME'); 
end if;

if v_lms_db_full_name = '*' then
v_lms_db_full_name := SYS_CONTEXT('USERENV', 'DB_UNIQUE_NAME'); 
end if;

v_lms_db_host := SYS_CONTEXT('USERENV', 'SERVER_HOST');

-- update TST Last
if v_tst_last is null then
v_tst_last := SYSTIMESTAMP;
update lms_srv set
timestamp_lst = v_tst_last
where lms_id = 1;
COMMIT;
end if;

-- test connection
conn := sys.utl_tcp.open_connection(
remote_host => v_lms_host,
remote_port => v_lms_port,
charset => v_lms_charset
);
sys.utl_tcp.close_connection(conn);


-- Begin Loop UNF Records
for rec_unf in c_unf (v_tst_last, v_max_rows) loop

-- Make Unix epoch timestamp 
v_date_utc := cast(rec_unf.EVENT_TIMESTAMP_UTC as date);
v_UNIX_sec :=
round(to_number((v_date_utc - to_date('01-01-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600));
v_UNIX_FF  := to_char(rec_unf.EVENT_TIMESTAMP_UTC, 'FF');
v_UNIX_time := to_char(v_UNIX_sec) || '.' || v_UNIX_FF;

-- Make SEO
P_UNF_TRAIL_SEO(
rec_unf.AUDIT_TYPE,
rec_unf.DBUSERNAME,
rec_unf.ACTION_NAME,
rec_unf.OBJECT_SCHEMA,
rec_unf.OBJECT_NAME,
rec_unf.RETURN_CODE,
rec_unf.DV_RETURN_CODE,
rec_unf.CURRENT_USER,
v_sys_app_schema,
-- Seo
v_seo_sec,
v_seo_acc,
v_seo_ora,
v_seo_ddl,
v_seo_dml,
v_seo_se,
v_seo_err,
v_seo_app,
v_seo_curr_user
);

-- JSON Escape for Graylog
v_lms_db_host := F_LMS_JSON_ESC(v_lms_db_host);  
v_os_username := F_LMS_JSON_ESC(rec_unf.OS_USERNAME);  
v_userhost    := F_LMS_JSON_ESC(rec_unf.USERHOST); 
v_sql_binds   := F_LMS_JSON_ESC(rec_unf.SQL_BINDS);
v_sql_text    := F_LMS_JSON_ESC(rec_unf.SQL_TEXT);
v_rls_info    := F_LMS_JSON_ESC(rec_unf.RLS_INFO);

-- Clear fields
v_sql_binds := replace(v_sql_binds,chr(0),'');
v_sql_text  := replace(v_sql_text,chr(0),'');
v_rls_info  := replace(v_rls_info,chr(0),'');

-- Set Graylog field 32 kB limit
v_sql_binds := substr(v_sql_binds,1,32768);
v_sql_text  := substr(v_sql_text,1,32768);
v_rls_info  := substr(v_rls_info,1,32768);

-- Graylog JSON record
v_GL_record := 
'{' 

|| '"version":"1.1", '
|| '"application_name":"oraaudgraylog", '
|| '"host":"'		|| v_lms_db_host || '", ' 
|| '"short_message":"'	|| v_lms_db_name || ' oracle audit' || '", '
|| '"timestamp":'	|| v_UNIX_time || ', '
|| '"level":2, '
-- DB LMS
|| '"_DB_NAME":"'         || v_lms_db_name           || '", ' 
|| '"_DB_UNIQUE_NAME":"'  || v_lms_db_full_name      || '", ' 
|| '"_DB_HOST":"'         || v_lms_db_host           || '", ' 
-- Common
|| '"_AUDIT_TYPE":"'           || rec_unf.audit_type          || '", ' 
|| '"_SESSIONID":'             || NVL(to_char(rec_unf.SESSIONID), 'null') || ', '
|| '"_PROXY_SESSIONID":'       || NVL(to_char(rec_unf.PROXY_SESSIONID), 'null') || ', '
|| '"_OS_USERNAME":"'          || v_os_username               || '", ' 
|| '"_USERHOST":"'             || v_userhost                  || '", ' 
|| '"_TERMINAL":"'             || rec_unf.TERMINAL            || '", ' 
|| '"_INSTANCE_ID":'           || NVL(to_char(rec_unf.INSTANCE_ID), 'null') || ', '
|| '"_DBID":'                  || NVL(to_char(rec_unf.DBID), 'null') || ', '
|| '"_AUTHENTICATION_TYPE":"'  || rec_unf.AUTHENTICATION_TYPE || '", ' 
|| '"_DBUSERNAME":"'           || rec_unf.DBUSERNAME          || '", ' 
|| '"_DBPROXY_USERNAME":"'     || rec_unf.DBPROXY_USERNAME    || '", ' 
|| '"_EXTERNAL_USERID":"'      || rec_unf.EXTERNAL_USERID     || '", ' 
|| '"_GLOBAL_USERID":"'        || rec_unf.GLOBAL_USERID       || '", ' 
|| '"_CLIENT_PROGRAM_NAME":"'  || rec_unf.CLIENT_PROGRAM_NAME || '", ' 
|| '"_DBLINK_INFO":"'          || rec_unf.DBLINK_INFO         || '", ' 
|| '"_XS_USER_NAME":"'         || rec_unf.XS_USER_NAME        || '", ' 
|| '"_XS_SESSIONID":"'         || rec_unf.XS_SESSIONID        || '", ' 
|| '"_ENTRY_ID":'              || NVL(to_char(rec_unf.ENTRY_ID), 'null') || ', ' 
|| '"_STATEMENT_ID":'          || NVL(to_char(rec_unf.STATEMENT_ID), 'null') || ', '
|| '"_EVENT_TIMESTAMP_UTC":"'  || to_char(rec_unf.EVENT_TIMESTAMP_UTC, 'yyyymmddhh24miss.FF') || '", ' 
|| '"_EVENT_TIMESTAMP":"'      || to_char(rec_unf.EVENT_TIMESTAMP, 'yyyymmddhh24miss.FF')     || '", ' 
|| '"_ACTION_NAME":"'          || rec_unf.ACTION_NAME         || '", '
|| '"_RETURN_CODE":'           || NVL(to_char(rec_unf.RETURN_CODE), 'null') || ', '
|| '"_OS_PROCESS":"'           || rec_unf.OS_PROCESS          || '", '
|| '"_TRANSACTION_ID":"'       || rec_unf.TRANSACTION_ID      || '", '
|| '"_SCN":'                   || NVL(to_char(rec_unf.SCN), 'null') || ', '
|| '"_EXECUTION_ID":"'         || rec_unf.EXECUTION_ID        || '", '
|| '"_OBJECT_SCHEMA":"'        || rec_unf.OBJECT_SCHEMA       || '", '
|| '"_OBJECT_NAME":"'          || rec_unf.OBJECT_NAME         || '", '
-- || '"_OBJECT_TYPE":"'          || rec_unf.OBJECT_TYPE      || '", ' -- Oracle 21c
|| '"_SQL_BINDS":"'            || v_sql_binds                 || '", '
|| '"_SQL_TEXT":"'             || v_sql_text                  || '", '
|| '"_APPLICATION_CONTEXTS":"'  || rec_unf.APPLICATION_CONTEXTS   || '", '
|| '"_CLIENT_IDENTIFIER":"'     || rec_unf.CLIENT_IDENTIFIER      || '", '
|| '"_NEW_SCHEMA":"'            || rec_unf.NEW_SCHEMA             || '", '
|| '"_NEW_NAME":"'              || rec_unf.NEW_NAME               || '", '
|| '"_OBJECT_EDITION":"'        || rec_unf.OBJECT_EDITION         || '", '
|| '"_SYSTEM_PRIVILEGE_USED":"' || rec_unf.SYSTEM_PRIVILEGE_USED  || '", '
|| '"_SYSTEM_PRIVILEGE":"'      || rec_unf.SYSTEM_PRIVILEGE       || '", '
|| '"_AUDIT_OPTION":"'          || rec_unf.AUDIT_OPTION           || '", '
|| '"_OBJECT_PRIVILEGES":"'     || rec_unf.OBJECT_PRIVILEGES      || '", '
|| '"_ROLE":"'                  || rec_unf.ROLE                   || '", '
|| '"_TARGET_USER":"'           || rec_unf.TARGET_USER            || '", '
|| '"_EXCLUDED_USER":"'         || rec_unf.EXCLUDED_USER          || '", '
|| '"_EXCLUDED_SCHEMA":"'       || rec_unf.EXCLUDED_SCHEMA        || '", '
|| '"_EXCLUDED_OBJECT":"'       || rec_unf.EXCLUDED_OBJECT        || '", '
|| '"_ADDITIONAL_INFO":"'        || rec_unf.ADDITIONAL_INFO        || '", '
|| '"_UNIFIED_AUDIT_POLICIES":"' || rec_unf.UNIFIED_AUDIT_POLICIES || '", '
|| '"_FGA_POLICY_NAME":"'        || rec_unf.FGA_POLICY_NAME        || '", '
|| '"_CURRENT_USER":"'           || rec_unf.CURRENT_USER           || '", '
-- XS
|| '"_XS_INACTIVITY_TIMEOUT":'      || NVL(to_char(rec_unf.XS_INACTIVITY_TIMEOUT), 'null') || ', ' 
|| '"_XS_ENTITY_TYPE":"'            || rec_unf.XS_ENTITY_TYPE           || '", '
|| '"_XS_TARGET_PRINCIPAL_NAME":"'  || rec_unf.XS_TARGET_PRINCIPAL_NAME || '", '
|| '"_XS_PROXY_USER_NAME":"'        || rec_unf.XS_PROXY_USER_NAME       || '", '
|| '"_XS_DATASEC_POLICY_NAME":"'    || rec_unf.XS_DATASEC_POLICY_NAME   || '", '
|| '"_XS_SCHEMA_NAME":"'            || rec_unf.XS_SCHEMA_NAME           || '", '
|| '"_XS_CALLBACK_EVENT_TYPE":"'    || rec_unf.XS_CALLBACK_EVENT_TYPE   || '", '
|| '"_XS_PACKAGE_NAME":"'           || rec_unf.XS_PACKAGE_NAME          || '", '
|| '"_XS_PROCEDURE_NAME":"'         || rec_unf.XS_PROCEDURE_NAME        || '", '
|| '"_XS_ENABLED_ROLE":"'           || rec_unf.XS_ENABLED_ROLE          || '", '
|| '"_XS_COOKIE":"'                 || rec_unf.XS_COOKIE                || '", '
|| '"_XS_NS_NAME":"'                || rec_unf.XS_NS_NAME               || '", '
|| '"_XS_NS_ATTRIBUTE":"'           || rec_unf.XS_NS_ATTRIBUTE          || '", '
|| '"_XS_NS_ATTRIBUTE_OLD_VAL":"'   || rec_unf.XS_NS_ATTRIBUTE_OLD_VAL  || '", '
|| '"_XS_NS_ATTRIBUTE_NEW_VAL":"'   || rec_unf.XS_NS_ATTRIBUTE_NEW_VAL  || '", '
-- DV
|| '"_DV_ACTION_CODE":'             || NVL(to_char(rec_unf.DV_ACTION_CODE), 'null') || ', '
|| '"_DV_ACTION_NAME":"'            || rec_unf.DV_ACTION_NAME           || '", '
|| '"_DV_EXTENDED_ACTION_CODE":'    || NVL(to_char(rec_unf.DV_EXTENDED_ACTION_CODE), 'null') || ', '
|| '"_DV_GRANTEE":"'                || rec_unf.DV_GRANTEE               || '", '
|| '"_DV_RETURN_CODE":'             || NVL(to_char(rec_unf.DV_RETURN_CODE), 'null') || ', '
|| '"_DV_ACTION_OBJECT_NAME":"'     || rec_unf.DV_ACTION_OBJECT_NAME    || '", '
|| '"_DV_RULE_SET_NAME":"'          || rec_unf.DV_RULE_SET_NAME         || '", '
|| '"_DV_COMMENT":"'                || rec_unf.DV_COMMENT               || '", '
|| '"_DV_FACTOR_CONTEXT":"'         || rec_unf.DV_FACTOR_CONTEXT        || '", '
|| '"_DV_OBJECT_STATUS":"'          || rec_unf.DV_OBJECT_STATUS         || '", '
-- OLS
|| '"_OLS_POLICY_NAME":"'           || rec_unf.OLS_POLICY_NAME          || '", '
|| '"_OLS_GRANTEE":"'               || rec_unf.OLS_GRANTEE              || '", '
|| '"_OLS_MAX_READ_LABEL":"'        || rec_unf.OLS_MAX_READ_LABEL       || '", '
|| '"_OLS_MAX_WRITE_LABEL":"'       || rec_unf.OLS_MAX_WRITE_LABEL      || '", '
|| '"_OLS_MIN_WRITE_LABEL":"'       || rec_unf.OLS_MIN_WRITE_LABEL      || '", '
|| '"_OLS_PRIVILEGES_GRANTED":"'    || rec_unf.OLS_PRIVILEGES_GRANTED   || '", '
|| '"_OLS_PROGRAM_UNIT_NAME":"'     || rec_unf.OLS_PROGRAM_UNIT_NAME    || '", '
|| '"_OLS_PRIVILEGES_USED":"'       || rec_unf.OLS_PRIVILEGES_USED      || '", '
|| '"_OLS_STRING_LABEL":"'          || rec_unf.OLS_STRING_LABEL         || '", '
|| '"_OLS_LABEL_COMPONENT_TYPE":"'  || rec_unf.OLS_LABEL_COMPONENT_TYPE || '", '
|| '"_OLS_LABEL_COMPONENT_NAME":"'  || rec_unf.OLS_LABEL_COMPONENT_NAME || '", '
|| '"_OLS_PARENT_GROUP_NAME":"'     || rec_unf.OLS_PARENT_GROUP_NAME    || '", '
|| '"_OLS_OLD_VALUE":"'             || rec_unf.OLS_OLD_VALUE            || '", '
|| '"_OLS_NEW_VALUE":"'             || rec_unf.OLS_NEW_VALUE            || '", '
-- RMAN
|| '"_RMAN_SESSION_RECID":'        || NVL(to_char(rec_unf.RMAN_SESSION_RECID), 'null') || ', '
|| '"_RMAN_SESSION_STAMP":'        || NVL(to_char(rec_unf.RMAN_SESSION_STAMP), 'null') || ', '
|| '"_RMAN_OPERATION":"'           || rec_unf.RMAN_OPERATION                 || '", '
|| '"_RMAN_OBJECT_TYPE":"'         || rec_unf.RMAN_OBJECT_TYPE               || '", '
|| '"_RMAN_DEVICE_TYPE":"'         || rec_unf.RMAN_DEVICE_TYPE               || '", '
-- DP
|| '"_DP_TEXT_PARAMETERS1":"'      || rec_unf.DP_TEXT_PARAMETERS1            || '", '
|| '"_DP_BOOLEAN_PARAMETERS1":"'   || rec_unf.DP_BOOLEAN_PARAMETERS1         || '", '
-- || '"_DP_WARNINGS1":"'             || rec_unf.DP_WARNINGS1                   || '", '
-- DRP
|| '"_DIRECT_PATH_NUM_COLUMNS_LOADED":' || NVL(to_char(rec_unf.DIRECT_PATH_NUM_COLUMNS_LOADED), 'null') || ', '
-- VPD
|| '"_RLS_INFO":"'                 || v_rls_info        || '", '
-- KSACL
|| '"_KSACL_USER_NAME":"'          || rec_unf.KSACL_USER_NAME                || '", '
|| '"_KSACL_SERVICE_NAME":"'       || rec_unf.KSACL_SERVICE_NAME             || '", '
|| '"_KSACL_SOURCE_LOCATION":"'    || rec_unf.KSACL_SOURCE_LOCATION          || '", '
-- SEO
|| '"_SEO_SEC":'           || v_seo_sec          || ', ' 
|| '"_SEO_ACC":'           || v_seo_acc          || ', ' 
|| '"_SEO_ORA":'           || v_seo_ora          || ', ' 
|| '"_SEO_DDL":'           || v_seo_ddl          || ', ' 
|| '"_SEO_DML":'           || v_seo_dml          || ', ' 
|| '"_SEO_SE":'            || v_seo_se           || ', ' 
|| '"_SEO_ERR":'           || v_seo_err          || ', ' 
|| '"_SEO_APP":'           || v_seo_app          || ', ' 
|| '"_SEO_CURR_USER":'     || v_seo_curr_user    || ' '

|| '}' ;

-- Begin Debug
-- dbms_output.put_line(v_GL_record);
-- dbms_output.put_line(v_UNIX_time || ' ' || v_GL_record);
-- End Debug

-- Open Connection
conn := sys.utl_tcp.open_connection(
remote_host  => v_lms_host,
remote_port  => v_lms_port,
charset      => v_lms_charset
);

-- Begin Multi-Write
Loop
v_SP_record_part := substr(v_GL_record, 1, 8190);
-- Close Line/Event
If v_SP_record_part is null then
ret_val := sys.UTL_TCP.WRITE_LINE(conn, '');
Exit;
End if;
-- Write Text
ret_val := sys.UTL_TCP.WRITE_TEXT(conn, v_SP_record_part);
-- Drop Processed part
v_GL_record := substr(v_GL_record, 8190+1);
End loop;
-- End Multi-Write

-- Close Connection
sys.utl_tcp.close_connection(conn);

-- Mark TST
v_tst_new := rec_unf.EVENT_TIMESTAMP;

end loop;
-- End Loop UNF Records


-- Update New TST
if v_tst_new is not null then
update lms_srv set
timestamp_lst = v_tst_new
where lms_id = 1;
COMMIT;
end if;


EXCEPTION -- MAIN EXCEPTION

WHEN OTHERS THEN

-- Update New TST
if v_tst_new is not null then
update lms_srv set
timestamp_lst = v_tst_new
where lms_id = 1;
COMMIT;
end if;

RAISE;

END;
-- END MAIN BEGIN-EXCEPTION-END

end;

-- ============================================================
  
END ORACLE_GRAYLOG;
-- END PACKAGE BODY
/


-- 04. Oracle Audit Add-on for Graylog - Scheduler Job
prompt 04. Oracle Audit Add-on for Graylog - Scheduler Job
prompt ===================================================
prompt
   
begin
     dbms_scheduler.create_job(
     job_name => 'AUDORAGRAYLOG.LMS_GRAYLOG',
     job_type => 'PLSQL_BLOCK',
     job_action => 'begin ORACLE_GRAYLOG.P_LMS_GRAYLOG; end;',
     start_date => SYSTIMESTAMP + 1/(24*60), -- set 1 min later
     repeat_interval => 'freq=secondly;interval=60',
     enabled => FALSE,
     comments => 'Oracle Audit Add-on for Graylog Job'
     );
end;
/


-- 05. Oracle Audit Add-on for Graylog - Repository Data
prompt 05. Oracle Audit Add-on for Graylog - Repository Data
prompt =====================================================
prompt

-- LMS_PARAM
insert into AUDORAGRAYLOG.lms_param 
(parameter_id, parameter_name, parameter_desc, param_value, param_type
)
values (
1, 'APPSCHM', 'Application Schemas', '#', 1
);

-- LMS_SRV
insert into AUDORAGRAYLOG.LMS_SRV
(
lms_id, db_name, db_full_name, 
lms_host, lms_port, lms_host_2, lms_port_2, 
lms_charset, timestamp_lst, max_rows
)
values
(
1, '*', '*', 
'*', 0, '*', 0,
'AL32UTF8', NULL, 10000
);

COMMIT;


-- 06. Oracle Audit Add-on for Graylog - Compile
prompt 06. Oracle Audit Add-on for Graylog - Compile
prompt =============================================
prompt
   
execute SYS.DBMS_UTILITY.COMPILE_SCHEMA('AUDORAGRAYLOG', TRUE, FALSE);


-- Purge Recycle Bin
purge recyclebin;
   
SPOOL OFF
