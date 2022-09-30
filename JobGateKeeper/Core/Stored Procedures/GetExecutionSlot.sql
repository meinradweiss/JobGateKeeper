
CREATE PROCEDURE [Core].[GetExecutionSlot] (@Application VARCHAR(25) = 'myApp')
AS

BEGIN
    SET NOCOUNT ON

	CREATE TABLE #RequestResult
    (
	  [ExecutionRequestGId]   [uniqueidentifier] NULL,
	  [ExecutionRequestId]    [int]              NULL,
	  [Application]           [varchar](25)      NULL,
	  [RequestStatus]         [varchar](25)      NULL,
	  [RequestStartTime]      [datetime2](3)     NULL,
	  [RequestFullfilledTime] [datetime2](3)     NULL,
	  [NextValidStartTime]    [datetime2](3)     NULL,
	  [SecondsToWait]         [int]              NULL,
	  [DenyReason]            [varchar](255)     NULL,
   )

    DECLARE @RequestStatus       [varchar](25)      = ''
	       ,@SecondsToWait       [int]
		   ,@WaitString          [varchar](8)

	WHILE (@RequestStatus <> 'Granted')
	BEGIN
	  INSERT INTO #RequestResult
	  EXEC [Core].[RequestExecutionSlot] @Application


	  SELECT TOP 1 @RequestStatus = RequestStatus, @SecondsToWait = SecondsToWait
	  FROM #RequestResult
	  ORDER BY [RequestStartTime] DESC




	  IF (@RequestStatus = 'Denied')
	  BEGIN

	    SELECT @WaitString = CONVERT(VARCHAR, DATEADD(SECOND, @SecondsToWait,'00:00:00'), 108)
	    WAITFOR DELAY @WaitString

	  END

	END

	SELECT *
	FROM   #RequestResult
END
