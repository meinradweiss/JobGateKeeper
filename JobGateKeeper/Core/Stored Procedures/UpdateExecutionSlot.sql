
CREATE PROCEDURE [Core].[UpdateExecutionSlot] (@ExecutionRequestGId    UNIQUEIDENTIFIER
                                              ,@RequestFullfilledTime  DATETIME2
                                              ,@ExecutionResult        NVARCHAR(MAX))
AS

BEGIN
  UPDATE Core.ExecutionRequest
  SET RequestFullfilledTime = @RequestFullfilledTime
     ,ExecutionResult       = @ExecutionResult
  WHERE ExecutionRequestGId = @ExecutionRequestGId
   
END
