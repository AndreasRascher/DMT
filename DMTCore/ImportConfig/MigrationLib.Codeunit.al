codeunit 91003 DMTMigrationLib
{
    procedure FindFieldNameInOldVersion(FieldName: Text; TargetTableNo: Integer; var OldFieldName: Text) Found: Boolean
    begin
        //* Hier Felder eintragen die in neueren Versionen umbenannt wurden, deren Werte aber 1:1 kopiert werden können
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
            // Item Cross Reference -> Item Reference
            (TargetTableNo = Database::"Item Reference") and (FieldName = 'Reference Type'):
                OldFieldName := 'Cross-Reference Type';
            (TargetTableNo = Database::"Item Reference") and (FieldName = 'Reference Type No.'):
                OldFieldName := 'Cross-Reference Type No.';
            (TargetTableNo = Database::"Item Reference") and (FieldName = 'Reference No.'):
                OldFieldName := 'Cross-Reference No.';
        end; // end_CASE
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
        if FindKnownFixedValue(TargetField, KnownFixedValue) then
            ImportConfigLine.Validate("Fixed Value", KnownFixedValue);
        if FindKnownFieldsToIgnore(TargetField) then
            ImportConfigLine."Processing Action" := ImportConfigLine."Processing Action"::Ignore;
    end;

    /// <summary>
    /// List of known fields with blocking logic(ValidateCode / Self references in Table Telations). Validation type is set to AssignWithoutValidate.
    /// </summary>
    /// <param name="TargetField"></param>
    /// <param name="KnownValidationType"></param>
    /// <returns></returns>
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
            IsMatch(TargetField, Database::Customer, 'Payment Terms Id'),     // ID Values clear the associated field
            IsMatch(TargetField, Database::Customer, 'Payment Method Id'),    // ID Values clear the associated field
            IsMatch(TargetField, Database::Customer, 'Currency Id'),          // ID Values clear the associated field
            IsMatch(TargetField, Database::Customer, 'Contact ID'),           // ID Values clear the associated field
            IsMatch(TargetField, Database::Customer, 'Tax Area ID'),          // ID Values clear the associated field
            IsMatch(TargetField, Database::Vendor, 'Primary Contact No.'),
            IsMatch(TargetField, Database::Vendor, 'Contact'),
            IsMatch(TargetField, Database::Vendor, 'Prices Including VAT'),
            IsMatch(TargetField, Database::Vendor, 'Pay-to Vendor No.'),
            IsMatch(TargetField, Database::Vendor, 'Payment Terms Id'),     // ID Values clear the associated field
            IsMatch(TargetField, Database::Vendor, 'Payment Method Id'),    // ID Values clear the associated field
            IsMatch(TargetField, Database::Vendor, 'Currency Id'),          // ID Values clear the associated field
            IsMatch(TargetField, Database::Contact, 'Company No.'),
            IsMatch(TargetField, Database::Contact, 'Company Name'),  // Avoid Dialog
            IsMatch(TargetField, Database::Contact, 'First Name'),  // Avoid ProcessNameChange to clear Names
            IsMatch(TargetField, Database::Contact, 'Middle Name'),
            IsMatch(TargetField, Database::Contact, 'Surname'),
            IsMatch(TargetField, Database::Item, 'Sales Unit of Measure'),
            IsMatch(TargetField, Database::Item, 'Purch. Unit of Measure'),
            IsMatch(TargetField, Database::Item, 'Unit Cost'),
            IsMatch(TargetField, Database::Item, 'Rounding Precision'),
            IsMatch(TargetField, Database::Item, 'Standard Cost'),
            IsMatch(TargetField, Database::Item, 'Indirect Cost %'),
            IsMatch(TargetField, Database::Item, 'Unit of Measure Id'),           // ID Values clear the associated field            
            IsMatch(TargetField, Database::Item, 'Tax Group Id'),                 // ID Values clear the associated field
            IsMatch(TargetField, Database::Item, 'Item Category Id'),             // ID Values clear the associated field
            IsMatch(TargetField, Database::Item, 'Inventory Posting Group Id'),   // ID Values clear the associated field
            IsMatch(TargetField, Database::Item, 'Gen. Prod. Posting Group Id'),  // ID Values clear the associated field
            IsMatch(TargetField, Database::"Item Unit of Measure", 'Qty. per Unit of Measure'),
            IsMatch(TargetField, Database::"Routing Header", 'Status'),
            IsMatch(TargetField, Database::"Extended Text Header", 'Language Code'), /* Possible in old version to have Language Code + All Language */
            IsMatch(TargetField, Database::"Extended Text Header", 'All Language Codes'), /* Possible in old version to have Language Code + All Language */
            IsMatch(TargetField, Database::"Interaction Template", 'Language Code (Default)'), /* Avoid confirm */
            IsMatch(TargetField, Database::"Sales Header", 'Bill-to Customer No.'), /* Avoid confirm */
             IsMatch(TargetField, Database::"Sales Header", 'Sell-to Customer Name'): /* Avoid LookUp Dialog */
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
            // Picture BLOBs
            IsMatch(TargetField, Database::Item, 'Picture'),
            IsMatch(TargetField, Database::"Company Information", 'Picture'),
            // Sales Header
            IsMatch(TargetField, Database::"Sales Header", 'Invoice'),
            IsMatch(TargetField, Database::"Sales Header", 'Ship'),
            IsMatch(TargetField, Database::"Sales Header", 'Receive'),
            // Testsfields on Recreate SalesLine
            IsMatch(TargetField, Database::"Sales Line", 'Job No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Job Contract Entry No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Quantity Invoiced'),
            IsMatch(TargetField, Database::"Sales Line", 'Return Qty. Received'),
            IsMatch(TargetField, Database::"Sales Line", 'Shipment No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Return Receipt No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Blanket Order No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Prepmt. Amt. Inv.'),
            // Testfields on Recreate PurchLine
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

    procedure CreateNAVExportFileNameDictionary(var NAVExportFileNamesDict: Dictionary of [Text, Integer])
    var
        tableMetadata: Record "Table Metadata";
        FeatureKey: Record "Feature Key";
        fileNameFromCaption: Text;
    begin
        // From existing table captions
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

        //FeatureKey: ReplaceIntrastat
        if FeatureKey.Get('ReplaceIntrastat') and (FeatureKey.Enabled <> FeatureKey.Enabled::"All Users") then begin
            // add obsolete tables if feature is disabled
            tableMetadata.Get(261);
            NAVExportFileNamesDict.Set(createNAVExportFileName(tableMetadata.Caption), tableMetadata.ID);
            tableMetadata.Get(262);
            NAVExportFileNamesDict.Set(createNAVExportFileName(tableMetadata.Caption), tableMetadata.ID);
        end;

        // Known renamed tables
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
        // Feature: If Target Table Obsolete, switch to alternative
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
                    5105: // Customer Template
                        TargetTableID := Database::"Customer Templ.";
                    5717: //Item Cross Reference
                        TargetTableID := Database::"Item Reference";
                    7002,// Sales Price - 'Replaced by the new implementation (V16) of price calculation: table Price List Line'
                    7004,// Sales Line Discount - 'Replaced by the new implementation (V16) of price calculation: table Price List Line'
                    7012,// Purchase Price - 'Replaced by the new implementation (V16) of price calculation: table Price List Line'
                    7014:// Purchase Line Discount - 'Replaced by the new implementation (V16) of price calculation: table Price List Line'
                        begin
                            if FeatureKey.Get('SalesPrices') and (FeatureKey.Enabled = FeatureKey.Enabled::"All Users") then
                                TargetTableID := Database::"Price List Line"
                            else
                                TargetTableID := NAVTableID;
                        end;
                    //5005350 "Phys. Inventory Order Header"
                    //5875 "Phys. Invt. Order Header
                    5005350:
                        TargetTableID := 5875; //5875
                    // 5005351 "Phys. Inventory Order Line"
                    // 5876 "Phys. Invt. Order Line"
                    5005351:
                        TargetTableID := 5876; // 5876
                    // 5005361 "Expect. Phys. Inv. Track. Line"
                    // 5886 "Exp. Phys. Invt. Tracking"
                    5005361:
                        TargetTableID := 5886; //5886 
                    5723: // Product Group -> Item Category
                        TargetTableID := 5722;
                    else
                        Message('unhandled obsolete Table %1', NAVTableID);
                end;
            end;
        end;
    end;

}