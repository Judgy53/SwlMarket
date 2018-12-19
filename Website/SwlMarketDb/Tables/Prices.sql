﻿CREATE TABLE [dbo].[Prices]
(
    [Id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [ItemId] INT NOT NULL, 
    [Time] DATETIME NOT NULL, 
    [Marks] INT NOT NULL, 
    [IPId] INT NULL
)

GO

CREATE INDEX [IX_Prices_ItemId] ON [dbo].[Prices] ([ItemId]) INCLUDE ([Id],[Time],[Marks],[IPId])
GO

CREATE TRIGGER [dbo].[Trigger_UpdateMostRecentPrice]
    ON [dbo].[Prices]
    FOR INSERT
    AS
    BEGIN
      IF EXISTS(SELECT 1 FROM MostRecentPrices WHERE MostRecentPrices.ItemId = (SELECT TOP(1) ItemId FROM inserted))
        BEGIN
          UPDATE MostRecentPrices 
		      SET MostRecentPrices.[Time] = inserted.[Time], MostRecentPrices.Marks = inserted.Marks, MostRecentPrices.IPId = inserted.IPId
          FROM inserted
		      INNER JOIN MostRecentPrices
		      ON MostRecentPrices.ItemId = inserted.ItemId
        END
      ELSE
        BEGIN
          INSERT INTO MostRecentPrices (ItemId, [Time], Marks, IPId)
		      SELECT ItemId, [Time], Marks, IPId
		      FROM inserted
        END
    END