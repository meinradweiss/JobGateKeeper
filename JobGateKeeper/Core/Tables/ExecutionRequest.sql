CREATE TABLE [Core].[ExecutionRequest] (
    [ExecutionRequestGId]   UNIQUEIDENTIFIER CONSTRAINT [DF__tmp_ms_xx__Execu__536D5C82] DEFAULT (newid()) NOT NULL,
    [ExecutionRequestId]    INT              CONSTRAINT [DF__tmp_ms_xx__Execu__546180BB] DEFAULT (NEXT VALUE FOR [Core].[Id]) NOT NULL,
    [Application]           VARCHAR (25)     CONSTRAINT [DF__tmp_ms_xx__Appli__5555A4F4] DEFAULT ('App1') NOT NULL,
    [RequestStatus]         VARCHAR (25)     NOT NULL,
    [RequestStartTime]      DATETIME2 (3)    NOT NULL,
    [RequestFullfilledTime] DATETIME2 (3)    NULL,
    [NextValidStartTime]    DATETIME2 (3)    NULL,
    [DenyReason]            VARCHAR (255)    NULL,
    [ExecutionResult]       NVARCHAR (MAX)   NULL,
    CONSTRAINT [CK__Execution__Reque__5649C92D] CHECK ([RequestStatus]='Denied' OR [RequestStatus]='Granted')
);


GO
CREATE CLUSTERED INDEX [CIX_Core_ExecutionRequest_RequestStartTime]
    ON [Core].[ExecutionRequest]([RequestStartTime] ASC);

