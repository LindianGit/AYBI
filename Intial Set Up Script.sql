CREATE OR REPLACE TRANSIENT TABLE INACTIVE_USERS ( 
    USER_NAME STRING, 
    IDENTIFIED_ON DATE DEFAULT CURRENT_DATE() 
); 

-===============================================================

CREATE OR REPLACE PROCEDURE sp_find_inactive_users ()
  RETURNS TEXT
  LANGUAGE SQL
  AS $$
BEGIN
    INSERT INTO INACTIVE_USERS(USER_NAME) 
SELECT name 
FROM snowflake.account_usage.users 
WHERE name NOT IN ( 
    SELECT DISTINCT user_name
    FROM snowflake.account_usage.login_history 
    WHERE event_timestamp > DATEADD(day, -90, CURRENT_DATE) 
      AND event_type = 'LOGIN' 
) 
AND name NOT IN ('SNOWFLAKE', 'SYSADMIN', 'ACCOUNTADMIN'); 
END;
$$;


-===============================================================
CREATE OR REPLACE PROCEDURE sp_disable_inactive_users() 
  RETURNS STRING 
  LANGUAGE SQL 
  EXECUTE AS CALLER 
AS 
$$ 
DECLARE
    usr STRING;
    result STRING DEFAULT ''; 
    cur CURSOR FOR SELECT USER_NAME FROM INACTIVE_USERS; 
BEGIN 
    FOR record IN cur DO 
        usr := record.USER_NAME; 
        EXECUTE IMMEDIATE 
            'ALTER USER IDENTIFIER(?) SET DISABLED = TRUE'
            USING (usr);
        result := result || usr || ', ';
    END FOR; 
    RETURN 'Disabled users: ' || RTRIM(result, ', '); 
END;
$$; 

-===============================================================
--CALL sp_find_inactive_users ();
--CALL sp_disable_inactive_users();

--=============================================================
 
CREATE OR REPLACE TASK find_inactive_users WAREHOUSE = COMPUTE_WH SCHEDULE = 'USING CRON 45 2 * * * Europe/London' AS CALL sp_find_inactive_users ();
CREATE OR REPLACE TASK disable_inactive_users WAREHOUSE = COMPUTE_WH SCHEDULE = 'USING CRON 0 3 * * * Europe/London' AS CALL sp_disable_inactive_users(); 
 
 
