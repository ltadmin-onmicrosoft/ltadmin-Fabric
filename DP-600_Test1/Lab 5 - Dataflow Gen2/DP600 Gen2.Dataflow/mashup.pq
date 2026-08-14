[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "orders_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared orders = let
  Source = Csv.Document(Web.Contents("https://raw.githubusercontent.com/MicrosoftLearning/dp-data/main/orders.csv"), [Delimiter = ",", Columns = 7, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
  #"Choose columns" = Table.SelectColumns(#"Promoted headers", {"OrderDate", "CustomerID", "LineItem", "OrderQty", "LineItemTotal"}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Choose columns", {{"OrderDate", type date}, {"OrderQty", Int64.Type}, {"LineItemTotal", type number}, {"CustomerID", Int64.Type}, {"LineItem", Int64.Type}}),
  #"Filtered rows" = Table.SelectRows(#"Changed column type 1", each [OrderDate] <> null and [OrderDate] <> ""),
  #"Filtered rows 1" = Table.SelectRows(#"Filtered rows", each [OrderQty] > 0),
  #"Renamed columns" = Table.RenameColumns(#"Filtered rows 1", {{"OrderQty", "Quantity"}, {"LineItemTotal", "Line Total"}, {"LineItem", "Item"}}),
  #"Added custom" = Table.AddColumn(#"Renamed columns", "Unit Price", each [Line Total] / [Quantity], type number),
  #"Rounded off" = Table.TransformColumns(#"Added custom", {{"Unit Price", each Number.Round(_, 2), type number}})
in
  #"Rounded off";
shared orders_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "02cd22f9-be7f-4ff8-a77e-4c7e778d9065"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "600357f4-b37c-41c3-82da-e19f01d4e029"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "orders", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
