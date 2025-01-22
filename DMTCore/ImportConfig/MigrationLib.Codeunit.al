codeunit 91003 DMTMigrationLib
{
    procedure FindFieldNameInOldVersion(FieldName: Text; TargetTableNo: Integer; var OldFieldName: Text) Found: Boolean
    begin
        Clear(OldFieldName);
        case true of
            (TargetTableNo = Database::Customer) and (FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = Database::Vendor) and (FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = Database::Contact) and (FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = Database::Item) and (FieldName = 'Country/Region of Origin Code'):
                OldFieldName := 'Country of Origin Code';
            (TargetTableNo = Database::Item) and (FieldName = 'Time Bucket'):
                OldFieldName := 'Reorder Cycle';
            (TargetTableNo = Database::"Item Reference") and (FieldName = 'Reference Type'):
                OldFieldName := 'Cross-Reference Type';
            (TargetTableNo = Database::"Item Reference") and (FieldName = 'Reference Type No.'):
                OldFieldName := 'Cross-Reference Type No.';
            (TargetTableNo = Database::"Item Reference") and (FieldName = 'Reference No.'):
                OldFieldName := 'Cross-Reference No.';
        end;
        Found := OldFieldName <> '';
    end;

    procedure ApplyKnownValidationRules(var ImportConfigLine: Record DMTImportConfigLine)
    var
        TargetField: Record Field;
        ValidationType: Enum DMTFieldValidationType;
        KnownFixedValue: Text;
    begin
        TargetField.Get(ImportConfigLine."Target Table ID", ImportConfigLine."Target Field No.");
        if FindKnownUseValidateValue(TargetField, ValidationType) then
            ImportConfigLine."Validation Type" := ValidationType;
        if FindKnownFixedValue(TargetField, KnownFixedValue) then begin
            ImportConfigLine.Validate("Custom Value Type", ImportConfigLine."Custom Value Type"::"Fixed Value");
            ImportConfigLine.Validate("Custom Value", KnownFixedValue);
        end;
        if FindKnownFieldsToIgnore(TargetField) then
            ImportConfigLine."Processing Action" := ImportConfigLine."Processing Action"::Ignore;
    end;

    local procedure FindKnownUseValidateValue(TargetField: Record Field; var KnownValidationType: Enum DMTFieldValidationType) Found: Boolean
    begin
        KnownValidationType := KnownValidationType::AlwaysValidate;
        Found := true;
        case true of
            IsMatch(TargetField, 'VAT Registration No.'),
            IsMatch(TargetField, Database::Location, 'ESCM In Behalf of Customer No.'),
            IsMatch(TargetField, Database::"Stockkeeping Unit", 'Phys Invt Counting Period Code'),
            IsMatch(TargetField, Database::"Stockkeeping Unit", 'Standard Cost'),
            IsMatch(TargetField, Database::"G/L Account", 'Totaling'),
            IsMatch(TargetField, Database::Customer, 'Primary Contact No.'),
            IsMatch(TargetField, Database::Customer, 'Contact'),
            IsMatch(TargetField, Database::Customer, 'Block Payment Tolerance'),
            IsMatch(TargetField, Database::Customer, 'Bill-to Customer No.'),
            IsMatch(TargetField, Database::Vendor, 'Primary Contact No.'),
            IsMatch(TargetField, Database::Vendor, 'Contact'),
            IsMatch(TargetField, Database::Vendor, 'Prices Including VAT'),
            IsMatch(TargetField, Database::Vendor, 'Pay-to Vendor No.'),
            IsMatch(TargetField, Database::Contact, 'Company No.'),
            IsMatch(TargetField, Database::Contact, 'Company Name'),
            IsMatch(TargetField, Database::Contact, 'First Name'),
            IsMatch(TargetField, Database::Contact, 'Middle Name'),
            IsMatch(TargetField, Database::Contact, 'Surname'),
            IsMatch(TargetField, Database::Item, 'Sales Unit of Measure'),
            IsMatch(TargetField, Database::Item, 'Purch. Unit of Measure'),
            IsMatch(TargetField, Database::Item, 'Unit Cost'),
            IsMatch(TargetField, Database::Item, 'Rounding Precision'),
            IsMatch(TargetField, Database::Item, 'Standard Cost'),
            IsMatch(TargetField, Database::Item, 'Indirect Cost %'),
                IsMatch(TargetField, Database::"Item Unit of Measure", 'Qty. per Unit of Measure'),
            IsMatch(TargetField, Database::"Routing Header", 'Status'),
            IsMatch(TargetField, Database::"Extended Text Header", 'Language Code'),
            IsMatch(TargetField, Database::"Extended Text Header", 'All Language Codes'),
            IsMatch(TargetField, Database::"Interaction Template", 'Language Code (Default)'),
            IsMatch(TargetField, Database::"Sales Header", 'Bill-to Customer No.'),
            IsMatch(TargetField, Database::"Sales Header", 'Sell-to Customer Name'),
            IsMatch(TargetField, Database::"Dimension Value", 'Dimension Value ID'),
            IsMatch(TargetField, Database::"General Ledger Setup", 'Acc. Sched. for Balance Sheet'),
            IsMatch(TargetField, Database::"General Ledger Setup", 'Acc. Sched. for Income Stmt.'),
            IsMatch(TargetField, Database::"General Ledger Setup", 'Acc. Sched. for Cash Flow Stmt'),
            IsMatch(TargetField, Database::"General Ledger Setup", 'Acc. Sched. for Retained Earn.'):
                KnownValidationType := KnownValidationType::AssignWithoutValidate;
            else
                Found := false;
        end;
    end;

    procedure IsMatch(Field: Record Field; Field1: Text) IsMatch: Boolean
    begin
        IsMatch := (Field.FieldName = Field1);
    end;

    procedure IsMatch(Field: Record Field; TableNo: Integer; FieldName: Text) IsMatch: Boolean
    begin
        IsMatch := (Field.TableNo = TableNo) and (Field.FieldName = FieldName);
    end;

    local procedure FindKnownFixedValue(TargetField: Record Field; KnownFixedValue: Text) Found: Boolean
    begin
        KnownFixedValue := '';
        Found := true;
        case true of
            IsMatch(TargetField, Database::"Production BOM Header", 'Status'),
            IsMatch(TargetField, Database::"Production BOM Version", 'Status'):
                KnownFixedValue := Format(Enum::"BOM Status"::"Under Development");
            IsMatch(TargetField, Database::"Routing Header", 'Status'):
                KnownFixedValue := Format(Enum::"Routing Status"::"Under Development");
            else
                Found := false;
        end;
    end;

    local procedure FindKnownFieldsToIgnore(TargetField: Record Field) Found: Boolean
    begin
        case true of

            IsMatch(TargetField, Database::Item, 'Picture'),
            IsMatch(TargetField, Database::"Company Information", 'Picture'),

            IsMatch(TargetField, Database::"Sales Header", 'Invoice'),
            IsMatch(TargetField, Database::"Sales Header", 'Ship'),
            IsMatch(TargetField, Database::"Sales Header", 'Receive'),

            IsMatch(TargetField, Database::"Sales Line", 'Job No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Job Contract Entry No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Quantity Invoiced'),
            IsMatch(TargetField, Database::"Sales Line", 'Return Qty. Received'),
            IsMatch(TargetField, Database::"Sales Line", 'Shipment No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Return Receipt No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Blanket Order No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Prepmt. Amt. Inv.'),

            IsMatch(TargetField, Database::"Purchase Line", 'Quantity Received'),
            IsMatch(TargetField, Database::"Purchase Line", 'Quantity Invoiced'),
            IsMatch(TargetField, Database::"Purchase Line", 'Return Qty. Shipped'),
            IsMatch(TargetField, Database::"Purchase Line", 'Receipt No.'),
            IsMatch(TargetField, Database::"Purchase Line", 'Return Shipment No.'),
            IsMatch(TargetField, Database::"Purchase Line", 'Blanket Order No.'):
                Found := true;
            else
                Found := false;
        end;
    end;

    procedure UpdateGlobalDimNoInDimensionValues()
    var
        DimValue: Record "Dimension Value";
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();

        if GLSetup."Global Dimension 1 Code" <> '' then begin
            DimValue.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
            DimValue.ModifyAll("Global Dimension No.", 1);
        end;

        if GLSetup."Global Dimension 2 Code" <> '' then begin
            DimValue.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
            DimValue.ModifyAll("Global Dimension No.", 2);
        end;
    end;

    internal procedure RunPostProcessingFor(var ImportConfigHeader: Record DMTImportConfigHeader)
    begin
        if ImportConfigHeader."Target Table ID" = Database::"Dimension Value" then
            UpdateGlobalDimNoInDimensionValues();
    end;

    internal procedure ApplyKnownProcessingRulesToNewImportConfigHeaderRec(var ImportConfigHeader: Record DMTImportConfigHeader)
    begin
        case ImportConfigHeader."Target Table ID" of
            Database::"Item Vendor",
          Database::Customer,
          Database::Vendor,
          Database::"Extended Text Header":   /* Avoid renumbering key field "Text No." */
                ImportConfigHeader."Use OnInsert Trigger" := false;
        end;
    end;

    internal procedure GetNAVTableIDFromFileName(var NAVTableID: Integer; var NAVTableCaption: Text; SourceFileName: Text) OK: Boolean
    var
        TypeHelper: Codeunit "Type Helper";
        Splitted: List of [Text];
        numberText: Text;
    begin
        ok := true;
        NAVTableCaption := SourceFileName;
        Splitted := NAVTableCaption.Split('_');
        numberText := Splitted.Get(1);
        if not TypeHelper.IsNumeric(numberText) then
            exit(false);
        Evaluate(NAVTableID, numberText);
        NAVTableCaption := SourceFileName.TrimStart(StrSubstNo('%1_', numberText));
    end;

    procedure CreateNAVExportFileNameDictionary(var NAVExportFileNamesDict: Dictionary of [Text, Integer])
    var
        tableMetadata: Record "Table Metadata";
        FeatureKey: Record "Feature Key";
        fileNameFromCaption: Text;
    begin
        tableMetadata.SetRange(ID, 0, 2000000000);
        tableMetadata.SetRange(ObsoleteState, tableMetadata.ObsoleteState::No);
        tableMetadata.SetFilter(ID, '<>49&<>55&<>600&<>601&<>1570&<>1571');
        tableMetadata.SetRange(DataIsExternal, false);
        tableMetadata.FindSet();
        repeat
            fileNameFromCaption := createNAVExportFileName(tableMetadata.Caption);
            if not NAVExportFileNamesDict.ContainsKey(fileNameFromCaption) then
                NAVExportFileNamesDict.Add(fileNameFromCaption, tableMetadata.ID);
        until tableMetadata.Next() = 0;

        if FeatureKey.Get('ReplaceIntrastat') and (FeatureKey.Enabled <> FeatureKey.Enabled::"All Users") then begin
            tableMetadata.Get(261);
            NAVExportFileNamesDict.Set(createNAVExportFileName(tableMetadata.Caption), tableMetadata.ID);
            tableMetadata.Get(262);
            NAVExportFileNamesDict.Set(createNAVExportFileName(tableMetadata.Caption), tableMetadata.ID);
        end;

        NAVExportFileNamesDict.Add(createNAVExportFileName('PLZ-Code'), 225);
        NAVExportFileNamesDict.Add(createNAVExportFileName('Bundesland'), 284);
        NAVExportFileNamesDict.Add(createNAVExportFileName('Projekt Einrichtung'), 315);
        NAVExportFileNamesDict.Add(createNAVExportFileName('Produktgruppe'), 5723);
        NAVExportFileNamesDict.Add(createNAVExportFileName('Team Mitarbeiter'), 5084);
        NAVExportFileNamesDict.Add(createNAVExportFileName('Spezifische Kalenderänderung'), 7602);
        NAVExportFileNamesDict.Add(createNAVExportFileName('Spezifische Kalenderposten'), 7603);
        NAVExportFileNamesDict.Add(createNAVExportFileName('Datensatzverknüpfung'), 2000000068);
    end;

    procedure createNAVExportFileName(tableCaption: Text) ExportCSVFileName: Text
    begin
        ExportCSVFileName := StrSubstNo('%1.csv', ConvertStr(tableCaption, '<>*\/|"', '_______'));
    end;

    procedure HandleObsoleteNAVTargetTable(NAVTableID: Integer) TargetTableID: Integer
    var
        FeatureKey: Record "Feature Key";
        TableMetadata: Record "Table Metadata";
    begin
        if TableMetadata.Get(NAVTableID) then begin
            if not (TableMetadata.ObsoleteState in [TableMetadata.ObsoleteState::Removed, TableMetadata.ObsoleteState::Pending]) then begin
                TargetTableID := TableMetadata.ID;
            end else begin
                case NAVTableID of
                    261, 262:
                        begin
                            if FeatureKey.Get('ReplaceIntrastat') and (FeatureKey.Enabled <> FeatureKey.Enabled::"All Users") then
                                exit(NAVTableID)
                            else
                                Message('ToDo - Find new TableID for 261,262 (ReplaceIntrastat)');
                        end;
                    5105:
                        TargetTableID := Database::"Customer Templ.";
                    5717:
                        TargetTableID := Database::"Item Reference";
                    7002,
                    7004,
                    7012,
                    7014:
                        begin
                            if FeatureKey.Get('SalesPrices') and (FeatureKey.Enabled = FeatureKey.Enabled::"All Users") then
                                TargetTableID := Database::"Price List Line"
                            else
                                TargetTableID := NAVTableID;
                        end;

                    5005350:
                        TargetTableID := 5875;

                    5005351:
                        TargetTableID := 5876;
                    5005361:
                        TargetTableID := 5886;
                    5723:
                        TargetTableID := 5722;
                    else
                        Message('unhandled obsolete Table %1', NAVTableID);
                end;
            end;
        end;
    end;

}