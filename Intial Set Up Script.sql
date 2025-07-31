 CREATE OR REPLACE PROCEDURE sp_disable_inactive_users_merged()
  RETURNS STRING
  LANGUAGE JAVASCRIPT
  EXECUTE AS CALLER
AS
$$
/*
  Author: Lindian Thomas
  Date: August 2025

  Description:
  This procedure disables Snowflake users who have not logged in within the last 90 days,
  excluding system and specified service users.
*/

var result = '';
var sql_command = `
    SELECT name AS USER_NAME
    FROM snowflake.account_usage.users
    WHERE name NOT IN (
        SELECT DISTINCT user_name
        FROM snowflake.account_usage.login_history
        WHERE event_timestamp > DATEADD(day, -90, CURRENT_DATE)
          AND event_type = 'LOGIN'
    )
     AND name NOT IN ('SNOWFLAKE', 'SYSADMIN', 'ACCOUNTADMIN')
`;
var stmt = snowflake.createStatement({sqlText: sql_command});
var cur = stmt.execute();
while (cur.next()) {
    var usr = cur.getColumnValue('USER_NAME');
    snowflake.createStatement({
        sqlText: `ALTER USER IDENTIFIER('${usr}') SET DISABLED = TRUE`
    }).execute();
    result += usr + ', ';
}
if (result == '') {
    return 'No users disabled.';
} else {
    return 'Disabled users: ' + result.replace(/, $/, '');
}
$$;
