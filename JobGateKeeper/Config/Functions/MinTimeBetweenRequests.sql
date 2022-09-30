

CREATE FUNCTION [Config].[MinTimeBetweenRequests] (@Application VARCHAR(25))
RETURNS INT

AS
BEGIN
  RETURN (SELECT IsNull(Max([MinTimeBetweenRequests]), 60) AS [MinTimeBetweenRequests]
          FROM [Config].[ScheduleConfiguration]
          WHERE [Application] = @Application)
END
