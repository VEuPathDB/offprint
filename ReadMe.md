![offprint logo](doc/offprint.png)

# offprint

A pipeline for making an offprint of a EuPathDB website on to a virtual appliance.

### Features

- Given the name of website hostname, e.g. `offprint toxodb.org`, offprint will programmatically determine the user and application databases that need to be cloned and the website source code that is required.
- Imports, over network link, the source website's application and user databases to destination databases on the appliance. This helps ensure that the database is in sync with the website application code.
- Website source code is checked out from SCM at the same revision as the source website. This helps ensure that the code is in sync with the databases (in particular, with the tuning tables).

### Requirements
- The source databases require an account with the `EXP_FULL_DATABASE` role.
- Virtual machine cloned from our standard template.
  - Prepped with Puppet's sa.pp node manifest, which includes
    - Oracle software (offprint will create the databases)
    - Apache HTTP Server framework
    - Tomcat Instance Framework
    - userdb disk image mounted at /u02/oradata/userdb
      - the volume must be large enough to hold the user database
    - appdb disk image mounted at /u02/oradata/appdb
      - the volume must be large enough to hold the application database
    - vmbuilder disk image mounted at /vmbuilder
    - existing tnsnames.ora with appdb and userdb entries
- The source website must have a functional /dashboard app. 
  - The destination machine must have access to the source /dashboard API.
    - e.g. `curl toxodb.org/dashboard/xml`
- The user running offprint must have root privileges in /etc/sudoers with no password, e.g.
  - `%vmbulder ALL   = (ALL) NOPASSWD:ALL`
  - See note about the `vmbuilder` user below.
- Many steps are run as other users (oracle) and those users need to be
able to read `offprint` files. So install offprint in a world readable
location.

#### Recommeded

The standard KVM virtual machine template includes the user 'vmbuilder' whose home is provided by a dedicated virtual disk. Run offprint as this user. When converting from KVM to VMWare the vmbulder home disk is excluded, thereby reducing security exposure from vmbuilder's shell history and offprint configuration files.


### Usage


Set env variables (optional)

- OPR_HOME (default: $HOME/offprint) - location of offprint source code
- OPR_WD (default: $HOME/.offprint) - offprint working directory for temporary files and logs
- OPR_CONF (default: $HOME/offprint.conf) - configuration for an offprint instance

Confirm the source website is online, has a functional `/dashboard` API and has the desired version of source code and database. Then run **offprint &lt;hostname&gt;**

Where hostname is the source website you want to install on a virtual machine. For example,

      offprint w1.amoebadb.org

_Tip: For websites that multiple backends, it is best to explictly state the host that is closest to the VM; that is, use `w1.amoebadb.org` rather than `amoebadb.org` so you do not try to copy a database across a WAN._

See the  __Individual Commands__  section below for running substeps of the pipeline.

#### Configuration

The default configuration file is `offprint.conf` in `vmbuilder`'s home directory (use `offprint/conf/offprint.conf.sample` as a starting template. The conf file is internally documented. The default file location can be changed by setting the `OPR_CONF` environment variable to a file path.

Other quasi-configuration files can be found in `offprint/conf/`. These should not need to be changed very often, typically only when the database schema changes.

- oprdatafiles.ws.rsync.exclude

  A list of files to exclude from `apiSiteFilesMirror` during `rsync` to the VM. The file format follows `rsync --exclude-from` rules.

- oprdb.appdb.schema

  The list of schema to export from the source AppDB database.

- oprdb.userdb.schema

  The list of schema to export from the source UserDB database. `%%user_schema%%` is a macro that will be dynamically replaced with the correct value for the given website, e.g. `userlogins5`. The value is obtained by a /dashboard API query to the source website.

- oprdb.userdb.min.exp.query

  Queries used to select rows for exporting from UserDB. This is useful for creating a minimal database, devoid of sensitive data such as user profiles and passwords. 
  
  `%%user_schema%%` is a macro as described above for `oprdb.userdb.schema`. These lines will be copied into the parameter file used by `impdp`. See [Oracle Export documentation](http://docs.oracle.com/cd/B28359_01/server.111/b28319/dp_export.htm#i1007859) for Query syntax.

- oprdb.userdb.min.exp.query

- oprdb.fullscrub.remap

  Oracle expdp remap\_data instructions.
  
  `%%user_schema%%` is a macro as described above for `oprdb.userdb.schema`. These lines will be copied into the parameter file used by `impdp`. The remapping functions are defined in `offprint/lib/sql/oprdb.userdb.functions.sql`.

#### Logging

STDOUT and STDERR are directed to the console and to log files in `~/.opr/`. They are named after the individual commands and timestamped.

#### Individual Commands

Typically you want to run `offprint` to do a complete setup but you can run individual steps if you need to patch specific components or are debugging the pipeline. Be aware that running individual steps can have unintended consequences. For example, re-importing a database may result in one that is out of sync with the WDK application code.

**oprdb**

**oprsite**

**oprdatafiles**

### Things To Know

- `offprint` installs the same revision of source code as found on the source website (as reported by the /dashboard API).
  - Therefore, committing a bug fix to the relevant branch is not sufficient for the VM to acquire that fix. You must first rebuild the source website so /dashboard reflects the correct revision.


### Action Overview

The following is a high-level summary of what each script does.

**oprdb**

  - for each userdb and appdb
    - gets name of source database from /dashboard API of source website
    - creates network link from destination to source databases
    - imports from source to destination (VM) database over that network link
    - patches destination database with objects present in source database but not imported
      - add database link from AppDB to UserDB
      - add UTL_INADDR ACL (needed by /dashboard)
    - patches destination database with VM-specific objects
      - `vmuser` database accounts for WDK

**oprsite**

**oprdatafiles**
    
### Known Issues

  - FK constraints in userlogins tables such as STEPS and STRATEGIES are lost when filtering the expdp of WDK userlogins users because of the missing parent keys. I would need to similarly filter those other tables but that's too much maintenance at this point - I have to reverse engineer the references each time the UserDB schema changes.

  - Personal WDK profile data may not be scrubbed. I can only remove profile data (such as passwords, email addresses) if I know about it. Some data is obvious (userlogins.users.password) but I have not done a full inspection of every field so there may be caches of data that is not cleaned.
  
  - UserDB GBROWSEUSERS.SESSIONS has long columns, and longs can not be loaded/unloaded using a network link. This is ok.


### ToDo

  - install jolokia webapp for /dashboard
  - not exp databases if tuningManager is running
    - block tM when offprint is running    
  - do we need APICOMM_DBLINK in conf/oprdb.userdb.schema?
    - yes because it's used for the dblink
      - CFG_WDK_USERDB_LINK_LOGIN in offprint.conf
  - CFG_WDK_USERDB_LINK_LOGIN is not created despite what the offprint.conf indicates
  - %%app_login_schema%% is commented out in conf/oprdb.appdb.schema, delete line if not needed
