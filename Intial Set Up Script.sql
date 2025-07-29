

use database samsungdb;
use schema samsung_schema;

-- Step 0: Drop the existing data clean room if it exists
use role samooha_app_role;


--DROP the existing data clean room 
  ---SET cleanroom_name = 'SAMSUNG_ARGOS';
  ---CALL samooha_by_snowflake_local_db.provider.drop_cleanroom($cleanroom_name);

-- Step 1: Set up security role and compute warehouse
use role sysadmin;
USE WAREHOUSE app_wh;

-- Step 2: (SKIPPED) Table creation and data loading
-- The table samsungdb.samsung_schema.Stage_Table already exists and is loaded with data.
-- No need to recreate or reload.

-- Step 3: (Optional) Verify table and data
-- select * from samsungdb.samsung_schema.Stage_Table;

-- Step 4: Switch to Samooha application role for clean room configuration
USE ROLE samooha_app_role;
SET cleanroom_name = 'SAMSUNG_ARGOS';

-- Step 5: Initialize the clean room
CALL samooha_by_snowflake_local_db.provider.cleanroom_init($cleanroom_name, 'INTERNAL');

-- Step 6: Register the provider database so the clean room API layer can access it
CALL samooha_by_snowflake_local_db.provider.register_db('samsungdb');

-- Step 7: Link the provider table to the clean room
CALL samooha_by_snowflake_local_db.provider.link_datasets($cleanroom_name,
  ['samsungdb.samsung_schema.Stage_Table']);

CALL samooha_by_snowflake_local_db.provider.view_provider_datasets($cleanroom_name);

-- Step 8: Restrict joinable columns to hashedEmails only
CALL samooha_by_snowflake_local_db.provider.set_join_policy($cleanroom_name,
  ['samsungdb.samsung_schema.Stage_Table:hashedEmails']);

CALL samooha_by_snowflake_local_db.provider.view_join_policy($cleanroom_name);

-- Step 9: (Reference only) Example query that the template will allow
-- Select c.hashedEmails
-- From samsungdb.samsung_schema.Stage_Table p
-- join consumer_table c on p.hashedEmails = c.hashedEmails;

-- Step 10: Add the custom SQL template for allowed overlap join
SET template_name = 'overlap_template';
----Alex's changes ***********************************************
CALL samooha_by_snowflake_local_db.provider.add_custom_sql_template(
    $cleanroom_name,
    $template_name,
    $$
        select {{ consumer_join_id1 | sqlsafe }}
        from identifier({{ source_table[0] }}) p
        left join identifier({{ my_table[0] }}) c
        on {{ consumer_join_id1 | sqlsafe }} = {{ provider_join_id1 | sqlsafe }};
    $$);

CALL samooha_by_snowflake_local_db.provider.view_added_templates($cleanroom_name);

-- Step 11: Set default release directive (versioning for clean room)
CALL samooha_by_snowflake_local_db.provider.set_default_release_directive($cleanroom_name, 'V1_0', '0');

-- Step 12: Share the clean room with the consumer account -- Invite occurs here
-- You must obtain the consumer's Snowflake Account Identifier (e.g. TA76655) and their role (e.g. SFPSCOGS.AM_DCR_CONSUMER)
use role accountadmin;

CALL samooha_by_snowflake_local_db.provider.add_consumers(
  $cleanroom_name,
  'TA76655', -- Consumer's Snowflake Account Identifier. Consumer must supply Samsung with this.
  'SFPSCOGS.AM_DCR_CONSUMER' -- Consumer's role for clean room access. Consumer must supply Samsung with this.
);

CALL samooha_by_snowflake_local_db.provider.view_consumers($cleanroom_name);

-- Step 13: Publish the clean room so the consumer can access it
CALL samooha_by_snowflake_local_db.provider.create_or_update_cleanroom_listing($cleanroom_name);

-- Linking a table to a Data Clean Room:
CALL samooha_by_snowflake_local_db.provider.link_datasets('SAMSUNG_ARGOS', ['samsungdb.samsung_schema.Stage_Table']);



-- See all tables currently linked to the data clean room
CALL samooha_by_snowflake_local_db.provider.view_provider_datasets('SAMSUNG_ARGOS');



-- Check which columns are allowed for joining
CALL samooha_by_snowflake_local_db.provider.view_join_policy('SAMSUNG_ARGOS');





-- End of script
