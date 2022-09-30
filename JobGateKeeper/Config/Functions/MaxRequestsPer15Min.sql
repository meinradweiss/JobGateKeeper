

CREATE FUNCTION [Config].[MaxRequestsPer15Min] (@Application VARCHAR(25))
RETURNS INT

AS
BEGIN
  RETURN (SELECT IsNull(Max([MaxRequestsPer15Min]), 15) AS [MaxRequestsPer15Min]
          FROM [Config].[ScheduleConfiguration]
          WHERE [Application] = @Application)
END

