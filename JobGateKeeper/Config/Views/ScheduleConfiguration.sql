
CREATE VIEW [Config].[ScheduleConfiguration]

AS


SELECT CONVERT(VARCHAR(25), 'myApp' ) AS [Application]
      ,CONVERT(INT, 2)                AS [MinTimeBetweenRequests] -- Second
      ,CONVERT(INT, 3)                AS [MaxRequestsPer15Min]
WHERE @@SERVERNAME like 'mewsqlmi%'  -- Dev

UNION ALL

SELECT CONVERT(VARCHAR(25), 'myApp' ) AS [Application]
      ,CONVERT(INT, 2)                AS [MinTimeBetweenRequests]
      ,CONVERT(INT, 3)                AS [MaxRequestsPer15Min]
WHERE @@SERVERNAME like 'mewsqlmiTest%'  -- Test

UNION ALL

SELECT CONVERT(VARCHAR(25), 'myApp' ) AS [Application]
      ,CONVERT(INT, 30)                AS [MinTimeBetweenRequests] 
      ,CONVERT(INT, 15)                AS [MaxRequestsPer15Min]
WHERE @@SERVERNAME like 'mewsqlmiProd%'  -- Prod


UNION ALL


SELECT CONVERT(VARCHAR(25), 'myApp2' ) AS [Application]
      ,CONVERT(INT, 15)                AS [MinTimeBetweenRequests] -- Second
      ,CONVERT(INT, 15)                AS [MaxRequestsPer15Min]
-- WHERE @@SERVERNAME like 'mewsqlmi%'  -- All environment



