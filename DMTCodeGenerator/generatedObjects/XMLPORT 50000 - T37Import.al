xmlport 90012 T37Import
{
    CaptionML = DEU = 'Verkaufszeile(DMT)', ENU = 'Sales Line(DMT)';
    Direction = Import;
    FieldSeparator = '<TAB>';
    FieldDelimiter = '<None>';
    TextEncoding = UTF8;
    Format = VariableText;
    FormatEvaluate = Xml;

    schema
    {
        textelement(Root)
        {
            tableelement(Sales_Line; T37Buffer)
            {
                XmlName = 'Sales_Line';
                fieldelement("DocumentType"; Sales_Line."Document Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SelltoCustomerNo"; Sales_Line."Sell-to Customer No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DocumentNo"; Sales_Line."Document No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LineNo"; Sales_Line."Line No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Type"; Sales_Line."Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("No"; Sales_Line."No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LocationCode"; Sales_Line."Location Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PostingGroup"; Sales_Line."Posting Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShipmentDate"; Sales_Line."Shipment Date") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Description"; Sales_Line."Description") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Description2"; Sales_Line."Description 2") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UnitofMeasure"; Sales_Line."Unit of Measure") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Quantity"; Sales_Line."Quantity") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OutstandingQuantity"; Sales_Line."Outstanding Quantity") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QtytoInvoice"; Sales_Line."Qty. to Invoice") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QtytoShip"; Sales_Line."Qty. to Ship") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UnitPrice"; Sales_Line."Unit Price") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UnitCostLCY"; Sales_Line."Unit Cost (LCY)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VAT"; Sales_Line."VAT %") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LineDiscount"; Sales_Line."Line Discount %") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LineDiscountAmount"; Sales_Line."Line Discount Amount") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Amount"; Sales_Line."Amount") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AmountIncludingVAT"; Sales_Line."Amount Including VAT") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AllowInvoiceDisc"; Sales_Line."Allow Invoice Disc.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GrossWeight"; Sales_Line."Gross Weight") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NetWeight"; Sales_Line."Net Weight") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UnitsperParcel"; Sales_Line."Units per Parcel") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UnitVolume"; Sales_Line."Unit Volume") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AppltoItemEntry"; Sales_Line."Appl.-to Item Entry") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShortcutDimension1Code"; Sales_Line."Shortcut Dimension 1 Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShortcutDimension2Code"; Sales_Line."Shortcut Dimension 2 Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CustomerPriceGroup"; Sales_Line."Customer Price Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("JobNo"; Sales_Line."Job No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("WorkTypeCode"; Sales_Line."Work Type Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OutstandingAmount"; Sales_Line."Outstanding Amount") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QtyShippedNotInvoiced"; Sales_Line."Qty. Shipped Not Invoiced") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShippedNotInvoiced"; Sales_Line."Shipped Not Invoiced") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QuantityShipped"; Sales_Line."Quantity Shipped") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QuantityInvoiced"; Sales_Line."Quantity Invoiced") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShipmentNo"; Sales_Line."Shipment No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShipmentLineNo"; Sales_Line."Shipment Line No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Profit"; Sales_Line."Profit %") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BilltoCustomerNo"; Sales_Line."Bill-to Customer No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("InvDiscountAmount"; Sales_Line."Inv. Discount Amount") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PurchaseOrderNo"; Sales_Line."Purchase Order No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PurchOrderLineNo"; Sales_Line."Purch. Order Line No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DropShipment"; Sales_Line."Drop Shipment") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GenBusPostingGroup"; Sales_Line."Gen. Bus. Posting Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GenProdPostingGroup"; Sales_Line."Gen. Prod. Posting Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VATCalculationType"; Sales_Line."VAT Calculation Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TransactionType"; Sales_Line."Transaction Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TransportMethod"; Sales_Line."Transport Method") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AttachedtoLineNo"; Sales_Line."Attached to Line No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ExitPoint"; Sales_Line."Exit Point") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Area"; Sales_Line."Area") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TransactionSpecification"; Sales_Line."Transaction Specification") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TaxAreaCode"; Sales_Line."Tax Area Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TaxLiable"; Sales_Line."Tax Liable") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TaxGroupCode"; Sales_Line."Tax Group Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VATBusPostingGroup"; Sales_Line."VAT Bus. Posting Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VATProdPostingGroup"; Sales_Line."VAT Prod. Posting Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CurrencyCode"; Sales_Line."Currency Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OutstandingAmountLCY"; Sales_Line."Outstanding Amount (LCY)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShippedNotInvoicedLCY"; Sales_Line."Shipped Not Invoiced (LCY)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Reserve"; Sales_Line."Reserve") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BlanketOrderNo"; Sales_Line."Blanket Order No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BlanketOrderLineNo"; Sales_Line."Blanket Order Line No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VATBaseAmount"; Sales_Line."VAT Base Amount") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UnitCost"; Sales_Line."Unit Cost") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SystemCreatedEntry"; Sales_Line."System-Created Entry") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LineAmount"; Sales_Line."Line Amount") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VATDifference"; Sales_Line."VAT Difference") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("InvDiscAmounttoInvoice"; Sales_Line."Inv. Disc. Amount to Invoice") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VATIdentifier"; Sales_Line."VAT Identifier") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ICPartnerRefType"; Sales_Line."IC Partner Ref. Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ICPartnerReference"; Sales_Line."IC Partner Reference") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Prepayment"; Sales_Line."Prepayment %") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepmtLineAmount"; Sales_Line."Prepmt. Line Amount") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepmtAmtInv"; Sales_Line."Prepmt. Amt. Inv.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepmtAmtInclVAT"; Sales_Line."Prepmt. Amt. Incl. VAT") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepaymentAmount"; Sales_Line."Prepayment Amount") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepmtVATBaseAmt"; Sales_Line."Prepmt. VAT Base Amt.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepaymentVAT"; Sales_Line."Prepayment VAT %") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepmtVATCalcType"; Sales_Line."Prepmt. VAT Calc. Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepaymentVATIdentifier"; Sales_Line."Prepayment VAT Identifier") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepaymentTaxAreaCode"; Sales_Line."Prepayment Tax Area Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepaymentTaxLiable"; Sales_Line."Prepayment Tax Liable") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepaymentTaxGroupCode"; Sales_Line."Prepayment Tax Group Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepmtAmttoDeduct"; Sales_Line."Prepmt Amt to Deduct") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepmtAmtDeducted"; Sales_Line."Prepmt Amt Deducted") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepaymentLine"; Sales_Line."Prepayment Line") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepmtAmountInvInclVAT"; Sales_Line."Prepmt. Amount Inv. Incl. VAT") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepmtAmountInvLCY"; Sales_Line."Prepmt. Amount Inv. (LCY)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ICPartnerCode"; Sales_Line."IC Partner Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepaymentVATDifference"; Sales_Line."Prepayment VAT Difference") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepmtVATDifftoDeduct"; Sales_Line."Prepmt VAT Diff. to Deduct") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrepmtVATDiffDeducted"; Sales_Line."Prepmt VAT Diff. Deducted") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("JobTaskNo"; Sales_Line."Job Task No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("JobContractEntryNo"; Sales_Line."Job Contract Entry No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VariantCode"; Sales_Line."Variant Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BinCode"; Sales_Line."Bin Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QtyperUnitofMeasure"; Sales_Line."Qty. per Unit of Measure") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Planned"; Sales_Line."Planned") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UnitofMeasureCode"; Sales_Line."Unit of Measure Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QuantityBase"; Sales_Line."Quantity (Base)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OutstandingQtyBase"; Sales_Line."Outstanding Qty. (Base)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QtytoInvoiceBase"; Sales_Line."Qty. to Invoice (Base)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QtytoShipBase"; Sales_Line."Qty. to Ship (Base)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QtyShippedNotInvdBase"; Sales_Line."Qty. Shipped Not Invd. (Base)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QtyShippedBase"; Sales_Line."Qty. Shipped (Base)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QtyInvoicedBase"; Sales_Line."Qty. Invoiced (Base)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("FAPostingDate"; Sales_Line."FA Posting Date") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DepreciationBookCode"; Sales_Line."Depreciation Book Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DepruntilFAPostingDate"; Sales_Line."Depr. until FA Posting Date") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DuplicateinDepreciationBook"; Sales_Line."Duplicate in Depreciation Book") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UseDuplicationList"; Sales_Line."Use Duplication List") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ResponsibilityCenter"; Sales_Line."Responsibility Center") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OutofStockSubstitution"; Sales_Line."Out-of-Stock Substitution") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OriginallyOrderedNo"; Sales_Line."Originally Ordered No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OriginallyOrderedVarCode"; Sales_Line."Originally Ordered Var. Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CrossReferenceNo"; Sales_Line."Cross-Reference No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UnitofMeasureCrossRef"; Sales_Line."Unit of Measure (Cross Ref.)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CrossReferenceType"; Sales_Line."Cross-Reference Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CrossReferenceTypeNo"; Sales_Line."Cross-Reference Type No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ItemCategoryCode"; Sales_Line."Item Category Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Nonstock"; Sales_Line."Nonstock") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PurchasingCode"; Sales_Line."Purchasing Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ProductGroupCode"; Sales_Line."Product Group Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SpecialOrder"; Sales_Line."Special Order") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SpecialOrderPurchaseNo"; Sales_Line."Special Order Purchase No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SpecialOrderPurchLineNo"; Sales_Line."Special Order Purch. Line No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CompletelyShipped"; Sales_Line."Completely Shipped") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RequestedDeliveryDate"; Sales_Line."Requested Delivery Date") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PromisedDeliveryDate"; Sales_Line."Promised Delivery Date") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShippingTime"; Sales_Line."Shipping Time") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OutboundWhseHandlingTime"; Sales_Line."Outbound Whse. Handling Time") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PlannedDeliveryDate"; Sales_Line."Planned Delivery Date") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PlannedShipmentDate"; Sales_Line."Planned Shipment Date") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShippingAgentCode"; Sales_Line."Shipping Agent Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShippingAgentServiceCode"; Sales_Line."Shipping Agent Service Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AllowItemChargeAssignment"; Sales_Line."Allow Item Charge Assignment") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReturnQtytoReceive"; Sales_Line."Return Qty. to Receive") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReturnQtytoReceiveBase"; Sales_Line."Return Qty. to Receive (Base)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReturnQtyRcdNotInvd"; Sales_Line."Return Qty. Rcd. Not Invd.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RetQtyRcdNotInvdBase"; Sales_Line."Ret. Qty. Rcd. Not Invd.(Base)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReturnRcdNotInvd"; Sales_Line."Return Rcd. Not Invd.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReturnRcdNotInvdLCY"; Sales_Line."Return Rcd. Not Invd. (LCY)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReturnQtyReceived"; Sales_Line."Return Qty. Received") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReturnQtyReceivedBase"; Sales_Line."Return Qty. Received (Base)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ApplfromItemEntry"; Sales_Line."Appl.-from Item Entry") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BOMItemNo"; Sales_Line."BOM Item No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReturnReceiptNo"; Sales_Line."Return Receipt No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReturnReceiptLineNo"; Sales_Line."Return Receipt Line No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReturnReasonCode"; Sales_Line."Return Reason Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AllowLineDisc"; Sales_Line."Allow Line Disc.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CustomerDiscGroup"; Sales_Line."Customer Disc. Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("IndentureNo"; Sales_Line."Indenture No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CharacterCode"; Sales_Line."Character Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NegativeAdjmtInventory"; Sales_Line."Negative Adjmt. Inventory") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("WMSStatus"; Sales_Line."WMS Status") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QuantityfromWMS"; Sales_Line."Quantity from WMS") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("WMSPosition"; Sales_Line."WMS Position") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QuantitytoWMS"; Sales_Line."Quantity to WMS") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RowID"; Sales_Line."Row-ID") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SetQuantity"; Sales_Line."Set Quantity") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OutstandingsexclVAT"; Sales_Line."Outstandings excl.VAT") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("withoutMaterialPosting"; Sales_Line."without Material Posting") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("MainItemNo"; Sales_Line."Main Item No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("MachineType"; Sales_Line."Machine Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CustomerIdentNo"; Sales_Line."Customer Ident. No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AssemblyOrderNo"; Sales_Line."Assembly Order No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SalespersonCode"; Sales_Line."Salesperson Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CreationDate"; Sales_Line."Creation Date") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ForeignDescription"; Sales_Line."Foreign Description") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrintLine"; Sales_Line."Print Line") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LineMainItemNo"; Sales_Line."Line Main Item No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TextPosition"; Sales_Line."Text Position") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Position"; Sales_Line."Position") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Description3"; Sales_Line."Description 3") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NumberofDays"; Sales_Line."Number of Days") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LowLevelCode"; Sales_Line."Low Level Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("EntryNo"; Sales_Line."Entry No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ProdMainItem"; Sales_Line."Prod. Main Item") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("MainLocationCode"; Sales_Line."Main Location Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CreationType"; Sales_Line."Creation Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Validto"; Sales_Line."Valid to") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Priority"; Sales_Line."Priority") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NetworkingListNo"; Sales_Line."Networking List No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OrderTypeCode"; Sales_Line."Order Type Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LVSOrder"; Sales_Line."LVS Order") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ForecastStatus"; Sales_Line."Forecast Status") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("FixedAllocationQty"; Sales_Line."Fixed Allocation Qty.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DemandSalesOrderQty"; Sales_Line."Demand Sales Order Qty.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Discount1"; Sales_Line."Discount 1") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Discount2"; Sales_Line."Discount 2") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CodeVariabel"; Sales_Line."CodeVariabel") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Service"; Sales_Line."Service") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Warranty"; Sales_Line."Warranty") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("WarrantyDisc"; Sales_Line."Warranty Disc. %") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("WarrantyAmount"; Sales_Line."Warranty Amount") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ExplodeBOM"; Sales_Line."Explode BOM") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Quantityper"; Sales_Line."Quantity per") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RequestedItems"; Sales_Line."Requested Items") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PromisedProdEndingdate"; Sales_Line."Promised Prod. Ending date") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BOMCalcDate"; Sales_Line."BOM Calc. Date") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ServiceCostNo"; Sales_Line."Service Cost No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Entnahmemenge"; Sales_Line."Entnahmemenge") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BOMItemType"; Sales_Line."BOM Item Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AbgelaufenerAbsatzplan"; Sales_Line."Abgelaufener Absatzplan") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AbgelaufeneZugeordneteMenge"; Sales_Line."Abgelaufene Zugeordnete Menge") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LVRQtyModOrder"; Sales_Line."LVR Qty. Mod. Order") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ModifiedfromModOrder"; Sales_Line."Modified from Mod. Order") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Status"; Sales_Line."Status") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BOMCalcTime"; Sales_Line."BOM Calc Time") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BOMCalcUser"; Sales_Line."BOM Calc User") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AssemblyLoadrelevant"; Sales_Line."Assembly Load relevant") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NoLVRRequest"; Sales_Line."No LVR-Request") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LocationConsignment"; Sales_Line."Location Consignment") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SICYSoFoAuftragsnummer"; Sales_Line."SICY SoFo Auftragsnummer") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SICYSoFoAuftragsmenge"; Sales_Line."SICY SoFo Auftragsmenge") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("JahrKW"; Sales_Line."JahrKW") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Linie"; Sales_Line."Linie") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Durchlaufzeit"; Sales_Line."Durchlaufzeit") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DurchlaufzeitZeile"; Sales_Line."Durchlaufzeit Zeile") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RoutingHeader"; Sales_Line."Routing Header") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LVRPaketNr"; Sales_Line."LVR Paket Nr.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("EtagisDelay"; Sales_Line."Etagis Delay") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("EtagisDueDate"; Sales_Line."Etagis Due Date") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("EtagisPlanDate"; Sales_Line."Etagis Plan Date") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Übernahme"; Sales_Line."Übernahme") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CustomerLineReference"; Sales_Line."Customer Line Reference") { FieldValidate = No; MinOccurs = Zero; }
                trigger OnBeforeInsertRecord()
                begin
                    ReceivedLinesCount += 1;
                end;

                trigger OnAfterInitRecord()
                begin
                    if FileHasHeader then begin
                        FileHasHeader := false;
                        currXMLport.Skip();
                    end;
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Umgebung)
                {
                    Caption = 'Environment', locked = true;
                    field(DatabaseName; GetDatabaseName()) { Caption = 'Database', locked = true; ApplicationArea = all; }
                    field(COMPANYNAME; COMPANYNAME) { Caption = 'Company', locked = true; ApplicationArea = all; }
                }
            }
        }
    }

    trigger OnPostXmlPort()
    var
        T37Buffer: Record T37Buffer;
        LinesProcessedMsg: Label '%1 Buffer\%2 lines imported', locked = true;
    begin
        IF currXMLport.Filename <> '' then //only for manual excecution
            MESSAGE(LinesProcessedMsg, T37Buffer.TABLECAPTION, ReceivedLinesCount);
    end;

    trigger OnPreXmlPort()
    var
        T37Buffer: Record T37Buffer;
    begin
        ClearBufferBeforeImportTable(T37Buffer.RECORDID.TABLENO);
        FileHasHeader := true;
    end;

    var
        ReceivedLinesCount: Integer;
        FileHasHeader: Boolean;

    procedure RemoveSpecialChars(TextIn: Text[1024]) TextOut: Text[1024]
    var
        CharArray: Text[30];
    begin
        CharArray[1] := 9; // TAB
        CharArray[2] := 10; // LF
        CharArray[3] := 13; // CR
        exit(DELCHR(TextIn, '=', CharArray));
    end;

    local procedure ClearBufferBeforeImportTable(BufferTableNo: Integer)
    var
        BufferRef: RecordRef;
    begin
        //* Puffertabelle l”schen vor dem Import
        IF NOT currXMLport.IMPORTFILE then
            exit;
        IF BufferTableNo < 50000 then begin
            MESSAGE('Achtung: Puffertabellen ID kleiner 50000');
            exit;
        end;
        BufferRef.OPEN(BufferTableNo);
        IF NOT BufferRef.IsEmpty then
            BufferRef.DELETEALL();
    end;

    procedure GetDatabaseName(): Text[250]
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.SetRange("Server Instance ID", SERVICEINSTANCEID());
        ActiveSession.SetRange("Session ID", SESSIONID());
        ActiveSession.findfirst();
        exit(ActiveSession."Database Name");
    end;
}
