
SELECT [Config].[MaxRequestsPer15Min] ('myApp')      AS MaxRequestsPer15Min
SELECT [Config].[MinTimeBetweenRequests] ('myApp')   AS MinTimeBetweenRequests


  DELETE FROM [Core].[ExecutionRequest]

  EXEC [Core].[RequestExecutionSlot] 'myApp'
  EXEC [Core].[RequestExecutionSlot] 'myApp'

  WAITFOR DELAY '00:00:03';  
  EXEC [Core].[RequestExecutionSlot] 'myApp'

  WAITFOR DELAY '00:00:03';  
  EXEC [Core].[RequestExecutionSlot] 'myApp'

  WAITFOR DELAY '00:00:03';  
  EXEC [Core].[RequestExecutionSlot] 'myApp'

  WAITFOR DELAY '00:00:03';  
  EXEC [Core].[RequestExecutionSlot] 'myApp'

declare @now DATETIME2 = GETUTCDATE()
       ,@ID UNIQUEIDENTIFIER

SELECT  TOP 1 @ID = ExecutionRequestGId   
FROM     [Core].[ExecutionRequest] 
WHERE   [RequestStatus] = 'Granted'
 AND     [Application] = 'myApp';

EXEC  [Core].[UpdateExecutionSlot] 
   @ExecutionRequestGId = @ID
  ,@RequestFullfilledTime = @now
  ,@ExecutionResult = '{"rowsTransferred":344}'

SELECT *
FROM CORE.ExecutionRequest  
ORDER BY RequestStartTime DESC

SELECT *, JSON_VALUE(ExecutionResult, '$.rowsTransferred') AS rowsTransferred
FROM CORE.ExecutionRequest  
ORDER BY RequestStartTime DESC
