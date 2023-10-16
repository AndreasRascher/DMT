table 90012 T37Buffer
{
    CaptionML = DEU = 'Verkaufszeile(DMT)', ENU = 'Sales Line(DMT)';
    fields
    {
        field(1; "Document Type"; Option)
        {
            CaptionML = ENU = 'Document Type', DEU = 'Belegart';
            OptionMembers = Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order";
            OptionCaptionML = ENU = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order', DEU = 'Angebot,Auftrag,Rechnung,Gutschrift,Rahmenauftrag,Reklamation';
        }
        field(2; "Sell-to Customer No."; Code[20])
        {
            CaptionML = ENU = 'Sell-to Customer No.', DEU = 'Verk. an Deb.-Nr.';
        }
        field(3; "Document No."; Code[20])
        {
            CaptionML = ENU = 'Document No.', DEU = 'Belegnr.';
        }
        field(4; "Line No."; Integer)
        {
            CaptionML = ENU = 'Line No.', DEU = 'Zeilennr.';
        }
        field(5; "Type"; Option)
        {
            CaptionML = ENU = 'Type', DEU = 'Art';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
            OptionCaptionML = ENU = ' ,G/L Account,Item,Resource,Fixed Asset,Charge (Item)', DEU = ' ,Sachkonto,Artikel,Ressource,WG/Anlage,Zu-/Abschlag (Artikel)';
        }
        field(6; "No."; Code[20])
        {
            CaptionML = ENU = 'No.', DEU = 'Nr.';
        }
        field(7; "Location Code"; Code[10])
        {
            CaptionML = ENU = 'Location Code', DEU = 'Lagerortcode';
        }
        field(8; "Posting Group"; Code[10])
        {
            CaptionML = ENU = 'Posting Group', DEU = 'Buchungsgruppe';
        }
        field(10; "Shipment Date"; Date)
        {
            CaptionML = ENU = 'Shipment Date', DEU = 'Warenausg.-Datum';
        }
        field(11; "Description"; Text[50])
        {
            CaptionML = ENU = 'Description', DEU = 'Beschreibung';
        }
        field(12; "Description 2"; Text[50])
        {
            CaptionML = ENU = 'Description 2', DEU = 'Beschreibung 2';
        }
        field(13; "Unit of Measure"; Text[10])
        {
            CaptionML = ENU = 'Unit of Measure', DEU = 'Einheit';
        }
        field(15; "Quantity"; Decimal)
        {
            CaptionML = ENU = 'Quantity', DEU = 'Menge';
        }
        field(16; "Outstanding Quantity"; Decimal)
        {
            CaptionML = ENU = 'Outstanding Quantity', DEU = 'Restauftragsmenge';
        }
        field(17; "Qty. to Invoice"; Decimal)
        {
            CaptionML = ENU = 'Qty. to Invoice', DEU = 'Zu fakturieren';
        }
        field(18; "Qty. to Ship"; Decimal)
        {
            CaptionML = ENU = 'Qty. to Ship', DEU = 'Zu liefern';
        }
        field(22; "Unit Price"; Decimal)
        {
            CaptionML = ENU = 'Unit Price', DEU = 'VK-Preis';
        }
        field(23; "Unit Cost (LCY)"; Decimal)
        {
            CaptionML = ENU = 'Unit Cost (LCY)', DEU = 'Einstandspreis (MW)';
        }
        field(25; "VAT %"; Decimal)
        {
            CaptionML = ENU = 'VAT %', DEU = 'MwSt. %';
        }
        field(27; "Line Discount %"; Decimal)
        {
            CaptionML = ENU = 'Line Discount %', DEU = 'Zeilenrabatt %';
        }
        field(28; "Line Discount Amount"; Decimal)
        {
            CaptionML = ENU = 'Line Discount Amount', DEU = 'Zeilenrabattbetrag';
        }
        field(29; "Amount"; Decimal)
        {
            CaptionML = ENU = 'Amount', DEU = 'Betrag';
        }
        field(30; "Amount Including VAT"; Decimal)
        {
            CaptionML = ENU = 'Amount Including VAT', DEU = 'Betrag inkl. MwSt.';
        }
        field(32; "Allow Invoice Disc."; Boolean)
        {
            CaptionML = ENU = 'Allow Invoice Disc.', DEU = 'Rech.-Rabatt zulassen';
        }
        field(34; "Gross Weight"; Decimal)
        {
            CaptionML = ENU = 'Gross Weight', DEU = 'Bruttogewicht';
        }
        field(35; "Net Weight"; Decimal)
        {
            CaptionML = ENU = 'Net Weight', DEU = 'Nettogewicht';
        }
        field(36; "Units per Parcel"; Decimal)
        {
            CaptionML = ENU = 'Units per Parcel', DEU = 'Anzahl pro Paket';
        }
        field(37; "Unit Volume"; Decimal)
        {
            CaptionML = ENU = 'Unit Volume', DEU = 'Volumen';
        }
        field(38; "Appl.-to Item Entry"; Integer)
        {
            CaptionML = ENU = 'Appl.-to Item Entry', DEU = 'Ausgleich mit Artikelposten';
        }
        field(40; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionML = ENU = 'Shortcut Dimension 1 Code', DEU = 'Shortcutdimensionscode 1';
        }
        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionML = ENU = 'Shortcut Dimension 2 Code', DEU = 'Shortcutdimensionscode 2';
        }
        field(42; "Customer Price Group"; Code[10])
        {
            CaptionML = ENU = 'Customer Price Group', DEU = 'Debitorenpreisgruppe';
        }
        field(45; "Job No."; Code[20])
        {
            CaptionML = ENU = 'Job No.', DEU = 'Projektnr.';
        }
        field(52; "Work Type Code"; Code[10])
        {
            CaptionML = ENU = 'Work Type Code', DEU = 'Arbeitstypencode';
        }
        field(57; "Outstanding Amount"; Decimal)
        {
            CaptionML = ENU = 'Outstanding Amount', DEU = 'Restauftragsbetrag';
        }
        field(58; "Qty. Shipped Not Invoiced"; Decimal)
        {
            CaptionML = ENU = 'Qty. Shipped Not Invoiced', DEU = 'Lief. nicht fakt. Menge';
        }
        field(59; "Shipped Not Invoiced"; Decimal)
        {
            CaptionML = ENU = 'Shipped Not Invoiced', DEU = 'Lief. nicht fakt. Betrag';
        }
        field(60; "Quantity Shipped"; Decimal)
        {
            CaptionML = ENU = 'Quantity Shipped', DEU = 'Menge geliefert';
        }
        field(61; "Quantity Invoiced"; Decimal)
        {
            CaptionML = ENU = 'Quantity Invoiced', DEU = 'Menge fakturiert';
        }
        field(63; "Shipment No."; Code[20])
        {
            CaptionML = ENU = 'Shipment No.', DEU = 'Lieferungsnr.';
        }
        field(64; "Shipment Line No."; Integer)
        {
            CaptionML = ENU = 'Shipment Line No.', DEU = 'Lieferzeilennr.';
        }
        field(67; "Profit %"; Decimal)
        {
            CaptionML = ENU = 'Profit %', DEU = 'DB %';
        }
        field(68; "Bill-to Customer No."; Code[20])
        {
            CaptionML = ENU = 'Bill-to Customer No.', DEU = 'Rech. an Deb.-Nr.';
        }
        field(69; "Inv. Discount Amount"; Decimal)
        {
            CaptionML = ENU = 'Inv. Discount Amount', DEU = 'Rechnungsrabattbetrag';
        }
        field(71; "Purchase Order No."; Code[20])
        {
            CaptionML = ENU = 'Purchase Order No.', DEU = 'Bestellungsnr.';
        }
        field(72; "Purch. Order Line No."; Integer)
        {
            CaptionML = ENU = 'Purch. Order Line No.', DEU = 'Bestellungszeilennr.';
        }
        field(73; "Drop Shipment"; Boolean)
        {
            CaptionML = ENU = 'Drop Shipment', DEU = 'Direktlieferung';
        }
        field(74; "Gen. Bus. Posting Group"; Code[10])
        {
            CaptionML = ENU = 'Gen. Bus. Posting Group', DEU = 'Geschäftsbuchungsgruppe';
        }
        field(75; "Gen. Prod. Posting Group"; Code[10])
        {
            CaptionML = ENU = 'Gen. Prod. Posting Group', DEU = 'Produktbuchungsgruppe';
        }
        field(77; "VAT Calculation Type"; Option)
        {
            CaptionML = ENU = 'VAT Calculation Type', DEU = 'MwSt.-Berechnungsart';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
            OptionCaptionML = ENU = 'Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax', DEU = 'Normale MwSt.,Erwerbsbesteuerung,Nur MwSt.,Verkaufssteuer';
        }
        field(78; "Transaction Type"; Code[10])
        {
            CaptionML = ENU = 'Transaction Type', DEU = 'Art des Geschäftes';
        }
        field(79; "Transport Method"; Code[10])
        {
            CaptionML = ENU = 'Transport Method', DEU = 'Verkehrszweig';
        }
        field(80; "Attached to Line No."; Integer)
        {
            CaptionML = ENU = 'Attached to Line No.', DEU = 'Gehört zu Zeilennr.';
        }
        field(81; "Exit Point"; Code[10])
        {
            CaptionML = ENU = 'Exit Point', DEU = 'Einladehafen';
        }
        field(82; "Area"; Code[10])
        {
            CaptionML = ENU = 'Area', DEU = 'Ursprungsregion';
        }
        field(83; "Transaction Specification"; Code[10])
        {
            CaptionML = ENU = 'Transaction Specification', DEU = 'Verfahren';
        }
        field(85; "Tax Area Code"; Code[20])
        {
            CaptionML = ENU = 'Tax Area Code', DEU = 'Steuergebietscode';
        }
        field(86; "Tax Liable"; Boolean)
        {
            CaptionML = ENU = 'Tax Liable', DEU = 'Steuerpflichtig';
        }
        field(87; "Tax Group Code"; Code[10])
        {
            CaptionML = ENU = 'Tax Group Code', DEU = 'Steuergruppencode';
        }
        field(89; "VAT Bus. Posting Group"; Code[10])
        {
            CaptionML = ENU = 'VAT Bus. Posting Group', DEU = 'MwSt.-Geschäftsbuchungsgruppe';
        }
        field(90; "VAT Prod. Posting Group"; Code[10])
        {
            CaptionML = ENU = 'VAT Prod. Posting Group', DEU = 'MwSt.-Produktbuchungsgruppe';
        }
        field(91; "Currency Code"; Code[10])
        {
            CaptionML = ENU = 'Currency Code', DEU = 'Währungscode';
        }
        field(92; "Outstanding Amount (LCY)"; Decimal)
        {
            CaptionML = ENU = 'Outstanding Amount (LCY)', DEU = 'Restauftragsbetrag (MW)';
        }
        field(93; "Shipped Not Invoiced (LCY)"; Decimal)
        {
            CaptionML = ENU = 'Shipped Not Invoiced (LCY)', DEU = 'Lief. nicht fakt. Betrag (MW)';
        }
        field(96; "Reserve"; Option)
        {
            CaptionML = ENU = 'Reserve', DEU = 'Reservieren';
            OptionMembers = Never,Optional,Always;
            OptionCaptionML = ENU = 'Never,Optional,Always', DEU = 'Nie,Optional,Immer';
        }
        field(97; "Blanket Order No."; Code[20])
        {
            CaptionML = ENU = 'Blanket Order No.', DEU = 'Rahmenauftragsnr.';
        }
        field(98; "Blanket Order Line No."; Integer)
        {
            CaptionML = ENU = 'Blanket Order Line No.', DEU = 'Rahmenauftragszeilennr.';
        }
        field(99; "VAT Base Amount"; Decimal)
        {
            CaptionML = ENU = 'VAT Base Amount', DEU = 'MwSt.-Bemessungsgrundlage';
        }
        field(100; "Unit Cost"; Decimal)
        {
            CaptionML = ENU = 'Unit Cost', DEU = 'Einstandspreis';
        }
        field(101; "System-Created Entry"; Boolean)
        {
            CaptionML = ENU = 'System-Created Entry', DEU = 'Systembuchung';
        }
        field(103; "Line Amount"; Decimal)
        {
            CaptionML = ENU = 'Line Amount', DEU = 'Zeilenbetrag';
        }
        field(104; "VAT Difference"; Decimal)
        {
            CaptionML = ENU = 'VAT Difference', DEU = 'MwSt.-Differenz';
        }
        field(105; "Inv. Disc. Amount to Invoice"; Decimal)
        {
            CaptionML = ENU = 'Inv. Disc. Amount to Invoice', DEU = 'Rechnungsrabattbetrag zu fakt.';
        }
        field(106; "VAT Identifier"; Code[10])
        {
            CaptionML = ENU = 'VAT Identifier', DEU = 'MwSt.-Kennzeichen';
        }
        field(107; "IC Partner Ref. Type"; Option)
        {
            CaptionML = ENU = 'IC Partner Ref. Type', DEU = 'IC-Partnerref.-Art';
            OptionMembers = " ","G/L Account",Item,,,"Charge (Item)","Cross Reference","Common Item No.";
            OptionCaptionML = ENU = ' ,G/L Account,Item,,,Charge (Item),Cross Reference,Common Item No.', DEU = ' ,Sachkonto,Artikel,,,Zu-/Abschlag (Artikel),Referenz,Gemeinsame Artikelnr.';
        }
        field(108; "IC Partner Reference"; Code[20])
        {
            CaptionML = ENU = 'IC Partner Reference', DEU = 'IC-Partnerreferenz';
        }
        field(109; "Prepayment %"; Decimal)
        {
            CaptionML = ENU = 'Prepayment %', DEU = 'Vorauszahlung %';
        }
        field(110; "Prepmt. Line Amount"; Decimal)
        {
            CaptionML = ENU = 'Prepmt. Line Amount', DEU = 'Vorauszahlungszeilenbetrag';
        }
        field(111; "Prepmt. Amt. Inv."; Decimal)
        {
            CaptionML = ENU = 'Prepmt. Amt. Inv.', DEU = 'Fakt. Vorauszahlungsbetrag';
        }
        field(112; "Prepmt. Amt. Incl. VAT"; Decimal)
        {
            CaptionML = ENU = 'Prepmt. Amt. Incl. VAT', DEU = 'Vorauszahlungsbetrag einschl. MwSt';
        }
        field(113; "Prepayment Amount"; Decimal)
        {
            CaptionML = ENU = 'Prepayment Amount', DEU = 'Vorauszahlungsbetrag';
        }
        field(114; "Prepmt. VAT Base Amt."; Decimal)
        {
            CaptionML = ENU = 'Prepmt. VAT Base Amt.', DEU = 'MwSt.-Bemessungsgrundlage Vorauszahlung';
        }
        field(115; "Prepayment VAT %"; Decimal)
        {
            CaptionML = ENU = 'Prepayment VAT %', DEU = 'MwSt % Vorauszahlung';
        }
        field(116; "Prepmt. VAT Calc. Type"; Option)
        {
            CaptionML = ENU = 'Prepmt. VAT Calc. Type', DEU = 'MwSt.-Berechnungsart Vorauszahlung';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
            OptionCaptionML = ENU = 'Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax', DEU = 'Normale MwSt.,Erwerbsbesteuerung,Nur MwSt.,Verkaufssteuer';
        }
        field(117; "Prepayment VAT Identifier"; Code[10])
        {
            CaptionML = ENU = 'Prepayment VAT Identifier', DEU = 'MwSt-Kennzeichen Vorauszahlung';
        }
        field(118; "Prepayment Tax Area Code"; Code[20])
        {
            CaptionML = ENU = 'Prepayment Tax Area Code', DEU = 'Steuergebietscode Vorauszahlung';
        }
        field(119; "Prepayment Tax Liable"; Boolean)
        {
            CaptionML = ENU = 'Prepayment Tax Liable', DEU = 'Vorauszahlung steuerpflichtig';
        }
        field(120; "Prepayment Tax Group Code"; Code[10])
        {
            CaptionML = ENU = 'Prepayment Tax Group Code', DEU = 'Steuergruppencode Vorauszahlung';
        }
        field(121; "Prepmt Amt to Deduct"; Decimal)
        {
            CaptionML = ENU = 'Prepmt Amt to Deduct', DEU = 'Abzuziehender Vorauszahlungsbetrag';
        }
        field(122; "Prepmt Amt Deducted"; Decimal)
        {
            CaptionML = ENU = 'Prepmt Amt Deducted', DEU = 'Abgezogener Vorauszahlungsbetrag';
        }
        field(123; "Prepayment Line"; Boolean)
        {
            CaptionML = ENU = 'Prepayment Line', DEU = 'Vorauszahlungszeile';
        }
        field(124; "Prepmt. Amount Inv. Incl. VAT"; Decimal)
        {
            CaptionML = ENU = 'Prepmt. Amount Inv. Incl. VAT', DEU = 'Fakt. Vorauszahlungsbetrag einschl. MwSt.';
        }
        field(129; "Prepmt. Amount Inv. (LCY)"; Decimal)
        {
            CaptionML = ENU = 'Prepmt. Amount Inv. (LCY)', DEU = 'Fakt. Vorauszahlungsbetrag (MW)';
        }
        field(130; "IC Partner Code"; Code[20])
        {
            CaptionML = ENU = 'IC Partner Code', DEU = 'IC-Partnercode';
        }
        field(135; "Prepayment VAT Difference"; Decimal)
        {
            CaptionML = ENU = 'Prepayment VAT Difference', DEU = 'MwSt.-Differenz Vorauszahlung';
        }
        field(136; "Prepmt VAT Diff. to Deduct"; Decimal)
        {
            CaptionML = ENU = 'Prepmt VAT Diff. to Deduct', DEU = 'Abzuziehende MwSt.-Differenz Vorauszahlung';
        }
        field(137; "Prepmt VAT Diff. Deducted"; Decimal)
        {
            CaptionML = ENU = 'Prepmt VAT Diff. Deducted', DEU = 'Abgezogene MwSt.-Differenz Vorauszahlung';
        }
        field(1001; "Job Task No."; Code[20])
        {
            CaptionML = ENU = 'Job Task No.', DEU = 'Projektaufgabennr.';
        }
        field(1002; "Job Contract Entry No."; Integer)
        {
            CaptionML = ENU = 'Job Contract Entry No.', DEU = 'Projektvertragspostennr.';
        }
        field(5402; "Variant Code"; Code[10])
        {
            CaptionML = ENU = 'Variant Code', DEU = 'Variantencode';
        }
        field(5403; "Bin Code"; Code[20])
        {
            CaptionML = ENU = 'Bin Code', DEU = 'Lagerplatzcode';
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            CaptionML = ENU = 'Qty. per Unit of Measure', DEU = 'Menge pro Einheit';
        }
        field(5405; "Planned"; Boolean)
        {
            CaptionML = ENU = 'Planned', DEU = 'Geplant';
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            CaptionML = ENU = 'Unit of Measure Code', DEU = 'Einheitencode';
        }
        field(5415; "Quantity (Base)"; Decimal)
        {
            CaptionML = ENU = 'Quantity (Base)', DEU = 'Menge (Basis)';
        }
        field(5416; "Outstanding Qty. (Base)"; Decimal)
        {
            CaptionML = ENU = 'Outstanding Qty. (Base)', DEU = 'Restauftragsmenge (Basis)';
        }
        field(5417; "Qty. to Invoice (Base)"; Decimal)
        {
            CaptionML = ENU = 'Qty. to Invoice (Base)', DEU = 'Zu fakturieren (Basis)';
        }
        field(5418; "Qty. to Ship (Base)"; Decimal)
        {
            CaptionML = ENU = 'Qty. to Ship (Base)', DEU = 'Zu liefern (Basis)';
        }
        field(5458; "Qty. Shipped Not Invd. (Base)"; Decimal)
        {
            CaptionML = ENU = 'Qty. Shipped Not Invd. (Base)', DEU = 'Lief. nicht fakt. Menge(Basis)';
        }
        field(5460; "Qty. Shipped (Base)"; Decimal)
        {
            CaptionML = ENU = 'Qty. Shipped (Base)', DEU = 'Menge geliefert (Basis)';
        }
        field(5461; "Qty. Invoiced (Base)"; Decimal)
        {
            CaptionML = ENU = 'Qty. Invoiced (Base)', DEU = 'Menge fakturiert (Basis)';
        }
        field(5600; "FA Posting Date"; Date)
        {
            CaptionML = ENU = 'FA Posting Date', DEU = 'Anlagedatum';
        }
        field(5602; "Depreciation Book Code"; Code[10])
        {
            CaptionML = ENU = 'Depreciation Book Code', DEU = 'AfA Buchcode';
        }
        field(5605; "Depr. until FA Posting Date"; Boolean)
        {
            CaptionML = ENU = 'Depr. until FA Posting Date', DEU = 'AfA bis Anlagedatum';
        }
        field(5612; "Duplicate in Depreciation Book"; Code[10])
        {
            CaptionML = ENU = 'Duplicate in Depreciation Book', DEU = 'In AfA-Buch kopieren';
        }
        field(5613; "Use Duplication List"; Boolean)
        {
            CaptionML = ENU = 'Use Duplication List', DEU = 'Kopiervorgang aktivieren';
        }
        field(5700; "Responsibility Center"; Code[10])
        {
            CaptionML = ENU = 'Responsibility Center', DEU = 'Zuständigkeitseinheitencode';
        }
        field(5701; "Out-of-Stock Substitution"; Boolean)
        {
            CaptionML = ENU = 'Out-of-Stock Substitution', DEU = 'Ersatz da nicht am Lager';
        }
        field(5703; "Originally Ordered No."; Code[20])
        {
            CaptionML = ENU = 'Originally Ordered No.', DEU = 'Urspr. Nr. (Auftrag)';
        }
        field(5704; "Originally Ordered Var. Code"; Code[10])
        {
            CaptionML = ENU = 'Originally Ordered Var. Code', DEU = 'Urspr. Variantencode (Auftrag)';
        }
        field(5705; "Cross-Reference No."; Code[20])
        {
            CaptionML = ENU = 'Cross-Reference No.', DEU = 'Referenznr.';
        }
        field(5706; "Unit of Measure (Cross Ref.)"; Code[10])
        {
            CaptionML = ENU = 'Unit of Measure (Cross Ref.)', DEU = 'Einheit (Referenz)';
        }
        field(5707; "Cross-Reference Type"; Option)
        {
            CaptionML = ENU = 'Cross-Reference Type', DEU = 'Referenzart';
            OptionMembers = " ",Customer,Vendor,"Bar Code";
            OptionCaptionML = ENU = ' ,Customer,Vendor,Bar Code', DEU = ' ,Debitor,Kreditor,Barcode';
        }
        field(5708; "Cross-Reference Type No."; Code[30])
        {
            CaptionML = ENU = 'Cross-Reference Type No.', DEU = 'Referenzartennr.';
        }
        field(5709; "Item Category Code"; Code[10])
        {
            CaptionML = ENU = 'Item Category Code', DEU = 'Artikelkategoriencode';
        }
        field(5710; "Nonstock"; Boolean)
        {
            CaptionML = ENU = 'Nonstock', DEU = 'Katalogartikel';
        }
        field(5711; "Purchasing Code"; Code[10])
        {
            CaptionML = ENU = 'Purchasing Code', DEU = 'Einkaufscode';
        }
        field(5712; "Product Group Code"; Code[10])
        {
            CaptionML = ENU = 'Product Group Code', DEU = 'Produktgruppencode';
        }
        field(5713; "Special Order"; Boolean)
        {
            CaptionML = ENU = 'Special Order', DEU = 'Spezialauftrag';
        }
        field(5714; "Special Order Purchase No."; Code[20])
        {
            CaptionML = ENU = 'Special Order Purchase No.', DEU = 'Spezialauftrag-Bestellnr.';
        }
        field(5715; "Special Order Purch. Line No."; Integer)
        {
            CaptionML = ENU = 'Special Order Purch. Line No.', DEU = 'Spezialauftrag-Eink.-Zeilennr.';
        }
        field(5752; "Completely Shipped"; Boolean)
        {
            CaptionML = ENU = 'Completely Shipped', DEU = 'Komplettlieferung (Ausgang)';
        }
        field(5790; "Requested Delivery Date"; Date)
        {
            CaptionML = ENU = 'Requested Delivery Date', DEU = 'Gewünschtes Lieferdatum';
        }
        field(5791; "Promised Delivery Date"; Date)
        {
            CaptionML = ENU = 'Promised Delivery Date', DEU = 'Zugesagtes Lieferdatum';
        }
        field(5792; "Shipping Time"; DateFormula)
        {
            CaptionML = ENU = 'Shipping Time', DEU = 'Transportzeit';
        }
        field(5793; "Outbound Whse. Handling Time"; DateFormula)
        {
            CaptionML = ENU = 'Outbound Whse. Handling Time', DEU = 'Ausgeh. Lagerdurchlaufzeit';
        }
        field(5794; "Planned Delivery Date"; Date)
        {
            CaptionML = ENU = 'Planned Delivery Date', DEU = 'Geplantes Lieferdatum';
        }
        field(5795; "Planned Shipment Date"; Date)
        {
            CaptionML = ENU = 'Planned Shipment Date', DEU = 'Geplantes Warenausgangsdatum';
        }
        field(5796; "Shipping Agent Code"; Code[10])
        {
            CaptionML = ENU = 'Shipping Agent Code', DEU = 'Zustellercode';
        }
        field(5797; "Shipping Agent Service Code"; Code[10])
        {
            CaptionML = ENU = 'Shipping Agent Service Code', DEU = 'Zustellertransportartencode';
        }
        field(5800; "Allow Item Charge Assignment"; Boolean)
        {
            CaptionML = ENU = 'Allow Item Charge Assignment', DEU = 'Artikel Zu-/Abschlagszuw. zul.';
        }
        field(5803; "Return Qty. to Receive"; Decimal)
        {
            CaptionML = ENU = 'Return Qty. to Receive', DEU = 'Menge akt. Rücksendung';
        }
        field(5804; "Return Qty. to Receive (Base)"; Decimal)
        {
            CaptionML = ENU = 'Return Qty. to Receive (Base)', DEU = 'Menge akt. Rücksendung (Basis)';
        }
        field(5805; "Return Qty. Rcd. Not Invd."; Decimal)
        {
            CaptionML = ENU = 'Return Qty. Rcd. Not Invd.', DEU = 'Lief. n. fakt. Rücks.-Menge';
        }
        field(5806; "Ret. Qty. Rcd. Not Invd.(Base)"; Decimal)
        {
            CaptionML = ENU = 'Ret. Qty. Rcd. Not Invd.(Base)', DEU = 'Lief.n.fak. Rücks.-Mge.(Basis)';
        }
        field(5807; "Return Rcd. Not Invd."; Decimal)
        {
            CaptionML = ENU = 'Return Rcd. Not Invd.', DEU = 'Lief. n. fakt. Rücks.-Betr.';
        }
        field(5808; "Return Rcd. Not Invd. (LCY)"; Decimal)
        {
            CaptionML = ENU = 'Return Rcd. Not Invd. (LCY)', DEU = 'Lief. n. fak. Rücks.-Betr.(MW)';
        }
        field(5809; "Return Qty. Received"; Decimal)
        {
            CaptionML = ENU = 'Return Qty. Received', DEU = 'Bereits gelief. Rücks.-Menge';
        }
        field(5810; "Return Qty. Received (Base)"; Decimal)
        {
            CaptionML = ENU = 'Return Qty. Received (Base)', DEU = 'Ber. gel. Rücks.-Menge (Basis)';
        }
        field(5811; "Appl.-from Item Entry"; Integer)
        {
            CaptionML = ENU = 'Appl.-from Item Entry', DEU = 'Ausgegl. von Artikelposten';
        }
        field(5909; "BOM Item No."; Code[20])
        {
            CaptionML = ENU = 'BOM Item No.', DEU = 'Fert.-Stückliste Artikelnr.';
        }
        field(6600; "Return Receipt No."; Code[20])
        {
            CaptionML = ENU = 'Return Receipt No.', DEU = 'Rücksendungsnr.';
        }
        field(6601; "Return Receipt Line No."; Integer)
        {
            CaptionML = ENU = 'Return Receipt Line No.', DEU = 'Rücksendungszeilennr.';
        }
        field(6608; "Return Reason Code"; Code[10])
        {
            CaptionML = ENU = 'Return Reason Code', DEU = 'Reklamationsgrundcode';
        }
        field(7001; "Allow Line Disc."; Boolean)
        {
            CaptionML = ENU = 'Allow Line Disc.', DEU = 'Zeilenrabatt zulassen';
        }
        field(7002; "Customer Disc. Group"; Code[10])
        {
            CaptionML = ENU = 'Customer Disc. Group', DEU = 'Debitorenrabattgruppe';
        }
        field(51005; "Indenture No."; Code[20])
        {
            CaptionML = ENU = 'Indenture No.', DEU = 'Ordnungsnummer';
        }
        field(51006; "Character Code"; Code[10])
        {
            CaptionML = ENU = 'Character Code', DEU = 'Charakterschlüssel';
        }
        field(51010; "Negative Adjmt. Inventory"; Option)
        {
            CaptionML = ENU = 'Negative Adjmt. Inventory', DEU = 'Abgang Lager';
            OptionMembers = J,N;
            OptionCaptionML = ENU = 'J,N', DEU = 'J,N';
        }
        field(51011; "WMS Status"; Option)
        {
            CaptionML = ENU = 'WMS Status', DEU = 'LVR Status';
            OptionMembers = " ",Requested,Picked;
            OptionCaptionML = ENU = ' ,Requested,Picked', DEU = ' ,Angefordet,Entnommen';
        }
        field(51012; "Quantity from WMS"; Decimal)
        {
            CaptionML = ENU = 'Quantity from WMS', DEU = 'Letzte Menge vom LVR';
        }
        field(51013; "WMS Position"; Integer)
        {
            CaptionML = ENU = 'WMS Position', DEU = 'LVS Position';
        }
        field(51014; "Quantity to WMS"; Decimal)
        {
            CaptionML = ENU = 'Quantity to WMS', DEU = 'Menge an LVR';
        }
        field(51015; "Row-ID"; Integer)
        {
            CaptionML = ENU = 'Row-ID', DEU = 'Row-ID';
        }
        field(51021; "Set Quantity"; Integer)
        {
            CaptionML = ENU = 'Set Quantity', DEU = 'Setanzahl';
        }
        field(52050; "Outstandings excl.VAT"; Decimal)
        {
            CaptionML = ENU = 'Outstandings excl.VAT', DEU = 'Restauftragsbetrag ohne MwSt';
        }
        field(52054; "without Material Posting"; Boolean)
        {
            CaptionML = ENU = 'without Material Posting', DEU = 'ohne Materialbuchung';
        }
        field(53001; "Main Item No."; Code[20])
        {
            CaptionML = ENU = 'Main Item No.', DEU = 'Hauptartikel';
        }
        field(53002; "Machine Type"; Code[30])
        {
            CaptionML = ENU = 'Machine Type', DEU = 'Maschinentyp';
        }
        field(53003; "Customer Ident. No."; Text[30])
        {
            CaptionML = ENU = 'Customer Ident. No.', DEU = 'Kundenidentnummer';
        }
        field(53004; "Assembly Order No."; Code[20])
        {
            CaptionML = ENU = 'Assembly Order No.', DEU = 'Montageauftragsnummer';
        }
        field(53005; "Salesperson Code"; Code[10])
        {
            CaptionML = ENU = 'Salesperson Code', DEU = 'Verkäufercode';
        }
        field(53006; "Creation Date"; Date)
        {
            CaptionML = ENU = 'Creation Date', DEU = 'Anlagedatum';
        }
        field(53007; "Foreign Description"; Text[50])
        {
            CaptionML = ENU = 'Foreign Description', DEU = 'Fremdsprachige Beschreibung';
        }
        field(53010; "Print Line"; Option)
        {
            CaptionML = ENU = 'Print Line', DEU = 'Zeile Drucken';
            OptionMembers = J,N;
            OptionCaptionML = ENU = 'J,N', DEU = 'J,N';
        }
        field(53011; "Line Main Item No."; Boolean)
        {
            CaptionML = ENU = 'Line Main Item No.', DEU = 'Position ist Hauptartikel';
        }
        field(53015; "Text Position"; Option)
        {
            CaptionML = ENU = 'Text Position', DEU = 'Text Position';
            OptionMembers = " ",Vortext,Nachtext;
            OptionCaptionML = ENU = ' ,Vortext,Nachtext', DEU = ' ,Vortext,Nachtext';
        }
        field(53016; "Position"; Text[10])
        {
            CaptionML = ENU = 'Position', DEU = 'Position';
        }
        field(53017; "Description 3"; Text[50])
        {
            CaptionML = ENU = 'Description 3', DEU = 'Beschreibung 3';
        }
        field(53021; "Number of Days"; Integer)
        {
            CaptionML = ENU = 'Number of Days', DEU = 'lfd. Tagesnummer';
        }
        field(53028; "Low Level Code"; Integer)
        {
            CaptionML = ENU = 'Low Level Code', DEU = 'Stücklistenebene';
        }
        field(53029; "Entry No."; Integer)
        {
            CaptionML = ENU = 'Entry No.', DEU = 'Lfd. Nr.';
        }
        field(53030; "Prod. Main Item"; Code[20])
        {
            CaptionML = ENU = 'Prod. Main Item', DEU = 'Fertigungsstückliste';
        }
        field(53042; "Main Location Code"; Code[10])
        {
            CaptionML = ENU = 'Main Location Code', DEU = 'Hauptlagerortcode';
        }
        field(53045; "Creation Type"; Option)
        {
            CaptionML = ENU = 'Creation Type', DEU = 'Anlage erfolgt';
            OptionMembers = Manuell,"Stückliste";
            OptionCaptionML = ENU = 'Manuell,Stückliste', DEU = 'Manuell,Stückliste';
        }
        field(53048; "Valid to"; Date)
        {
            CaptionML = ENU = 'Valid to', DEU = 'gültig bis';
        }
        field(53057; "Priority"; Option)
        {
            CaptionML = ENU = 'Priority', DEU = 'Priorität';
            OptionMembers = "0","1","2","3";
            OptionCaptionML = ENU = '0,1,2,3', DEU = 'normal,L/C,Messe,grüne Mappe';
        }
        field(53060; "Networking List No."; Integer)
        {
            CaptionML = ENU = 'Networking List No.', DEU = 'Vernetzungslistennr';
        }
        field(53062; "Order Type Code"; Option)
        {
            CaptionML = ENU = 'Order Type Code', DEU = 'Auftragsart';
            OptionMembers = Sofortauftrag,Bauteilfertigung,Ersatzteile;
            OptionCaptionML = ENU = 'Sofortauftrag,Bauteilfertigung,Ersatzteile', DEU = 'Sofortauftrag,Bauteilfertigung,Ersatzteile';
        }
        field(53064; "LVS Order"; Code[10])
        {
            CaptionML = ENU = 'LVS Order', DEU = 'LVS Auftragsnr';
        }
        field(53073; "Forecast Status"; Option)
        {
            CaptionML = ENU = 'Forecast Status', DEU = 'Zuordnung zum Absatzplan';
            OptionMembers = KPP,AKZ,ATZ,AIA,ANA,MFA,ABG;
            OptionCaptionML = ENU = 'KPP,AKZ,ATZ,AIA,ANA,MFA,ABG', DEU = 'Keine APL Prüfung,Position komplett APL zugeordnet,Position teilweise APL zugeordnet,Artikel in Fremd-APL vorhanden,Artikel nicht im APL gefunden,manuelle Freigabe (Mehrbedarf),Pos. Abgelaufender Abstazplan zugeordnet';
        }
        field(53093; "Fixed Allocation Qty."; Decimal)
        {
            CaptionML = ENU = 'Fixed Allocation Qty.', DEU = 'Offene Auftragsmenge LVR';
        }
        field(53094; "Demand Sales Order Qty."; Decimal)
        {
            CaptionML = ENU = 'Demand Sales Order Qty.', DEU = 'Nicht zugeordnete Auftragsmenge';
        }
        field(53100; "Discount 1"; Decimal)
        {
            CaptionML = ENU = 'Discount 1', DEU = 'Rabatt 1 in %';
        }
        field(53101; "Discount 2"; Decimal)
        {
            CaptionML = ENU = 'Discount 2', DEU = 'Rabatt 2 in %';
        }
        field(53119; "CodeVariabel"; Boolean)
        {
            CaptionML = ENU = 'CodeVariabel', DEU = 'CodeVariabel';
        }
        field(53120; "Service"; Boolean)
        {
            CaptionML = ENU = 'Service', DEU = 'Ersatzteilauftrag';
        }
        field(53121; "Warranty"; Boolean)
        {
            CaptionML = ENU = 'Warranty', DEU = 'Garantie';
        }
        field(53122; "Warranty Disc. %"; Decimal)
        {
            CaptionML = ENU = 'Warranty Disc. %', DEU = 'Garantierabatt %';
        }
        field(53123; "Warranty Amount"; Decimal)
        {
            CaptionML = ENU = 'Warranty Amount', DEU = 'Garantiebetrag';
        }
        field(53130; "Explode BOM"; Boolean)
        {
            CaptionML = ENU = 'Explode BOM', DEU = 'Einzelteile überspielen';
        }
        field(53140; "Quantity per"; Decimal)
        {
            CaptionML = ENU = 'Quantity per', DEU = 'Quantity per';
        }
        field(53145; "Requested Items"; Integer)
        {
            CaptionML = ENU = 'Requested Items', DEU = 'Anzahl überspielte Artikel';
        }
        field(53530; "Promised Prod. Ending date"; Date)
        {
            CaptionML = ENU = 'Promised Prod. Ending date', DEU = 'Bestätigtes Produktionsendedatum';
        }
        field(53535; "BOM Calc. Date"; Date)
        {
            CaptionML = ENU = 'BOM Calc. Date', DEU = 'Datum Stücklistenberechnung';
        }
        field(53900; "Service Cost No."; Code[10])
        {
            CaptionML = ENU = 'Service Cost No.', DEU = 'Zusatzkostentabelle';
        }
        field(53905; "Entnahmemenge"; Decimal)
        {
            CaptionML = ENU = 'Entnahmemenge', DEU = 'Entnahmemenge';
        }
        field(53965; "BOM Item Type"; Option)
        {
            CaptionML = ENU = 'BOM Item Type', DEU = 'Klassifizierung';
            OptionMembers = " ",G,V,E;
            OptionCaptionML = ENU = ' ,G,V,E', DEU = ' ,G,V,E';
        }
        field(53970; "Abgelaufener Absatzplan"; Code[20])
        {
            CaptionML = ENU = 'Abgelaufener Absatzplan', DEU = 'Manueller Absatzplan';
        }
        field(53971; "Abgelaufene Zugeordnete Menge"; Decimal)
        {
            CaptionML = ENU = 'Abgelaufene Zugeordnete Menge', DEU = 'Abgelaufene Zugeordnete Menge';
        }
        field(53975; "LVR Qty. Mod. Order"; Decimal)
        {
            CaptionML = ENU = 'LVR Qty. Mod. Order', DEU = 'LVR Menge Umbauauftrag';
        }
        field(53980; "Modified from Mod. Order"; Boolean)
        {
            CaptionML = ENU = 'Modified from Mod. Order', DEU = 'Update durch Umbauauftrag';
        }
        field(53999; "Status"; Option)
        {
            CaptionML = ENU = 'Status', DEU = 'Status';
            OptionMembers = Open,Released,"Pending Approval","Pending Prepayment";
            OptionCaptionML = ENU = 'Open,Released,Pending Approval,Pending Prepayment', DEU = 'Offen,Freigegeben,Genehmigung ausstehend,Vorauszahlung ausstehend';
        }
        field(54540; "BOM Calc Time"; Time)
        {
            CaptionML = ENU = 'BOM Calc Time', DEU = 'Uhrzeit Stücklistenberechnung';
        }
        field(54545; "BOM Calc User"; Code[20])
        {
            CaptionML = ENU = 'BOM Calc User', DEU = 'Stücklistenberechnung durch';
        }
        field(55222; "Assembly Load relevant"; Boolean)
        {
            CaptionML = ENU = 'Assembly Load relevant', DEU = 'Montage Auslastung relevant';
        }
        field(55224; "No LVR-Request"; Boolean)
        {
            CaptionML = ENU = 'No LVR-Request', DEU = 'Keine LVR-Anforderung';
        }
        field(55231; "Location Consignment"; Code[10])
        {
            CaptionML = ENU = 'Location Consignment', DEU = 'Lagerort Konsignation';
        }
        field(55240; "SICY SoFo Auftragsnummer"; Code[20])
        {
            CaptionML = ENU = 'SICY SoFo Auftragsnummer', DEU = 'SICY SoFo Auftragsnummer';
        }
        field(55241; "SICY SoFo Auftragsmenge"; Decimal)
        {
            CaptionML = ENU = 'SICY SoFo Auftragsmenge', DEU = 'SICY SoFo Auftragsmenge';
        }
        field(55250; "JahrKW"; Code[10])
        {
            CaptionML = ENU = 'JahrKW', DEU = 'JahrKW';
        }
        field(55251; "Linie"; Code[10])
        {
            CaptionML = ENU = 'Linie', DEU = 'Linie';
        }
        field(55252; "Durchlaufzeit"; Decimal)
        {
            CaptionML = ENU = 'Durchlaufzeit', DEU = 'Durchlaufzeit';
        }
        field(55253; "Durchlaufzeit Zeile"; Decimal)
        {
            CaptionML = ENU = 'Durchlaufzeit Zeile', DEU = 'Durchlaufzeit Zeile';
        }
        field(55260; "Routing Header"; Code[20])
        {
            CaptionML = ENU = 'Routing Header', DEU = 'Routing Header';
        }
        field(55265; "LVR Paket Nr."; Code[20])
        {
            CaptionML = ENU = 'LVR Paket Nr.', DEU = 'LVR Paket Nr.';
        }
        field(55700; "Etagis Delay"; Integer)
        {
            CaptionML = ENU = 'Etagis Delay', DEU = 'Etagis Verspätung';
        }
        field(55701; "Etagis Due Date"; Date)
        {
            CaptionML = ENU = 'Etagis Due Date', DEU = 'Etagis Due Date';
        }
        field(55702; "Etagis Plan Date"; Date)
        {
            CaptionML = ENU = 'Etagis Plan Date', DEU = 'Plandatum';
        }
        field(59999; "Übernahme"; Boolean)
        {
            CaptionML = ENU = 'Übernahme', DEU = 'Übernahme';
        }
        field(3010501; "Customer Line Reference"; Integer)
        {
            CaptionML = ENU = 'Customer Line Reference', DEU = 'Debitorzeilenreferenz';
        }
        field(51000; "DMT Imported"; Boolean) { CaptionML = ENU = 'DMT Imported', DEU = 'Importiert'; }
        field(51001; "DMT RecId (Imported)"; RecordId) { CaptionML = ENU = 'DMT Record ID (Imported)', DEU = 'Datensatz-ID (Importiert)'; }
    }
    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}
