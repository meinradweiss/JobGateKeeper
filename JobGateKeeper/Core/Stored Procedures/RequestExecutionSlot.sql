

CREATE PROCEDURE [Core].[RequestExecutionSlot] (@Application VARCHAR(25) = 'myApp')
AS

BEGIN

  SET NOCOUNT ON
   
  DECLARE  @Now                           DATETIME2        = GETUTCDATE()
          ,@ExecutionRequestGId           UNIQUEIDENTIFIER = NEWID()
          ,@LastGrantedRequest            DATETIME2
          ,@MinimalWaitPeriodeCheckResult INT
          ,@NumberOfGrantsInCheckPeriode  INT
          ,@MaxGrantCheckResult           INT
          ,@RequestStatus                 VARCHAR(25)   
          ,@DenyReason                    VARCHAR(255)     = NULL
		  ,@NextValidStartTime            DATETIME2        = NULL
		  ,@CheckTimeWindowSize           INT              = 15     -- Minutes

                                              
  BEGIN TRANSACTION;  


    -- Aquire application lock to make sure, that only one process can request a slot
    DECLARE @result int;  
    EXEC @result = sp_getapplock @Resource = @Application 
                                ,@LockMode = 'Exclusive';  
    IF @result <> 0 
    BEGIN  
        ROLLBACK TRANSACTION;  
        RAISERROR('Unable to Applock. Request not performed',15,1)
        RETURN -1;
    END  
    ELSE  
    BEGIN
      -- Ready to start
	  
	  -- Find last successful grant
      SELECT @LastGrantedRequest = ISNULL(MAX([RequestStartTime]), DATEADD(YEAR,-1, @Now)) 
      FROM [Core].[ExecutionRequest] 
      WHERE [RequestStatus] = 'Granted'
        AND [Application] = @Application
   
      -- Check if minimal time window is broad enough   
      SELECT @MinimalWaitPeriodeCheckResult = CASE WHEN  DATEDIFF(SECOND, @LastGrantedRequest, @Now) > Config.MinTimeBetweenRequests(@Application)
                                                    THEN  1
                                                    ELSE  0
                                              END
   
      -- Count number of grants in checked timewindow      
      SELECT @NumberOfGrantsInCheckPeriode = IsNull(COUNT(*),0)
      FROM   [Core].[ExecutionRequest] 
      WHERE  [RequestStatus] = 'Granted'
        AND  [RequestStartTime] >= DATEADD(MINUTE, -1 * @CheckTimeWindowSize, @Now)
        AND  [Application] = @Application
   
   
      SELECT @MaxGrantCheckResult = CASE WHEN  @NumberOfGrantsInCheckPeriode < Config.MaxRequestsPer15Min(@Application) 
                                          THEN  1
                                          ELSE  0
                                    END
   
    -- SELECT @MinimalWaitPeriodeCheckResult ,  @MaxGrantCheckResult  
   
   
      IF (@MinimalWaitPeriodeCheckResult = 1 AND  @MaxGrantCheckResult = 1)  
      BEGIN
        SET @RequestStatus     = 'Granted'  
      END    
      ELSE 
      BEGIN -- Deny
   
        SET @RequestStatus = 'Denied'
   
        DECLARE @NextValidStartTimeRequestsPerWindow DATETIME2
               ,@NextValidStartTimeRequestDistance   DATETIME2
               ,@NumberOfGrantsToConsider            INT
   
        -- Find next valid start based on max number of requests per time window
        SET @NumberOfGrantsToConsider = Config.MaxRequestsPer15Min(@Application)  -1
        ;WITH LastCountedGrants
        AS
        (
          SELECT top (@NumberOfGrantsToConsider) RequestStartTime               -- Get the last N-1 executions
          FROM [Core].[ExecutionRequest] 
          WHERE [RequestStatus] = 'Granted'
            AND [Application] = @Application
          ORDER BY [RequestStartTime] DESC
        )
        SELECT @NextValidStartTimeRequestsPerWindow =
              CASE WHEN  (SELECT COUNT(*)
                              FROM [Core].[ExecutionRequest] 
                              WHERE [RequestStatus] = 'Granted'
                                AND [RequestStartTime] >=  DATEADD(MINUTE, -1 * @CheckTimeWindowSize, @Now)
                                AND [Application] = @Application
                              ) >= Config.MaxRequestsPer15Min(@Application) 
                    THEN  DATEADD(SECOND, 1, DATEADD(MINUTE, @CheckTimeWindowSize, MIN(RequestStartTime)))
                    ELSE  DATEADD(SECOND, 1, MAX(RequestStartTime))
                    END
        FROM LastCountedGrants
   	    
   	    
        -- Find next valid start based on the minimal distance between calls
        SELECT @NextValidStartTimeRequestDistance = DATEADD(SECOND, Config.MinTimeBetweenRequests(@Application) + 1, MAX(RequestStartTime))
        FROM [Core].[ExecutionRequest] 
        WHERE [RequestStatus] = 'Granted'
          AND [Application] = @Application
   	    
		-- Choose the later one
        SELECT @NextValidStartTime=
                  CASE WHEN @NextValidStartTimeRequestsPerWindow > @NextValidStartTimeRequestDistance
                      THEN @NextValidStartTimeRequestsPerWindow
                      ELSE @NextValidStartTimeRequestDistance
                  END
   	    
   	    -- Generate issue list
        ;WITH IssueList
        AS
        (
            SELECT 'To close to last request'          AS DenyReason
            WHERE @MinimalWaitPeriodeCheckResult = 0
          UNION ALL
            SELECT CONCAT('To many request in last ', @CheckTimeWindowSize, ' minute') AS DenyReason
            WHERE @MaxGrantCheckResult = 0
        )
        SELECT @DenyReason=STRING_AGG(DenyReason,', ')
        FROM   IssueList
   
   
      END

      INSERT INTO [Core].[ExecutionRequest]
      (
           [ExecutionRequestGId]
          ,[Application]
          ,[RequestStatus]         
          ,[RequestStartTime]   
          ,[NextValidStartTime]
          ,[DenyReason] 
      )
      VALUES 
	  (
           @ExecutionRequestGId
          ,@Application
          ,@RequestStatus
          ,@Now 
          ,@NextValidStartTime
          ,@DenyReason
      ) 
   
      
      SELECT 
        [ExecutionRequestGId]
        ,[ExecutionRequestId]
        ,[Application]
        ,[RequestStatus]
        ,[RequestStartTime]
        ,[RequestFullfilledTime]
        ,[NextValidStartTime]
        ,DATEDIFF(SECOND, @NOW, [NextValidStartTime])       AS SecondsToWait
        ,15 * 60 / Config.MaxRequestsPer15Min(@Application) AS OptimalDelaySeconds
        ,[DenyReason]
      FROM [Core].[ExecutionRequest] 
      WHERE [ExecutionRequestGId] = @ExecutionRequestGId
   
   
      EXEC @result = sp_releaseapplock @Resource = @Application;  
 
   COMMIT TRANSACTION;  
END;  

  RETURN
END

