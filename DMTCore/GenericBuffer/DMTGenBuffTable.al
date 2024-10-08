table 50128 DMTGenBuffTable
{
    Access = Internal;
    fields
    {
        field(1; "Entry No."; Integer) { }
        field(10; "Import from Filename"; Text[250]) { Caption = 'Import from Filename', Comment = 'de-DE=Import Dateiname'; }
        field(11; "Imp.Conf.Header ID"; Integer)
        {
            Caption = 'Imp.Conf.Header ID', Comment = 'de-DE=Import Konfig. Kopf ID';
            TableRelation = DMTImportConfigHeader;
        }
        field(13; IsCaptionLine; Boolean) { }
        field(14; "Column Count"; Integer) { }
        field(20; Imported; Boolean) { Caption = 'Imported', comment = 'de-DE=Importiert'; }
        field(21; "RecId (Imported)"; RecordId) { Caption = 'Record ID (Imported)', comment = 'de-DE=Datensatz-ID (Importiert)'; }
        field(22; "SystemModifiedAt (Imported)"; DateTime) { Caption = 'System Modified At (Imported Record)', comment = 'de-DE=Letzte Änderung am (Importierter Datensatz)'; }
        field(30; "No. of Blob Contents"; Integer)
        {
            Caption = 'BLOB Contents', comment = 'de-DE=Blob Inhalte';
            BlankZero = true;
            FieldClass = FlowField;
            CalcFormula = count(DMTBlobStorage where("Gen. Buffer Table Entry No." = field("Entry No."), "Imp.Conf.Header ID" = field("Imp.Conf.Header ID")));
            Editable = false;
        }
        field(1001; Fld001; Text[250]) { CaptionClass = GetFieldCaption(1001); Caption = 'Fld001', Locked = true; }
        field(1002; Fld002; Text[250]) { CaptionClass = GetFieldCaption(1002); Caption = 'Fld002', Locked = true; }
        field(1003; Fld003; Text[250]) { CaptionClass = GetFieldCaption(1003); Caption = 'Fld003', Locked = true; }
        field(1004; Fld004; Text[250]) { CaptionClass = GetFieldCaption(1004); Caption = 'Fld004', Locked = true; }
        field(1005; Fld005; Text[250]) { CaptionClass = GetFieldCaption(1005); Caption = 'Fld005', Locked = true; }
        field(1006; Fld006; Text[250]) { CaptionClass = GetFieldCaption(1006); Caption = 'Fld006', Locked = true; }
        field(1007; Fld007; Text[250]) { CaptionClass = GetFieldCaption(1007); Caption = 'Fld007', Locked = true; }
        field(1008; Fld008; Text[250]) { CaptionClass = GetFieldCaption(1008); Caption = 'Fld008', Locked = true; }
        field(1009; Fld009; Text[250]) { CaptionClass = GetFieldCaption(1009); Caption = 'Fld009', Locked = true; }
        field(1010; Fld010; Text[250]) { CaptionClass = GetFieldCaption(1010); Caption = 'Fld010', Locked = true; }
        field(1011; Fld011; Text[250]) { CaptionClass = GetFieldCaption(1011); Caption = 'Fld011', Locked = true; }
        field(1012; Fld012; Text[250]) { CaptionClass = GetFieldCaption(1012); Caption = 'Fld012', Locked = true; }
        field(1013; Fld013; Text[250]) { CaptionClass = GetFieldCaption(1013); Caption = 'Fld013', Locked = true; }
        field(1014; Fld014; Text[250]) { CaptionClass = GetFieldCaption(1014); Caption = 'Fld014', Locked = true; }
        field(1015; Fld015; Text[250]) { CaptionClass = GetFieldCaption(1015); Caption = 'Fld015', Locked = true; }
        field(1016; Fld016; Text[250]) { CaptionClass = GetFieldCaption(1016); Caption = 'Fld016', Locked = true; }
        field(1017; Fld017; Text[250]) { CaptionClass = GetFieldCaption(1017); Caption = 'Fld017', Locked = true; }
        field(1018; Fld018; Text[250]) { CaptionClass = GetFieldCaption(1018); Caption = 'Fld018', Locked = true; }
        field(1019; Fld019; Text[250]) { CaptionClass = GetFieldCaption(1019); Caption = 'Fld019', Locked = true; }
        field(1020; Fld020; Text[250]) { CaptionClass = GetFieldCaption(1020); Caption = 'Fld020', Locked = true; }
        field(1021; Fld021; Text[250]) { CaptionClass = GetFieldCaption(1021); Caption = 'Fld021', Locked = true; }
        field(1022; Fld022; Text[250]) { CaptionClass = GetFieldCaption(1022); Caption = 'Fld022', Locked = true; }
        field(1023; Fld023; Text[250]) { CaptionClass = GetFieldCaption(1023); Caption = 'Fld023', Locked = true; }
        field(1024; Fld024; Text[250]) { CaptionClass = GetFieldCaption(1024); Caption = 'Fld024', Locked = true; }
        field(1025; Fld025; Text[250]) { CaptionClass = GetFieldCaption(1025); Caption = 'Fld025', Locked = true; }
        field(1026; Fld026; Text[250]) { CaptionClass = GetFieldCaption(1026); Caption = 'Fld026', Locked = true; }
        field(1027; Fld027; Text[250]) { CaptionClass = GetFieldCaption(1027); Caption = 'Fld027', Locked = true; }
        field(1028; Fld028; Text[250]) { CaptionClass = GetFieldCaption(1028); Caption = 'Fld028', Locked = true; }
        field(1029; Fld029; Text[250]) { CaptionClass = GetFieldCaption(1029); Caption = 'Fld029', Locked = true; }
        field(1030; Fld030; Text[250]) { CaptionClass = GetFieldCaption(1030); Caption = 'Fld030', Locked = true; }
        field(1031; Fld031; Text[250]) { CaptionClass = GetFieldCaption(1031); Caption = 'Fld031', Locked = true; }
        field(1032; Fld032; Text[250]) { CaptionClass = GetFieldCaption(1032); Caption = 'Fld032', Locked = true; }
        field(1033; Fld033; Text[250]) { CaptionClass = GetFieldCaption(1033); Caption = 'Fld033', Locked = true; }
        field(1034; Fld034; Text[250]) { CaptionClass = GetFieldCaption(1034); Caption = 'Fld034', Locked = true; }
        field(1035; Fld035; Text[250]) { CaptionClass = GetFieldCaption(1035); Caption = 'Fld035', Locked = true; }
        field(1036; Fld036; Text[250]) { CaptionClass = GetFieldCaption(1036); Caption = 'Fld036', Locked = true; }
        field(1037; Fld037; Text[250]) { CaptionClass = GetFieldCaption(1037); Caption = 'Fld037', Locked = true; }
        field(1038; Fld038; Text[250]) { CaptionClass = GetFieldCaption(1038); Caption = 'Fld038', Locked = true; }
        field(1039; Fld039; Text[250]) { CaptionClass = GetFieldCaption(1039); Caption = 'Fld039', Locked = true; }
        field(1040; Fld040; Text[250]) { CaptionClass = GetFieldCaption(1040); Caption = 'Fld040', Locked = true; }
        field(1041; Fld041; Text[250]) { CaptionClass = GetFieldCaption(1041); Caption = 'Fld041', Locked = true; }
        field(1042; Fld042; Text[250]) { CaptionClass = GetFieldCaption(1042); Caption = 'Fld042', Locked = true; }
        field(1043; Fld043; Text[250]) { CaptionClass = GetFieldCaption(1043); Caption = 'Fld043', Locked = true; }
        field(1044; Fld044; Text[250]) { CaptionClass = GetFieldCaption(1044); Caption = 'Fld044', Locked = true; }
        field(1045; Fld045; Text[250]) { CaptionClass = GetFieldCaption(1045); Caption = 'Fld045', Locked = true; }
        field(1046; Fld046; Text[250]) { CaptionClass = GetFieldCaption(1046); Caption = 'Fld046', Locked = true; }
        field(1047; Fld047; Text[250]) { CaptionClass = GetFieldCaption(1047); Caption = 'Fld047', Locked = true; }
        field(1048; Fld048; Text[250]) { CaptionClass = GetFieldCaption(1048); Caption = 'Fld048', Locked = true; }
        field(1049; Fld049; Text[250]) { CaptionClass = GetFieldCaption(1049); Caption = 'Fld049', Locked = true; }
        field(1050; Fld050; Text[250]) { CaptionClass = GetFieldCaption(1050); Caption = 'Fld050', Locked = true; }
        field(1051; Fld051; Text[250]) { CaptionClass = GetFieldCaption(1051); Caption = 'Fld051', Locked = true; }
        field(1052; Fld052; Text[250]) { CaptionClass = GetFieldCaption(1052); Caption = 'Fld052', Locked = true; }
        field(1053; Fld053; Text[250]) { CaptionClass = GetFieldCaption(1053); Caption = 'Fld053', Locked = true; }
        field(1054; Fld054; Text[250]) { CaptionClass = GetFieldCaption(1054); Caption = 'Fld054', Locked = true; }
        field(1055; Fld055; Text[250]) { CaptionClass = GetFieldCaption(1055); Caption = 'Fld055', Locked = true; }
        field(1056; Fld056; Text[250]) { CaptionClass = GetFieldCaption(1056); Caption = 'Fld056', Locked = true; }
        field(1057; Fld057; Text[250]) { CaptionClass = GetFieldCaption(1057); Caption = 'Fld057', Locked = true; }
        field(1058; Fld058; Text[250]) { CaptionClass = GetFieldCaption(1058); Caption = 'Fld058', Locked = true; }
        field(1059; Fld059; Text[250]) { CaptionClass = GetFieldCaption(1059); Caption = 'Fld059', Locked = true; }
        field(1060; Fld060; Text[250]) { CaptionClass = GetFieldCaption(1060); Caption = 'Fld060', Locked = true; }
        field(1061; Fld061; Text[250]) { CaptionClass = GetFieldCaption(1061); Caption = 'Fld061', Locked = true; }
        field(1062; Fld062; Text[250]) { CaptionClass = GetFieldCaption(1062); Caption = 'Fld062', Locked = true; }
        field(1063; Fld063; Text[250]) { CaptionClass = GetFieldCaption(1063); Caption = 'Fld063', Locked = true; }
        field(1064; Fld064; Text[250]) { CaptionClass = GetFieldCaption(1064); Caption = 'Fld064', Locked = true; }
        field(1065; Fld065; Text[250]) { CaptionClass = GetFieldCaption(1065); Caption = 'Fld065', Locked = true; }
        field(1066; Fld066; Text[250]) { CaptionClass = GetFieldCaption(1066); Caption = 'Fld066', Locked = true; }
        field(1067; Fld067; Text[250]) { CaptionClass = GetFieldCaption(1067); Caption = 'Fld067', Locked = true; }
        field(1068; Fld068; Text[250]) { CaptionClass = GetFieldCaption(1068); Caption = 'Fld068', Locked = true; }
        field(1069; Fld069; Text[250]) { CaptionClass = GetFieldCaption(1069); Caption = 'Fld069', Locked = true; }
        field(1070; Fld070; Text[250]) { CaptionClass = GetFieldCaption(1070); Caption = 'Fld070', Locked = true; }
        field(1071; Fld071; Text[250]) { CaptionClass = GetFieldCaption(1071); Caption = 'Fld071', Locked = true; }
        field(1072; Fld072; Text[250]) { CaptionClass = GetFieldCaption(1072); Caption = 'Fld072', Locked = true; }
        field(1073; Fld073; Text[250]) { CaptionClass = GetFieldCaption(1073); Caption = 'Fld073', Locked = true; }
        field(1074; Fld074; Text[250]) { CaptionClass = GetFieldCaption(1074); Caption = 'Fld074', Locked = true; }
        field(1075; Fld075; Text[250]) { CaptionClass = GetFieldCaption(1075); Caption = 'Fld075', Locked = true; }
        field(1076; Fld076; Text[250]) { CaptionClass = GetFieldCaption(1076); Caption = 'Fld076', Locked = true; }
        field(1077; Fld077; Text[250]) { CaptionClass = GetFieldCaption(1077); Caption = 'Fld077', Locked = true; }
        field(1078; Fld078; Text[250]) { CaptionClass = GetFieldCaption(1078); Caption = 'Fld078', Locked = true; }
        field(1079; Fld079; Text[250]) { CaptionClass = GetFieldCaption(1079); Caption = 'Fld079', Locked = true; }
        field(1080; Fld080; Text[250]) { CaptionClass = GetFieldCaption(1080); Caption = 'Fld080', Locked = true; }
        field(1081; Fld081; Text[250]) { CaptionClass = GetFieldCaption(1081); Caption = 'Fld081', Locked = true; }
        field(1082; Fld082; Text[250]) { CaptionClass = GetFieldCaption(1082); Caption = 'Fld082', Locked = true; }
        field(1083; Fld083; Text[250]) { CaptionClass = GetFieldCaption(1083); Caption = 'Fld083', Locked = true; }
        field(1084; Fld084; Text[250]) { CaptionClass = GetFieldCaption(1084); Caption = 'Fld084', Locked = true; }
        field(1085; Fld085; Text[250]) { CaptionClass = GetFieldCaption(1085); Caption = 'Fld085', Locked = true; }
        field(1086; Fld086; Text[250]) { CaptionClass = GetFieldCaption(1086); Caption = 'Fld086', Locked = true; }
        field(1087; Fld087; Text[250]) { CaptionClass = GetFieldCaption(1087); Caption = 'Fld087', Locked = true; }
        field(1088; Fld088; Text[250]) { CaptionClass = GetFieldCaption(1088); Caption = 'Fld088', Locked = true; }
        field(1089; Fld089; Text[250]) { CaptionClass = GetFieldCaption(1089); Caption = 'Fld089', Locked = true; }
        field(1090; Fld090; Text[250]) { CaptionClass = GetFieldCaption(1090); Caption = 'Fld090', Locked = true; }
        field(1091; Fld091; Text[250]) { CaptionClass = GetFieldCaption(1091); Caption = 'Fld091', Locked = true; }
        field(1092; Fld092; Text[250]) { CaptionClass = GetFieldCaption(1092); Caption = 'Fld092', Locked = true; }
        field(1093; Fld093; Text[250]) { CaptionClass = GetFieldCaption(1093); Caption = 'Fld093', Locked = true; }
        field(1094; Fld094; Text[250]) { CaptionClass = GetFieldCaption(1094); Caption = 'Fld094', Locked = true; }
        field(1095; Fld095; Text[250]) { CaptionClass = GetFieldCaption(1095); Caption = 'Fld095', Locked = true; }
        field(1096; Fld096; Text[250]) { CaptionClass = GetFieldCaption(1096); Caption = 'Fld096', Locked = true; }
        field(1097; Fld097; Text[250]) { CaptionClass = GetFieldCaption(1097); Caption = 'Fld097', Locked = true; }
        field(1098; Fld098; Text[250]) { CaptionClass = GetFieldCaption(1098); Caption = 'Fld098', Locked = true; }
        field(1099; Fld099; Text[250]) { CaptionClass = GetFieldCaption(1099); Caption = 'Fld099', Locked = true; }
        field(1100; Fld100; Text[250]) { CaptionClass = GetFieldCaption(1100); Caption = 'Fld100', Locked = true; }
        field(1101; Fld101; Text[250]) { CaptionClass = GetFieldCaption(1101); Caption = 'Fld101', Locked = true; }
        field(1102; Fld102; Text[250]) { CaptionClass = GetFieldCaption(1102); Caption = 'Fld102', Locked = true; }
        field(1103; Fld103; Text[250]) { CaptionClass = GetFieldCaption(1103); Caption = 'Fld103', Locked = true; }
        field(1104; Fld104; Text[250]) { CaptionClass = GetFieldCaption(1104); Caption = 'Fld104', Locked = true; }
        field(1105; Fld105; Text[250]) { CaptionClass = GetFieldCaption(1105); Caption = 'Fld105', Locked = true; }
        field(1106; Fld106; Text[250]) { CaptionClass = GetFieldCaption(1106); Caption = 'Fld106', Locked = true; }
        field(1107; Fld107; Text[250]) { CaptionClass = GetFieldCaption(1107); Caption = 'Fld107', Locked = true; }
        field(1108; Fld108; Text[250]) { CaptionClass = GetFieldCaption(1108); Caption = 'Fld108', Locked = true; }
        field(1109; Fld109; Text[250]) { CaptionClass = GetFieldCaption(1109); Caption = 'Fld109', Locked = true; }
        field(1110; Fld110; Text[250]) { CaptionClass = GetFieldCaption(1100); Caption = 'Fld110', Locked = true; }
        field(1111; Fld111; Text[250]) { CaptionClass = GetFieldCaption(1111); Caption = 'Fld111', Locked = true; }
        field(1112; Fld112; Text[250]) { CaptionClass = GetFieldCaption(1112); Caption = 'Fld112', Locked = true; }
        field(1113; Fld113; Text[250]) { CaptionClass = GetFieldCaption(1113); Caption = 'Fld113', Locked = true; }
        field(1114; Fld114; Text[250]) { CaptionClass = GetFieldCaption(1114); Caption = 'Fld114', Locked = true; }
        field(1115; Fld115; Text[250]) { CaptionClass = GetFieldCaption(1115); Caption = 'Fld115', Locked = true; }
        field(1116; Fld116; Text[250]) { CaptionClass = GetFieldCaption(1116); Caption = 'Fld116', Locked = true; }
        field(1117; Fld117; Text[250]) { CaptionClass = GetFieldCaption(1117); Caption = 'Fld117', Locked = true; }
        field(1118; Fld118; Text[250]) { CaptionClass = GetFieldCaption(1118); Caption = 'Fld118', Locked = true; }
        field(1119; Fld119; Text[250]) { CaptionClass = GetFieldCaption(1119); Caption = 'Fld119', Locked = true; }
        field(1120; Fld120; Text[250]) { CaptionClass = GetFieldCaption(1120); Caption = 'Fld120', Locked = true; }
        field(1121; Fld121; Text[250]) { CaptionClass = GetFieldCaption(1121); Caption = 'Fld121', Locked = true; }
        field(1122; Fld122; Text[250]) { CaptionClass = GetFieldCaption(1122); Caption = 'Fld122', Locked = true; }
        field(1123; Fld123; Text[250]) { CaptionClass = GetFieldCaption(1123); Caption = 'Fld123', Locked = true; }
        field(1124; Fld124; Text[250]) { CaptionClass = GetFieldCaption(1124); Caption = 'Fld124', Locked = true; }
        field(1125; Fld125; Text[250]) { CaptionClass = GetFieldCaption(1125); Caption = 'Fld125', Locked = true; }
        field(1126; Fld126; Text[250]) { CaptionClass = GetFieldCaption(1126); Caption = 'Fld126', Locked = true; }
        field(1127; Fld127; Text[250]) { CaptionClass = GetFieldCaption(1127); Caption = 'Fld127', Locked = true; }
        field(1128; Fld128; Text[250]) { CaptionClass = GetFieldCaption(1128); Caption = 'Fld128', Locked = true; }
        field(1129; Fld129; Text[250]) { CaptionClass = GetFieldCaption(1129); Caption = 'Fld129', Locked = true; }
        field(1130; Fld130; Text[250]) { CaptionClass = GetFieldCaption(1130); Caption = 'Fld130', Locked = true; }
        field(1131; Fld131; Text[250]) { CaptionClass = GetFieldCaption(1131); Caption = 'Fld131', Locked = true; }
        field(1132; Fld132; Text[250]) { CaptionClass = GetFieldCaption(1132); Caption = 'Fld132', Locked = true; }
        field(1133; Fld133; Text[250]) { CaptionClass = GetFieldCaption(1133); Caption = 'Fld133', Locked = true; }
        field(1134; Fld134; Text[250]) { CaptionClass = GetFieldCaption(1134); Caption = 'Fld134', Locked = true; }
        field(1135; Fld135; Text[250]) { CaptionClass = GetFieldCaption(1135); Caption = 'Fld135', Locked = true; }
        field(1136; Fld136; Text[250]) { CaptionClass = GetFieldCaption(1136); Caption = 'Fld136', Locked = true; }
        field(1137; Fld137; Text[250]) { CaptionClass = GetFieldCaption(1137); Caption = 'Fld137', Locked = true; }
        field(1138; Fld138; Text[250]) { CaptionClass = GetFieldCaption(1138); Caption = 'Fld138', Locked = true; }
        field(1139; Fld139; Text[250]) { CaptionClass = GetFieldCaption(1139); Caption = 'Fld139', Locked = true; }
        field(1140; Fld140; Text[250]) { CaptionClass = GetFieldCaption(1140); Caption = 'Fld140', Locked = true; }
        field(1141; Fld141; Text[250]) { CaptionClass = GetFieldCaption(1141); Caption = 'Fld141', Locked = true; }
        field(1142; Fld142; Text[250]) { CaptionClass = GetFieldCaption(1142); Caption = 'Fld142', Locked = true; }
        field(1143; Fld143; Text[250]) { CaptionClass = GetFieldCaption(1143); Caption = 'Fld143', Locked = true; }
        field(1144; Fld144; Text[250]) { CaptionClass = GetFieldCaption(1144); Caption = 'Fld144', Locked = true; }
        field(1145; Fld145; Text[250]) { CaptionClass = GetFieldCaption(1145); Caption = 'Fld145', Locked = true; }
        field(1146; Fld146; Text[250]) { CaptionClass = GetFieldCaption(1146); Caption = 'Fld146', Locked = true; }
        field(1147; Fld147; Text[250]) { CaptionClass = GetFieldCaption(1147); Caption = 'Fld147', Locked = true; }
        field(1148; Fld148; Text[250]) { CaptionClass = GetFieldCaption(1148); Caption = 'Fld148', Locked = true; }
        field(1149; Fld149; Text[250]) { CaptionClass = GetFieldCaption(1149); Caption = 'Fld149', Locked = true; }
        field(1150; Fld150; Text[250]) { CaptionClass = GetFieldCaption(1150); Caption = 'Fld150', Locked = true; }
        field(1151; Fld151; Text[250]) { CaptionClass = GetFieldCaption(1151); Caption = 'Fld151', Locked = true; }
        field(1152; Fld152; Text[250]) { CaptionClass = GetFieldCaption(1152); Caption = 'Fld152', Locked = true; }
        field(1153; Fld153; Text[250]) { CaptionClass = GetFieldCaption(1153); Caption = 'Fld153', Locked = true; }
        field(1154; Fld154; Text[250]) { CaptionClass = GetFieldCaption(1154); Caption = 'Fld154', Locked = true; }
        field(1155; Fld155; Text[250]) { CaptionClass = GetFieldCaption(1155); Caption = 'Fld155', Locked = true; }
        field(1156; Fld156; Text[250]) { CaptionClass = GetFieldCaption(1156); Caption = 'Fld156', Locked = true; }
        field(1157; Fld157; Text[250]) { CaptionClass = GetFieldCaption(1157); Caption = 'Fld157', Locked = true; }
        field(1158; Fld158; Text[250]) { CaptionClass = GetFieldCaption(1158); Caption = 'Fld158', Locked = true; }
        field(1159; Fld159; Text[250]) { CaptionClass = GetFieldCaption(1159); Caption = 'Fld159', Locked = true; }
        field(1160; Fld160; Text[250]) { CaptionClass = GetFieldCaption(1160); Caption = 'Fld160', Locked = true; }
        field(1161; Fld161; Text[250]) { CaptionClass = GetFieldCaption(1161); Caption = 'Fld161', Locked = true; }
        field(1162; Fld162; Text[250]) { CaptionClass = GetFieldCaption(1162); Caption = 'Fld162', Locked = true; }
        field(1163; Fld163; Text[250]) { CaptionClass = GetFieldCaption(1163); Caption = 'Fld163', Locked = true; }
        field(1164; Fld164; Text[250]) { CaptionClass = GetFieldCaption(1164); Caption = 'Fld164', Locked = true; }
        field(1165; Fld165; Text[250]) { CaptionClass = GetFieldCaption(1165); Caption = 'Fld165', Locked = true; }
        field(1166; Fld166; Text[250]) { CaptionClass = GetFieldCaption(1166); Caption = 'Fld166', Locked = true; }
        field(1167; Fld167; Text[250]) { CaptionClass = GetFieldCaption(1167); Caption = 'Fld167', Locked = true; }
        field(1168; Fld168; Text[250]) { CaptionClass = GetFieldCaption(1168); Caption = 'Fld168', Locked = true; }
        field(1169; Fld169; Text[250]) { CaptionClass = GetFieldCaption(1169); Caption = 'Fld169', Locked = true; }
        field(1170; Fld170; Text[250]) { CaptionClass = GetFieldCaption(1170); Caption = 'Fld170', Locked = true; }
        field(1171; Fld171; Text[250]) { CaptionClass = GetFieldCaption(1171); Caption = 'Fld171', Locked = true; }
        field(1172; Fld172; Text[250]) { CaptionClass = GetFieldCaption(1172); Caption = 'Fld172', Locked = true; }
        field(1173; Fld173; Text[250]) { CaptionClass = GetFieldCaption(1173); Caption = 'Fld173', Locked = true; }
        field(1174; Fld174; Text[250]) { CaptionClass = GetFieldCaption(1174); Caption = 'Fld174', Locked = true; }
        field(1175; Fld175; Text[250]) { CaptionClass = GetFieldCaption(1175); Caption = 'Fld175', Locked = true; }
        field(1176; Fld176; Text[250]) { CaptionClass = GetFieldCaption(1176); Caption = 'Fld176', Locked = true; }
        field(1177; Fld177; Text[250]) { CaptionClass = GetFieldCaption(1177); Caption = 'Fld177', Locked = true; }
        field(1178; Fld178; Text[250]) { CaptionClass = GetFieldCaption(1178); Caption = 'Fld178', Locked = true; }
        field(1179; Fld179; Text[250]) { CaptionClass = GetFieldCaption(1179); Caption = 'Fld179', Locked = true; }
        field(1180; Fld180; Text[250]) { CaptionClass = GetFieldCaption(1180); Caption = 'Fld180', Locked = true; }
        field(1181; Fld181; Text[250]) { CaptionClass = GetFieldCaption(1181); Caption = 'Fld181', Locked = true; }
        field(1182; Fld182; Text[250]) { CaptionClass = GetFieldCaption(1182); Caption = 'Fld182', Locked = true; }
        field(1183; Fld183; Text[250]) { CaptionClass = GetFieldCaption(1183); Caption = 'Fld183', Locked = true; }
        field(1184; Fld184; Text[250]) { CaptionClass = GetFieldCaption(1184); Caption = 'Fld184', Locked = true; }
        field(1185; Fld185; Text[250]) { CaptionClass = GetFieldCaption(1185); Caption = 'Fld185', Locked = true; }
        field(1186; Fld186; Text[250]) { CaptionClass = GetFieldCaption(1186); Caption = 'Fld186', Locked = true; }
        field(1187; Fld187; Text[250]) { CaptionClass = GetFieldCaption(1187); Caption = 'Fld187', Locked = true; }
        field(1188; Fld188; Text[250]) { CaptionClass = GetFieldCaption(1188); Caption = 'Fld188', Locked = true; }
        field(1189; Fld189; Text[250]) { CaptionClass = GetFieldCaption(1189); Caption = 'Fld189', Locked = true; }
        field(1190; Fld190; Text[250]) { CaptionClass = GetFieldCaption(1190); Caption = 'Fld190', Locked = true; }
        field(1191; Fld191; Text[250]) { CaptionClass = GetFieldCaption(1191); Caption = 'Fld191', Locked = true; }
        field(1192; Fld192; Text[250]) { CaptionClass = GetFieldCaption(1192); Caption = 'Fld192', Locked = true; }
        field(1193; Fld193; Text[250]) { CaptionClass = GetFieldCaption(1193); Caption = 'Fld193', Locked = true; }
        field(1194; Fld194; Text[250]) { CaptionClass = GetFieldCaption(1194); Caption = 'Fld194', Locked = true; }
        field(1195; Fld195; Text[250]) { CaptionClass = GetFieldCaption(1195); Caption = 'Fld195', Locked = true; }
        field(1196; Fld196; Text[250]) { CaptionClass = GetFieldCaption(1196); Caption = 'Fld196', Locked = true; }
        field(1197; Fld197; Text[250]) { CaptionClass = GetFieldCaption(1197); Caption = 'Fld197', Locked = true; }
        field(1198; Fld198; Text[250]) { CaptionClass = GetFieldCaption(1198); Caption = 'Fld198', Locked = true; }
        field(1199; Fld199; Text[250]) { CaptionClass = GetFieldCaption(1199); Caption = 'Fld199', Locked = true; }
        field(1200; Fld200; Text[250]) { CaptionClass = GetFieldCaption(1200); Caption = 'Fld200', Locked = true; }
        field(1201; Fld201; Text[250]) { CaptionClass = GetFieldCaption(1201); Caption = 'Fld201', Locked = true; }
        field(1202; Fld202; Text[250]) { CaptionClass = GetFieldCaption(1202); Caption = 'Fld202', Locked = true; }
        field(1203; Fld203; Text[250]) { CaptionClass = GetFieldCaption(1203); Caption = 'Fld203', Locked = true; }
        field(1204; Fld204; Text[250]) { CaptionClass = GetFieldCaption(1204); Caption = 'Fld204', Locked = true; }
        field(1205; Fld205; Text[250]) { CaptionClass = GetFieldCaption(1205); Caption = 'Fld205', Locked = true; }
        field(1206; Fld206; Text[250]) { CaptionClass = GetFieldCaption(1206); Caption = 'Fld206', Locked = true; }
        field(1207; Fld207; Text[250]) { CaptionClass = GetFieldCaption(1207); Caption = 'Fld207', Locked = true; }
        field(1208; Fld208; Text[250]) { CaptionClass = GetFieldCaption(1208); Caption = 'Fld208', Locked = true; }
        field(1209; Fld209; Text[250]) { CaptionClass = GetFieldCaption(1209); Caption = 'Fld209', Locked = true; }
        field(1210; Fld210; Text[250]) { CaptionClass = GetFieldCaption(1210); Caption = 'Fld210', Locked = true; }
        field(1211; Fld211; Text[250]) { CaptionClass = GetFieldCaption(1211); Caption = 'Fld211', Locked = true; }
        field(1212; Fld212; Text[250]) { CaptionClass = GetFieldCaption(1212); Caption = 'Fld212', Locked = true; }
        field(1213; Fld213; Text[250]) { CaptionClass = GetFieldCaption(1213); Caption = 'Fld213', Locked = true; }
        field(1214; Fld214; Text[250]) { CaptionClass = GetFieldCaption(1214); Caption = 'Fld214', Locked = true; }
        field(1215; Fld215; Text[250]) { CaptionClass = GetFieldCaption(1215); Caption = 'Fld215', Locked = true; }
        field(1216; Fld216; Text[250]) { CaptionClass = GetFieldCaption(1216); Caption = 'Fld216', Locked = true; }
        field(1217; Fld217; Text[250]) { CaptionClass = GetFieldCaption(1217); Caption = 'Fld217', Locked = true; }
        field(1218; Fld218; Text[250]) { CaptionClass = GetFieldCaption(1218); Caption = 'Fld218', Locked = true; }
        field(1219; Fld219; Text[250]) { CaptionClass = GetFieldCaption(1219); Caption = 'Fld219', Locked = true; }
        field(1220; Fld220; Text[250]) { CaptionClass = GetFieldCaption(1220); Caption = 'Fld220', Locked = true; }
        field(1221; Fld221; Text[250]) { CaptionClass = GetFieldCaption(1221); Caption = 'Fld221', Locked = true; }
        field(1222; Fld222; Text[250]) { CaptionClass = GetFieldCaption(1222); Caption = 'Fld222', Locked = true; }
        field(1223; Fld223; Text[250]) { CaptionClass = GetFieldCaption(1223); Caption = 'Fld223', Locked = true; }
        field(1224; Fld224; Text[250]) { CaptionClass = GetFieldCaption(1224); Caption = 'Fld224', Locked = true; }
        field(1225; Fld225; Text[250]) { CaptionClass = GetFieldCaption(1225); Caption = 'Fld225', Locked = true; }
        field(1226; Fld226; Text[250]) { CaptionClass = GetFieldCaption(1226); Caption = 'Fld226', Locked = true; }
        field(1227; Fld227; Text[250]) { CaptionClass = GetFieldCaption(1227); Caption = 'Fld227', Locked = true; }
        field(1228; Fld228; Text[250]) { CaptionClass = GetFieldCaption(1228); Caption = 'Fld228', Locked = true; }
        field(1229; Fld229; Text[250]) { CaptionClass = GetFieldCaption(1229); Caption = 'Fld229', Locked = true; }
        field(1230; Fld230; Text[250]) { CaptionClass = GetFieldCaption(1230); Caption = 'Fld230', Locked = true; }
        field(1231; Fld231; Text[250]) { CaptionClass = GetFieldCaption(1231); Caption = 'Fld231', Locked = true; }
        field(1232; Fld232; Text[250]) { CaptionClass = GetFieldCaption(1232); Caption = 'Fld232', Locked = true; }
        field(1233; Fld233; Text[250]) { CaptionClass = GetFieldCaption(1233); Caption = 'Fld233', Locked = true; }
        field(1234; Fld234; Text[250]) { CaptionClass = GetFieldCaption(1234); Caption = 'Fld234', Locked = true; }
        field(1235; Fld235; Text[250]) { CaptionClass = GetFieldCaption(1235); Caption = 'Fld235', Locked = true; }
        field(1236; Fld236; Text[250]) { CaptionClass = GetFieldCaption(1236); Caption = 'Fld236', Locked = true; }
        field(1237; Fld237; Text[250]) { CaptionClass = GetFieldCaption(1237); Caption = 'Fld237', Locked = true; }
        field(1238; Fld238; Text[250]) { CaptionClass = GetFieldCaption(1238); Caption = 'Fld238', Locked = true; }
        field(1239; Fld239; Text[250]) { CaptionClass = GetFieldCaption(1239); Caption = 'Fld239', Locked = true; }
        field(1240; Fld240; Text[250]) { CaptionClass = GetFieldCaption(1240); Caption = 'Fld240', Locked = true; }
        field(1241; Fld241; Text[250]) { CaptionClass = GetFieldCaption(1241); Caption = 'Fld241', Locked = true; }
        field(1242; Fld242; Text[250]) { CaptionClass = GetFieldCaption(1242); Caption = 'Fld242', Locked = true; }
        field(1243; Fld243; Text[250]) { CaptionClass = GetFieldCaption(1243); Caption = 'Fld243', Locked = true; }
        field(1244; Fld244; Text[250]) { CaptionClass = GetFieldCaption(1244); Caption = 'Fld244', Locked = true; }
        field(1245; Fld245; Text[250]) { CaptionClass = GetFieldCaption(1245); Caption = 'Fld245', Locked = true; }
        field(1246; Fld246; Text[250]) { CaptionClass = GetFieldCaption(1246); Caption = 'Fld246', Locked = true; }
        field(1247; Fld247; Text[250]) { CaptionClass = GetFieldCaption(1247); Caption = 'Fld247', Locked = true; }
        field(1248; Fld248; Text[250]) { CaptionClass = GetFieldCaption(1248); Caption = 'Fld248', Locked = true; }
        field(1249; Fld249; Text[250]) { CaptionClass = GetFieldCaption(1249); Caption = 'Fld249', Locked = true; }
        field(1250; Fld250; Text[250]) { CaptionClass = GetFieldCaption(1250); Caption = 'Fld250', Locked = true; }
        field(1251; Fld251; Text[250]) { CaptionClass = GetFieldCaption(1251); Caption = 'Fld251', Locked = true; }
        field(1252; Fld252; Text[250]) { CaptionClass = GetFieldCaption(1252); Caption = 'Fld252', Locked = true; }
        field(1253; Fld253; Text[250]) { CaptionClass = GetFieldCaption(1253); Caption = 'Fld253', Locked = true; }
        field(1254; Fld254; Text[250]) { CaptionClass = GetFieldCaption(1254); Caption = 'Fld254', Locked = true; }
        field(1255; Fld255; Text[250]) { CaptionClass = GetFieldCaption(1255); Caption = 'Fld255', Locked = true; }
        field(1256; Fld256; Text[250]) { CaptionClass = GetFieldCaption(1256); Caption = 'Fld256', Locked = true; }
        field(1257; Fld257; Text[250]) { CaptionClass = GetFieldCaption(1257); Caption = 'Fld257', Locked = true; }
        field(1258; Fld258; Text[250]) { CaptionClass = GetFieldCaption(1258); Caption = 'Fld258', Locked = true; }
        field(1259; Fld259; Text[250]) { CaptionClass = GetFieldCaption(1259); Caption = 'Fld259', Locked = true; }
        field(1260; Fld260; Text[250]) { CaptionClass = GetFieldCaption(1260); Caption = 'Fld260', Locked = true; }
        field(1261; Fld261; Text[250]) { CaptionClass = GetFieldCaption(1261); Caption = 'Fld261', Locked = true; }
        field(1262; Fld262; Text[250]) { CaptionClass = GetFieldCaption(1262); Caption = 'Fld262', Locked = true; }
        field(1263; Fld263; Text[250]) { CaptionClass = GetFieldCaption(1263); Caption = 'Fld263', Locked = true; }
        field(1264; Fld264; Text[250]) { CaptionClass = GetFieldCaption(1264); Caption = 'Fld264', Locked = true; }
        field(1265; Fld265; Text[250]) { CaptionClass = GetFieldCaption(1265); Caption = 'Fld265', Locked = true; }
        field(1266; Fld266; Text[250]) { CaptionClass = GetFieldCaption(1266); Caption = 'Fld266', Locked = true; }
        field(1267; Fld267; Text[250]) { CaptionClass = GetFieldCaption(1267); Caption = 'Fld267', Locked = true; }
        field(1268; Fld268; Text[250]) { CaptionClass = GetFieldCaption(1268); Caption = 'Fld268', Locked = true; }
        field(1269; Fld269; Text[250]) { CaptionClass = GetFieldCaption(1269); Caption = 'Fld269', Locked = true; }
        field(1270; Fld270; Text[250]) { CaptionClass = GetFieldCaption(1270); Caption = 'Fld270', Locked = true; }
        field(1271; Fld271; Text[250]) { CaptionClass = GetFieldCaption(1271); Caption = 'Fld271', Locked = true; }
        field(1272; Fld272; Text[250]) { CaptionClass = GetFieldCaption(1272); Caption = 'Fld272', Locked = true; }
        field(1273; Fld273; Text[250]) { CaptionClass = GetFieldCaption(1273); Caption = 'Fld273', Locked = true; }
        field(1274; Fld274; Text[250]) { CaptionClass = GetFieldCaption(1274); Caption = 'Fld274', Locked = true; }
        field(1275; Fld275; Text[250]) { CaptionClass = GetFieldCaption(1275); Caption = 'Fld275', Locked = true; }
        field(1276; Fld276; Text[250]) { CaptionClass = GetFieldCaption(1276); Caption = 'Fld276', Locked = true; }
        field(1277; Fld277; Text[250]) { CaptionClass = GetFieldCaption(1277); Caption = 'Fld277', Locked = true; }
        field(1278; Fld278; Text[250]) { CaptionClass = GetFieldCaption(1278); Caption = 'Fld278', Locked = true; }
        field(1279; Fld279; Text[250]) { CaptionClass = GetFieldCaption(1279); Caption = 'Fld279', Locked = true; }
        field(1280; Fld280; Text[250]) { CaptionClass = GetFieldCaption(1280); Caption = 'Fld280', Locked = true; }
        field(1281; Fld281; Text[250]) { CaptionClass = GetFieldCaption(1281); Caption = 'Fld281', Locked = true; }
        field(1282; Fld282; Text[250]) { CaptionClass = GetFieldCaption(1282); Caption = 'Fld282', Locked = true; }
        field(1283; Fld283; Text[250]) { CaptionClass = GetFieldCaption(1283); Caption = 'Fld283', Locked = true; }
        field(1284; Fld284; Text[250]) { CaptionClass = GetFieldCaption(1284); Caption = 'Fld284', Locked = true; }
        field(1285; Fld285; Text[250]) { CaptionClass = GetFieldCaption(1285); Caption = 'Fld285', Locked = true; }
        field(1286; Fld286; Text[250]) { CaptionClass = GetFieldCaption(1286); Caption = 'Fld286', Locked = true; }
        field(1287; Fld287; Text[250]) { CaptionClass = GetFieldCaption(1287); Caption = 'Fld287', Locked = true; }
        field(1288; Fld288; Text[250]) { CaptionClass = GetFieldCaption(1288); Caption = 'Fld288', Locked = true; }
        field(1289; Fld289; Text[250]) { CaptionClass = GetFieldCaption(1289); Caption = 'Fld289', Locked = true; }
        field(1290; Fld290; Text[250]) { CaptionClass = GetFieldCaption(1290); Caption = 'Fld290', Locked = true; }
        field(1291; Fld291; Text[250]) { CaptionClass = GetFieldCaption(1291); Caption = 'Fld291', Locked = true; }
        field(1292; Fld292; Text[250]) { CaptionClass = GetFieldCaption(1292); Caption = 'Fld292', Locked = true; }
        field(1293; Fld293; Text[250]) { CaptionClass = GetFieldCaption(1293); Caption = 'Fld293', Locked = true; }
        field(1294; Fld294; Text[250]) { CaptionClass = GetFieldCaption(1294); Caption = 'Fld294', Locked = true; }
        field(1295; Fld295; Text[250]) { CaptionClass = GetFieldCaption(1295); Caption = 'Fld295', Locked = true; }
        field(1296; Fld296; Text[250]) { CaptionClass = GetFieldCaption(1296); Caption = 'Fld296', Locked = true; }
        field(1297; Fld297; Text[250]) { CaptionClass = GetFieldCaption(1297); Caption = 'Fld297', Locked = true; }
        field(1298; Fld298; Text[250]) { CaptionClass = GetFieldCaption(1298); Caption = 'Fld298', Locked = true; }
        field(1299; Fld299; Text[250]) { CaptionClass = GetFieldCaption(1299); Caption = 'Fld299', Locked = true; }
        field(1300; Fld300; Text[250]) { CaptionClass = GetFieldCaption(1300); Caption = 'Fld300', Locked = true; }
    }

    keys
    {
        key(Key1; "Entry No.") { Clustered = true; }
    }

    trigger OnDelete()
    var
        DMTBlobStorage: Record DMTBlobStorage;
    begin
        if DMTBlobStorage.filterBy(Rec) then
            DMTBlobStorage.DeleteAll();
    end;

    /// <summary>Check if file has header line</summary>
    procedure HasCaptionLine(ImportConfigID: Integer) Result: Boolean
    var
        importConfigHeader: Record DMTImportConfigHeader;
        GenBuffTable_CaptionLine: Record DMTGenBuffTable;
    begin
        if not importConfigHeader.Get(ImportConfigID) then
            exit(false);
        GenBuffTable_CaptionLine.SetRange(IsCaptionLine, true);
        GenBuffTable_CaptionLine.SetRange("Imp.Conf.Header ID", ImportConfigID);
        GenBuffTable_CaptionLine.SetRange("Import from Filename", importConfigHeader."Source File Name");
        Result := not GenBuffTable_CaptionLine.IsEmpty();
    end;

    procedure InitFirstLineAsCaptions(var GenBuffTable_First: Record DMTGenBuffTable) NoOfCols: Integer
    var
        GenBuffTable_CaptionLine: Record DMTGenBuffTable;
        RecRef: RecordRef;
        FieldIndex: Integer;
    begin
        if (GenBuffTable_First."Entry No." = 0) then
            if GenBuffTable_First.FindFirst() then;
        GenBuffTable_CaptionLine.SetRange(IsCaptionLine, true);
        GenBuffTable_CaptionLine.SetRange("Imp.Conf.Header ID", GenBuffTable_First."Imp.Conf.Header ID");
        GenBuffTable_CaptionLine.SetRange("Import from Filename", GenBuffTable_First."Import from Filename");
        if not GenBuffTable_CaptionLine.FindFirst() then
            Error('No caption line found for %1', GenBuffTable_First."Import from Filename");


        DMTGenBufferFieldCaptions.DisposeCaptions();
        RecRef.GetTable(GenBuffTable_CaptionLine);
        for FieldIndex := 1001 to (1001 + GenBuffTable_CaptionLine."Column Count" - 1) do begin
            DMTGenBufferFieldCaptions.AddCaption(FieldIndex, RecRef.Field(FieldIndex).Value);
        end;
        NoOfCols := DMTGenBufferFieldCaptions.GetNoOfCaptions();
        DMTGenBufferFieldCaptions.SetUnusedCaptions();
    end;

    internal procedure FilterBy(ImportConfigHeader: Record DMTImportConfigHeader) HasLinesInFilter: Boolean
    var
        SourceFileStorage: Record DMTSourceFileStorage;
    begin
        ImportConfigHeader.TestField("Source File ID");
        SourceFileStorage.Get(ImportConfigHeader."Source File ID");
        Rec.SetRange("Imp.Conf.Header ID", ImportConfigHeader.ID);
        Rec.SetRange("Import from Filename", SourceFileStorage.Name);
        HasLinesInFilter := not Rec.IsEmpty;
    end;

    internal procedure GetColCaptionForImportedFile(ImportConfigHeader: Record DMTImportConfigHeader; var BuffTableCaptions: Dictionary of [Integer, Text]) OK: Boolean
    var
        GenBuffTable: Record DMTGenBuffTable;
        dataLayout: Record DMTDataLayout;
        RecRef: RecordRef;
        FieldIndex: Integer;
    begin
        Clear(BuffTableCaptions);
        OK := true;
        dataLayout := ImportConfigHeader.GetDataLayout();
        if not GenBuffTable.FilterBy(ImportConfigHeader) then begin
            Message('Keine Zeilen in der Puffertabelle gefunden (%1 - %2)', ImportConfigHeader.TableCaption, ImportConfigHeader.ID);
            exit(false);
        end;
        GenBuffTable.SetRange(IsCaptionLine, true);
        if not GenBuffTable.FindFirst() then begin
            Message('Keine Überschriftenzeile in der Puffertabelle gefunden (%1 - %2)', ImportConfigHeader.TableCaption, ImportConfigHeader.ID);
            exit(false);
        end;
        RecRef.GetTable(GenBuffTable);
        for FieldIndex := 1001 to (1000 + GenBuffTable."Column Count") do begin
            BuffTableCaptions.Add(FieldIndex, Format(RecRef.Field(FieldIndex).Value));
        end;
    end;

    internal procedure GetNextEntryNo() NextEntryNo: Integer
    var
        GenBuffTable: Record DMTGenBuffTable;
    begin
        NextEntryNo := 1;
        GenBuffTable.Reset();
        GenBuffTable.SetLoadFields("Entry No.");
        if GenBuffTable.FindLast() then begin
            NextEntryNo += GenBuffTable."Entry No.";
        end;
    end;

    internal procedure LookUpBlobContent()
    var
        blobStorage: Record DMTBlobStorage;
        TempBlob: Codeunit "Temp Blob";
        mlText: TextBuilder;
    begin
        if not blobStorage.filterBy(Rec) then
            exit;
        blobStorage.FindSet(false);
        repeat
            TempBlob.FromRecord(blobStorage, blobStorage.fieldNo(Blob));
            mlText.AppendLine('Field: ' + blobStorage."Source Field Caption" + ' Size:' + Format(TempBlob.Length()));
            mlText.AppendLine(blobStorage.getContentAsText());
        until blobStorage.Next() = 0;
        Message(mlText.ToText());
    end;

    local procedure GetFieldCaption(FieldNo: Integer) FieldCaption: Text
    begin
        if not DMTGenBufferFieldCaptions.HasCaption(FieldNo) then
            FieldCaption := Format(FieldNo);
        FieldCaption := '3,' + DMTGenBufferFieldCaptions.GetCaption(FieldNo);
    end;

    procedure ShowBufferTable(ImportConfigHeader: Record DMTImportConfigHeader)
    var
        GenBuffTable: Record DMTGenBuffTable;
        NoOfCols: Integer;
    begin
        DMTGenBufferFieldCaptions.DisposeCaptions();
        GenBuffTable.FilterBy(ImportConfigHeader);
        GenBuffTable.FindFirst();
        NoOfCols := GenBuffTable.InitFirstLineAsCaptions(GenBuffTable);

        GenBuffTable.Reset();
        GenBuffTable.FilterBy(ImportConfigHeader);
        GenBuffTable.SetRange(IsCaptionLine, false);
        // less Columns is faster
        case NoOfCols of
            0 .. 50:
                Page.Run(Page::DMTGenBufferList50, GenBuffTable);
            51 .. 100:
                Page.Run(Page::DMTGenBufferList100, GenBuffTable);
            101 .. 150:
                Page.Run(Page::DMTGenBufferList150, GenBuffTable);
            else
                Page.Run(Page::DMTGenBufferList250, GenBuffTable);
        end;
    end;

    /// <summary>
    /// Returns all unique value combinations for a set of fields
    /// </summary>
    /// <param name="importConfigHeaderID">Import Config Header ID with the related buffer data</param>
    /// <param name="FieldIDs">list of field ids to process</param>
    /// <returns>list of list of text with all unique combinations</returns>
    procedure GetUniqueColumnValues(importConfigHeaderID: integer; FieldIDs: List of [Integer]) uniqueValues: List of [List of [Text]]
    var
        genBuffTable: Record DMTGenBuffTable;
        importConfigHeader: Record DMTImportConfigHeader;
        RecRef: RecordRef;
        valueAsText: Text;
        UnitSeparator: Char;
        fieldID: integer;
        token: text;
        firstFieldID: integer;
        uniqueToken, lineValues : List of [Text];
    begin
        UnitSeparator := '▼';
        importConfigHeader.Get(importConfigHeaderID);
        genBuffTable.FilterBy(importConfigHeader);
        genBuffTable.SetRange(IsCaptionLine, false);
        RecRef.GetTable(genBuffTable);
        foreach fieldID in FieldIDs do
            RecRef.AddLoadFields(fieldID);
        firstFieldID := FieldIDs.Get(1);
        if RecRef.FindSet() then
            repeat
                Clear(token);
                foreach fieldID in FieldIDs do begin
                    if fieldID <> firstFieldID then
                        token += UnitSeparator;
                    valueAsText := format(RecRef.Field(fieldID).Value);
                    token += valueAsText;
                end;
                if not uniqueToken.Contains(token) then begin
                    uniqueToken.Add(token);
                    lineValues := token.Split(UnitSeparator);
                    uniqueValues.Add(lineValues);
                end;
            until RecRef.Next() = 0;
    end;

    var
        DMTGenBufferFieldCaptions: Codeunit DMTSessionStorage;
}