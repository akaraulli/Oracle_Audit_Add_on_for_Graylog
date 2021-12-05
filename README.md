Oracle Audit Add-on for Graylog integrates Oracle database unified audit with Graylog

1. Architecture and Overview 

| Oracle Database -> Oracle Audit Add-on for Graylog | -> | Graylog GELF TCP Input -> Graylog |

Oracle Audit Add-on for Graylog is an Oracle software package that performs delivery of Oracle 
unified audit events to Graylog SIEM system. The delivery is performed via TCP protocol. An Oracle
scheduler job invokes periodically the procedure that collects the latest events and delivers them 
in JSON format for Graylog GELF. On Graylog side a GELF TCP Input receives and ingests the Oracle 
unified audit events to Graylog repository.

2. Prerequisites

* Oracle Database 12c and later
* Graylog version 3 and later
* Graylog GELF TCP Input

3. Setup

Oracle
* Install the Add-on in the Oracle Database by executing SQL script Ora_Aud_GrayLog_01_00_00_Install.sql
* Set the Graylog Server hostname/IP and port in table LMS_SRV, respectively in fields lms_host and lms_port
* Grant Network ACL privileges to Add-on schema owner for access to Graylog host using SQL commands in file ACL.txt 
* Start the Oracle scheduler job LMS_GRAYLOG

Graylog

A GELF TCP Input must be up and running

For details please refer to User_Guide.txt

4. DATAPLUS

Oracle database security software solutions and services

Web:	https://www.dataplus-al.com

e-Mail:	info@dataplus-al.com
