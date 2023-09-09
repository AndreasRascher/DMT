table 91001 DMTGenBuffTable
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer) { }
        field(10; "Import from Filename"; Text[250]) { Caption = 'Import from Filename', Comment = 'de=DE=Import Dateiname'; }
        field(11; "Imp.Conf.Header ID"; Integer)
        {
            Caption = 'Imp.Conf.Header ID', Comment = 'de=DE=Import Konfig. Kopf ID';
            TableRelation = DMTImportConfigHeader;
        }
        field(13; IsCaptionLine; Boolean) { }
        field(14; "Column Count"; Integer) { }
        field(20; Imported; Boolean) { Caption = 'Imported', comment = 'de-DE=Importiert'; }
        field(21; "RecId (Imported)"; RecordId) { Caption = 'Record ID (Imported)', comment = 'de-DE=Datensatz-ID (Importiert)'; }
        field(1001; Fld001; Text[250]) { CaptionClass = GetFieldCaption(1001); }
        field(1002; Fld002; Text[250]) { CaptionClass = GetFieldCaption(1002); }
        field(1003; Fld003; Text[250]) { CaptionClass = GetFieldCaption(1003); }
        field(1004; Fld004; Text[250]) { CaptionClass = GetFieldCaption(1004); }
        field(1005; Fld005; Text[250]) { CaptionClass = GetFieldCaption(1005); }
        field(1006; Fld006; Text[250]) { CaptionClass = GetFieldCaption(1006); }
        field(1007; Fld007; Text[250]) { CaptionClass = GetFieldCaption(1007); }
        field(1008; Fld008; Text[250]) { CaptionClass = GetFieldCaption(1008); }
        field(1009; Fld009; Text[250]) { CaptionClass = GetFieldCaption(1009); }
        field(1010; Fld010; Text[250]) { CaptionClass = GetFieldCaption(1010); }
        field(1011; Fld011; Text[250]) { CaptionClass = GetFieldCaption(1011); }
        field(1012; Fld012; Text[250]) { CaptionClass = GetFieldCaption(1012); }
        field(1013; Fld013; Text[250]) { CaptionClass = GetFieldCaption(1013); }
        field(1014; Fld014; Text[250]) { CaptionClass = GetFieldCaption(1014); }
        field(1015; Fld015; Text[250]) { CaptionClass = GetFieldCaption(1015); }
        field(1016; Fld016; Text[250]) { CaptionClass = GetFieldCaption(1016); }
        field(1017; Fld017; Text[250]) { CaptionClass = GetFieldCaption(1017); }
        field(1018; Fld018; Text[250]) { CaptionClass = GetFieldCaption(1018); }
        field(1019; Fld019; Text[250]) { CaptionClass = GetFieldCaption(1019); }
        field(1020; Fld020; Text[250]) { CaptionClass = GetFieldCaption(1020); }
        field(1021; Fld021; Text[250]) { CaptionClass = GetFieldCaption(1021); }
        field(1022; Fld022; Text[250]) { CaptionClass = GetFieldCaption(1022); }
        field(1023; Fld023; Text[250]) { CaptionClass = GetFieldCaption(1023); }
        field(1024; Fld024; Text[250]) { CaptionClass = GetFieldCaption(1024); }
        field(1025; Fld025; Text[250]) { CaptionClass = GetFieldCaption(1025); }
        field(1026; Fld026; Text[250]) { CaptionClass = GetFieldCaption(1026); }
        field(1027; Fld027; Text[250]) { CaptionClass = GetFieldCaption(1027); }
        field(1028; Fld028; Text[250]) { CaptionClass = GetFieldCaption(1028); }
        field(1029; Fld029; Text[250]) { CaptionClass = GetFieldCaption(1029); }
        field(1030; Fld030; Text[250]) { CaptionClass = GetFieldCaption(1030); }
        field(1031; Fld031; Text[250]) { CaptionClass = GetFieldCaption(1031); }
        field(1032; Fld032; Text[250]) { CaptionClass = GetFieldCaption(1032); }
        field(1033; Fld033; Text[250]) { CaptionClass = GetFieldCaption(1033); }
        field(1034; Fld034; Text[250]) { CaptionClass = GetFieldCaption(1034); }
        field(1035; Fld035; Text[250]) { CaptionClass = GetFieldCaption(1035); }
        field(1036; Fld036; Text[250]) { CaptionClass = GetFieldCaption(1036); }
        field(1037; Fld037; Text[250]) { CaptionClass = GetFieldCaption(1037); }
        field(1038; Fld038; Text[250]) { CaptionClass = GetFieldCaption(1038); }
        field(1039; Fld039; Text[250]) { CaptionClass = GetFieldCaption(1039); }
        field(1040; Fld040; Text[250]) { CaptionClass = GetFieldCaption(1040); }
        field(1041; Fld041; Text[250]) { CaptionClass = GetFieldCaption(1041); }
        field(1042; Fld042; Text[250]) { CaptionClass = GetFieldCaption(1042); }
        field(1043; Fld043; Text[250]) { CaptionClass = GetFieldCaption(1043); }
        field(1044; Fld044; Text[250]) { CaptionClass = GetFieldCaption(1044); }
        field(1045; Fld045; Text[250]) { CaptionClass = GetFieldCaption(1045); }
        field(1046; Fld046; Text[250]) { CaptionClass = GetFieldCaption(1046); }
        field(1047; Fld047; Text[250]) { CaptionClass = GetFieldCaption(1047); }
        field(1048; Fld048; Text[250]) { CaptionClass = GetFieldCaption(1048); }
        field(1049; Fld049; Text[250]) { CaptionClass = GetFieldCaption(1049); }
        field(1050; Fld050; Text[250]) { CaptionClass = GetFieldCaption(1050); }
        field(1051; Fld051; Text[250]) { CaptionClass = GetFieldCaption(1051); }
        field(1052; Fld052; Text[250]) { CaptionClass = GetFieldCaption(1052); }
        field(1053; Fld053; Text[250]) { CaptionClass = GetFieldCaption(1053); }
        field(1054; Fld054; Text[250]) { CaptionClass = GetFieldCaption(1054); }
        field(1055; Fld055; Text[250]) { CaptionClass = GetFieldCaption(1055); }
        field(1056; Fld056; Text[250]) { CaptionClass = GetFieldCaption(1056); }
        field(1057; Fld057; Text[250]) { CaptionClass = GetFieldCaption(1057); }
        field(1058; Fld058; Text[250]) { CaptionClass = GetFieldCaption(1058); }
        field(1059; Fld059; Text[250]) { CaptionClass = GetFieldCaption(1059); }
        field(1060; Fld060; Text[250]) { CaptionClass = GetFieldCaption(1060); }
        field(1061; Fld061; Text[250]) { CaptionClass = GetFieldCaption(1061); }
        field(1062; Fld062; Text[250]) { CaptionClass = GetFieldCaption(1062); }
        field(1063; Fld063; Text[250]) { CaptionClass = GetFieldCaption(1063); }
        field(1064; Fld064; Text[250]) { CaptionClass = GetFieldCaption(1064); }
        field(1065; Fld065; Text[250]) { CaptionClass = GetFieldCaption(1065); }
        field(1066; Fld066; Text[250]) { CaptionClass = GetFieldCaption(1066); }
        field(1067; Fld067; Text[250]) { CaptionClass = GetFieldCaption(1067); }
        field(1068; Fld068; Text[250]) { CaptionClass = GetFieldCaption(1068); }
        field(1069; Fld069; Text[250]) { CaptionClass = GetFieldCaption(1069); }
        field(1070; Fld070; Text[250]) { CaptionClass = GetFieldCaption(1070); }
        field(1071; Fld071; Text[250]) { CaptionClass = GetFieldCaption(1071); }
        field(1072; Fld072; Text[250]) { CaptionClass = GetFieldCaption(1072); }
        field(1073; Fld073; Text[250]) { CaptionClass = GetFieldCaption(1073); }
        field(1074; Fld074; Text[250]) { CaptionClass = GetFieldCaption(1074); }
        field(1075; Fld075; Text[250]) { CaptionClass = GetFieldCaption(1075); }
        field(1076; Fld076; Text[250]) { CaptionClass = GetFieldCaption(1076); }
        field(1077; Fld077; Text[250]) { CaptionClass = GetFieldCaption(1077); }
        field(1078; Fld078; Text[250]) { CaptionClass = GetFieldCaption(1078); }
        field(1079; Fld079; Text[250]) { CaptionClass = GetFieldCaption(1079); }
        field(1080; Fld080; Text[250]) { CaptionClass = GetFieldCaption(1080); }
        field(1081; Fld081; Text[250]) { CaptionClass = GetFieldCaption(1081); }
        field(1082; Fld082; Text[250]) { CaptionClass = GetFieldCaption(1082); }
        field(1083; Fld083; Text[250]) { CaptionClass = GetFieldCaption(1083); }
        field(1084; Fld084; Text[250]) { CaptionClass = GetFieldCaption(1084); }
        field(1085; Fld085; Text[250]) { CaptionClass = GetFieldCaption(1085); }
        field(1086; Fld086; Text[250]) { CaptionClass = GetFieldCaption(1086); }
        field(1087; Fld087; Text[250]) { CaptionClass = GetFieldCaption(1087); }
        field(1088; Fld088; Text[250]) { CaptionClass = GetFieldCaption(1088); }
        field(1089; Fld089; Text[250]) { CaptionClass = GetFieldCaption(1089); }
        field(1090; Fld090; Text[250]) { CaptionClass = GetFieldCaption(1090); }
        field(1091; Fld091; Text[250]) { CaptionClass = GetFieldCaption(1091); }
        field(1092; Fld092; Text[250]) { CaptionClass = GetFieldCaption(1092); }
        field(1093; Fld093; Text[250]) { CaptionClass = GetFieldCaption(1093); }
        field(1094; Fld094; Text[250]) { CaptionClass = GetFieldCaption(1094); }
        field(1095; Fld095; Text[250]) { CaptionClass = GetFieldCaption(1095); }
        field(1096; Fld096; Text[250]) { CaptionClass = GetFieldCaption(1096); }
        field(1097; Fld097; Text[250]) { CaptionClass = GetFieldCaption(1097); }
        field(1098; Fld098; Text[250]) { CaptionClass = GetFieldCaption(1098); }
        field(1099; Fld099; Text[250]) { CaptionClass = GetFieldCaption(1099); }
        field(1100; Fld100; Text[250]) { CaptionClass = GetFieldCaption(1100); }
        field(1101; Fld101; Text[250]) { CaptionClass = GetFieldCaption(1101); }
        field(1102; Fld102; Text[250]) { CaptionClass = GetFieldCaption(1102); }
        field(1103; Fld103; Text[250]) { CaptionClass = GetFieldCaption(1103); }
        field(1104; Fld104; Text[250]) { CaptionClass = GetFieldCaption(1104); }
        field(1105; Fld105; Text[250]) { CaptionClass = GetFieldCaption(1105); }
        field(1106; Fld106; Text[250]) { CaptionClass = GetFieldCaption(1106); }
        field(1107; Fld107; Text[250]) { CaptionClass = GetFieldCaption(1107); }
        field(1108; Fld108; Text[250]) { CaptionClass = GetFieldCaption(1108); }
        field(1109; Fld109; Text[250]) { CaptionClass = GetFieldCaption(1109); }
        field(1110; Fld110; Text[250]) { CaptionClass = GetFieldCaption(1100); }
        field(1111; Fld111; Text[250]) { CaptionClass = GetFieldCaption(1111); }
        field(1112; Fld112; Text[250]) { CaptionClass = GetFieldCaption(1112); }
        field(1113; Fld113; Text[250]) { CaptionClass = GetFieldCaption(1113); }
        field(1114; Fld114; Text[250]) { CaptionClass = GetFieldCaption(1114); }
        field(1115; Fld115; Text[250]) { CaptionClass = GetFieldCaption(1115); }
        field(1116; Fld116; Text[250]) { CaptionClass = GetFieldCaption(1116); }
        field(1117; Fld117; Text[250]) { CaptionClass = GetFieldCaption(1117); }
        field(1118; Fld118; Text[250]) { CaptionClass = GetFieldCaption(1118); }
        field(1119; Fld119; Text[250]) { CaptionClass = GetFieldCaption(1119); }
        field(1120; Fld120; Text[250]) { CaptionClass = GetFieldCaption(1120); }
        field(1121; Fld121; Text[250]) { CaptionClass = GetFieldCaption(1121); }
        field(1122; Fld122; Text[250]) { CaptionClass = GetFieldCaption(1122); }
        field(1123; Fld123; Text[250]) { CaptionClass = GetFieldCaption(1123); }
        field(1124; Fld124; Text[250]) { CaptionClass = GetFieldCaption(1124); }
        field(1125; Fld125; Text[250]) { CaptionClass = GetFieldCaption(1125); }
        field(1126; Fld126; Text[250]) { CaptionClass = GetFieldCaption(1126); }
        field(1127; Fld127; Text[250]) { CaptionClass = GetFieldCaption(1127); }
        field(1128; Fld128; Text[250]) { CaptionClass = GetFieldCaption(1128); }
        field(1129; Fld129; Text[250]) { CaptionClass = GetFieldCaption(1129); }
        field(1130; Fld130; Text[250]) { CaptionClass = GetFieldCaption(1130); }
        field(1131; Fld131; Text[250]) { CaptionClass = GetFieldCaption(1131); }
        field(1132; Fld132; Text[250]) { CaptionClass = GetFieldCaption(1132); }
        field(1133; Fld133; Text[250]) { CaptionClass = GetFieldCaption(1133); }
        field(1134; Fld134; Text[250]) { CaptionClass = GetFieldCaption(1134); }
        field(1135; Fld135; Text[250]) { CaptionClass = GetFieldCaption(1135); }
        field(1136; Fld136; Text[250]) { CaptionClass = GetFieldCaption(1136); }
        field(1137; Fld137; Text[250]) { CaptionClass = GetFieldCaption(1137); }
        field(1138; Fld138; Text[250]) { CaptionClass = GetFieldCaption(1138); }
        field(1139; Fld139; Text[250]) { CaptionClass = GetFieldCaption(1139); }
        field(1140; Fld140; Text[250]) { CaptionClass = GetFieldCaption(1140); }
        field(1141; Fld141; Text[250]) { CaptionClass = GetFieldCaption(1141); }
        field(1142; Fld142; Text[250]) { CaptionClass = GetFieldCaption(1142); }
        field(1143; Fld143; Text[250]) { CaptionClass = GetFieldCaption(1143); }
        field(1144; Fld144; Text[250]) { CaptionClass = GetFieldCaption(1144); }
        field(1145; Fld145; Text[250]) { CaptionClass = GetFieldCaption(1145); }
        field(1146; Fld146; Text[250]) { CaptionClass = GetFieldCaption(1146); }
        field(1147; Fld147; Text[250]) { CaptionClass = GetFieldCaption(1147); }
        field(1148; Fld148; Text[250]) { CaptionClass = GetFieldCaption(1148); }
        field(1149; Fld149; Text[250]) { CaptionClass = GetFieldCaption(1149); }
        field(1150; Fld150; Text[250]) { CaptionClass = GetFieldCaption(1150); }
        field(1151; Fld151; Text[250]) { CaptionClass = GetFieldCaption(1151); }
        field(1152; Fld152; Text[250]) { CaptionClass = GetFieldCaption(1152); }
        field(1153; Fld153; Text[250]) { CaptionClass = GetFieldCaption(1153); }
        field(1154; Fld154; Text[250]) { CaptionClass = GetFieldCaption(1154); }
        field(1155; Fld155; Text[250]) { CaptionClass = GetFieldCaption(1155); }
        field(1156; Fld156; Text[250]) { CaptionClass = GetFieldCaption(1156); }
        field(1157; Fld157; Text[250]) { CaptionClass = GetFieldCaption(1157); }
        field(1158; Fld158; Text[250]) { CaptionClass = GetFieldCaption(1158); }
        field(1159; Fld159; Text[250]) { CaptionClass = GetFieldCaption(1159); }
        field(1160; Fld160; Text[250]) { CaptionClass = GetFieldCaption(1160); }
        field(1161; Fld161; Text[250]) { CaptionClass = GetFieldCaption(1161); }
        field(1162; Fld162; Text[250]) { CaptionClass = GetFieldCaption(1162); }
        field(1163; Fld163; Text[250]) { CaptionClass = GetFieldCaption(1163); }
        field(1164; Fld164; Text[250]) { CaptionClass = GetFieldCaption(1164); }
        field(1165; Fld165; Text[250]) { CaptionClass = GetFieldCaption(1165); }
        field(1166; Fld166; Text[250]) { CaptionClass = GetFieldCaption(1166); }
        field(1167; Fld167; Text[250]) { CaptionClass = GetFieldCaption(1167); }
        field(1168; Fld168; Text[250]) { CaptionClass = GetFieldCaption(1168); }
        field(1169; Fld169; Text[250]) { CaptionClass = GetFieldCaption(1169); }
        field(1170; Fld170; Text[250]) { CaptionClass = GetFieldCaption(1170); }
        field(1171; Fld171; Text[250]) { CaptionClass = GetFieldCaption(1171); }
        field(1172; Fld172; Text[250]) { CaptionClass = GetFieldCaption(1172); }
        field(1173; Fld173; Text[250]) { CaptionClass = GetFieldCaption(1173); }
        field(1174; Fld174; Text[250]) { CaptionClass = GetFieldCaption(1174); }
        field(1175; Fld175; Text[250]) { CaptionClass = GetFieldCaption(1175); }
        field(1176; Fld176; Text[250]) { CaptionClass = GetFieldCaption(1176); }
        field(1177; Fld177; Text[250]) { CaptionClass = GetFieldCaption(1177); }
        field(1178; Fld178; Text[250]) { CaptionClass = GetFieldCaption(1178); }
        field(1179; Fld179; Text[250]) { CaptionClass = GetFieldCaption(1179); }
        field(1180; Fld180; Text[250]) { CaptionClass = GetFieldCaption(1180); }
        field(1181; Fld181; Text[250]) { CaptionClass = GetFieldCaption(1181); }
        field(1182; Fld182; Text[250]) { CaptionClass = GetFieldCaption(1182); }
        field(1183; Fld183; Text[250]) { CaptionClass = GetFieldCaption(1183); }
        field(1184; Fld184; Text[250]) { CaptionClass = GetFieldCaption(1184); }
        field(1185; Fld185; Text[250]) { CaptionClass = GetFieldCaption(1185); }
        field(1186; Fld186; Text[250]) { CaptionClass = GetFieldCaption(1186); }
        field(1187; Fld187; Text[250]) { CaptionClass = GetFieldCaption(1187); }
        field(1188; Fld188; Text[250]) { CaptionClass = GetFieldCaption(1188); }
        field(1189; Fld189; Text[250]) { CaptionClass = GetFieldCaption(1189); }
        field(1190; Fld190; Text[250]) { CaptionClass = GetFieldCaption(1190); }
        field(1191; Fld191; Text[250]) { CaptionClass = GetFieldCaption(1191); }
        field(1192; Fld192; Text[250]) { CaptionClass = GetFieldCaption(1192); }
        field(1193; Fld193; Text[250]) { CaptionClass = GetFieldCaption(1193); }
        field(1194; Fld194; Text[250]) { CaptionClass = GetFieldCaption(1194); }
        field(1195; Fld195; Text[250]) { CaptionClass = GetFieldCaption(1195); }
        field(1196; Fld196; Text[250]) { CaptionClass = GetFieldCaption(1196); }
        field(1197; Fld197; Text[250]) { CaptionClass = GetFieldCaption(1197); }
        field(1198; Fld198; Text[250]) { CaptionClass = GetFieldCaption(1198); }
        field(1199; Fld199; Text[250]) { CaptionClass = GetFieldCaption(1199); }
        field(1200; Fld200; Text[250]) { CaptionClass = GetFieldCaption(1200); }
        field(1201; Fld201; Text[250]) { CaptionClass = GetFieldCaption(1201); }
        field(1202; Fld202; Text[250]) { CaptionClass = GetFieldCaption(1202); }
        field(1203; Fld203; Text[250]) { CaptionClass = GetFieldCaption(1203); }
        field(1204; Fld204; Text[250]) { CaptionClass = GetFieldCaption(1204); }
        field(1205; Fld205; Text[250]) { CaptionClass = GetFieldCaption(1205); }
        field(1206; Fld206; Text[250]) { CaptionClass = GetFieldCaption(1206); }
        field(1207; Fld207; Text[250]) { CaptionClass = GetFieldCaption(1207); }
        field(1208; Fld208; Text[250]) { CaptionClass = GetFieldCaption(1208); }
        field(1209; Fld209; Text[250]) { CaptionClass = GetFieldCaption(1209); }
        field(1210; Fld210; Text[250]) { CaptionClass = GetFieldCaption(1210); }
        field(1211; Fld211; Text[250]) { CaptionClass = GetFieldCaption(1211); }
        field(1212; Fld212; Text[250]) { CaptionClass = GetFieldCaption(1212); }
        field(1213; Fld213; Text[250]) { CaptionClass = GetFieldCaption(1213); }
        field(1214; Fld214; Text[250]) { CaptionClass = GetFieldCaption(1214); }
        field(1215; Fld215; Text[250]) { CaptionClass = GetFieldCaption(1215); }
        field(1216; Fld216; Text[250]) { CaptionClass = GetFieldCaption(1216); }
        field(1217; Fld217; Text[250]) { CaptionClass = GetFieldCaption(1217); }
        field(1218; Fld218; Text[250]) { CaptionClass = GetFieldCaption(1218); }
        field(1219; Fld219; Text[250]) { CaptionClass = GetFieldCaption(1219); }
        field(1220; Fld220; Text[250]) { CaptionClass = GetFieldCaption(1220); }
        field(1221; Fld221; Text[250]) { CaptionClass = GetFieldCaption(1221); }
        field(1222; Fld222; Text[250]) { CaptionClass = GetFieldCaption(1222); }
        field(1223; Fld223; Text[250]) { CaptionClass = GetFieldCaption(1223); }
        field(1224; Fld224; Text[250]) { CaptionClass = GetFieldCaption(1224); }
        field(1225; Fld225; Text[250]) { CaptionClass = GetFieldCaption(1225); }
        field(1226; Fld226; Text[250]) { CaptionClass = GetFieldCaption(1226); }
        field(1227; Fld227; Text[250]) { CaptionClass = GetFieldCaption(1227); }
        field(1228; Fld228; Text[250]) { CaptionClass = GetFieldCaption(1228); }
        field(1229; Fld229; Text[250]) { CaptionClass = GetFieldCaption(1229); }
        field(1230; Fld230; Text[250]) { CaptionClass = GetFieldCaption(1230); }
        field(1231; Fld231; Text[250]) { CaptionClass = GetFieldCaption(1231); }
        field(1232; Fld232; Text[250]) { CaptionClass = GetFieldCaption(1232); }
        field(1233; Fld233; Text[250]) { CaptionClass = GetFieldCaption(1233); }
        field(1234; Fld234; Text[250]) { CaptionClass = GetFieldCaption(1234); }
        field(1235; Fld235; Text[250]) { CaptionClass = GetFieldCaption(1235); }
        field(1236; Fld236; Text[250]) { CaptionClass = GetFieldCaption(1236); }
        field(1237; Fld237; Text[250]) { CaptionClass = GetFieldCaption(1237); }
        field(1238; Fld238; Text[250]) { CaptionClass = GetFieldCaption(1238); }
        field(1239; Fld239; Text[250]) { CaptionClass = GetFieldCaption(1239); }
        field(1240; Fld240; Text[250]) { CaptionClass = GetFieldCaption(1240); }
        field(1241; Fld241; Text[250]) { CaptionClass = GetFieldCaption(1241); }
        field(1242; Fld242; Text[250]) { CaptionClass = GetFieldCaption(1242); }
        field(1243; Fld243; Text[250]) { CaptionClass = GetFieldCaption(1243); }
        field(1244; Fld244; Text[250]) { CaptionClass = GetFieldCaption(1244); }
        field(1245; Fld245; Text[250]) { CaptionClass = GetFieldCaption(1245); }
        field(1246; Fld246; Text[250]) { CaptionClass = GetFieldCaption(1246); }
        field(1247; Fld247; Text[250]) { CaptionClass = GetFieldCaption(1247); }
        field(1248; Fld248; Text[250]) { CaptionClass = GetFieldCaption(1248); }
        field(1249; Fld249; Text[250]) { CaptionClass = GetFieldCaption(1249); }
        field(1250; Fld250; Text[250]) { CaptionClass = GetFieldCaption(1250); }
        field(1251; Fld251; Text[250]) { CaptionClass = GetFieldCaption(1251); }
        field(1252; Fld252; Text[250]) { CaptionClass = GetFieldCaption(1252); }
        field(1253; Fld253; Text[250]) { CaptionClass = GetFieldCaption(1253); }
        field(1254; Fld254; Text[250]) { CaptionClass = GetFieldCaption(1254); }
        field(1255; Fld255; Text[250]) { CaptionClass = GetFieldCaption(1255); }
        field(1256; Fld256; Text[250]) { CaptionClass = GetFieldCaption(1256); }
        field(1257; Fld257; Text[250]) { CaptionClass = GetFieldCaption(1257); }
        field(1258; Fld258; Text[250]) { CaptionClass = GetFieldCaption(1258); }
        field(1259; Fld259; Text[250]) { CaptionClass = GetFieldCaption(1259); }
        field(1260; Fld260; Text[250]) { CaptionClass = GetFieldCaption(1260); }
        field(1261; Fld261; Text[250]) { CaptionClass = GetFieldCaption(1261); }
        field(1262; Fld262; Text[250]) { CaptionClass = GetFieldCaption(1262); }
        field(1263; Fld263; Text[250]) { CaptionClass = GetFieldCaption(1263); }
        field(1264; Fld264; Text[250]) { CaptionClass = GetFieldCaption(1264); }
        field(1265; Fld265; Text[250]) { CaptionClass = GetFieldCaption(1265); }
        field(1266; Fld266; Text[250]) { CaptionClass = GetFieldCaption(1266); }
        field(1267; Fld267; Text[250]) { CaptionClass = GetFieldCaption(1267); }
        field(1268; Fld268; Text[250]) { CaptionClass = GetFieldCaption(1268); }
        field(1269; Fld269; Text[250]) { CaptionClass = GetFieldCaption(1269); }
        field(1270; Fld270; Text[250]) { CaptionClass = GetFieldCaption(1270); }
        field(1271; Fld271; Text[250]) { CaptionClass = GetFieldCaption(1271); }
        field(1272; Fld272; Text[250]) { CaptionClass = GetFieldCaption(1272); }
        field(1273; Fld273; Text[250]) { CaptionClass = GetFieldCaption(1273); }
        field(1274; Fld274; Text[250]) { CaptionClass = GetFieldCaption(1274); }
        field(1275; Fld275; Text[250]) { CaptionClass = GetFieldCaption(1275); }
        field(1276; Fld276; Text[250]) { CaptionClass = GetFieldCaption(1276); }
        field(1277; Fld277; Text[250]) { CaptionClass = GetFieldCaption(1277); }
        field(1278; Fld278; Text[250]) { CaptionClass = GetFieldCaption(1278); }
        field(1279; Fld279; Text[250]) { CaptionClass = GetFieldCaption(1279); }
        field(1280; Fld280; Text[250]) { CaptionClass = GetFieldCaption(1280); }
        field(1281; Fld281; Text[250]) { CaptionClass = GetFieldCaption(1281); }
        field(1282; Fld282; Text[250]) { CaptionClass = GetFieldCaption(1282); }
        field(1283; Fld283; Text[250]) { CaptionClass = GetFieldCaption(1283); }
        field(1284; Fld284; Text[250]) { CaptionClass = GetFieldCaption(1284); }
        field(1285; Fld285; Text[250]) { CaptionClass = GetFieldCaption(1285); }
        field(1286; Fld286; Text[250]) { CaptionClass = GetFieldCaption(1286); }
        field(1287; Fld287; Text[250]) { CaptionClass = GetFieldCaption(1287); }
        field(1288; Fld288; Text[250]) { CaptionClass = GetFieldCaption(1288); }
        field(1289; Fld289; Text[250]) { CaptionClass = GetFieldCaption(1289); }
        field(1290; Fld290; Text[250]) { CaptionClass = GetFieldCaption(1290); }
        field(1291; Fld291; Text[250]) { CaptionClass = GetFieldCaption(1291); }
        field(1292; Fld292; Text[250]) { CaptionClass = GetFieldCaption(1292); }
        field(1293; Fld293; Text[250]) { CaptionClass = GetFieldCaption(1293); }
        field(1294; Fld294; Text[250]) { CaptionClass = GetFieldCaption(1294); }
        field(1295; Fld295; Text[250]) { CaptionClass = GetFieldCaption(1295); }
        field(1296; Fld296; Text[250]) { CaptionClass = GetFieldCaption(1296); }
        field(1297; Fld297; Text[250]) { CaptionClass = GetFieldCaption(1297); }
        field(1298; Fld298; Text[250]) { CaptionClass = GetFieldCaption(1298); }
        field(1299; Fld299; Text[250]) { CaptionClass = GetFieldCaption(1299); }
        field(1300; Fld300; Text[250]) { CaptionClass = GetFieldCaption(1300); }
    }


    keys
    {
        key(Key1; "Entry No.") { Clustered = true; }
    }

    procedure InitFirstLineAsCaptions(GenBuffTable_First: Record DMTGenBuffTable) NoOfCols: Integer
    var
        GenBuffTable_CaptionLine: Record DMTGenBuffTable;
        RecRef: RecordRef;
        FieldIndex: Integer;
    begin
        GenBuffTable_CaptionLine.SetRange(IsCaptionLine, true);
        GenBuffTable_CaptionLine.SetRange("Import from Filename", GenBuffTable_First."Import from Filename");
        if not GenBuffTable_CaptionLine.FindFirst() then
            Error('No caption line found for %1', GenBuffTable_First."Import from Filename");


        DMTGenBufferFieldCaptions.DisposeCaptions();
        RecRef.GetTable(GenBuffTable_CaptionLine);
        for FieldIndex := 1001 to (1001 + GenBuffTable_CaptionLine."Column Count") do begin
            DMTGenBufferFieldCaptions.AddCaption(FieldIndex, RecRef.Field(FieldIndex).Value);
        end;
        NoOfCols := DMTGenBufferFieldCaptions.GetNoOfCaptions();
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

    internal procedure LookUpFileNameFromGenBuffTable(CurrFileName: Text): Text
    var
        GenBuffTableQry: Query DMTGenBuffTableQry;
        Choice: Integer;
        FileList: List of [Text];
        Choices: Text;
        FileName: Text;
        GenBufferTableIsEmptyErr: Label 'the generic Buffer Table is empty', Comment = 'de-DE=Die generische Puffertabelle ist leer';
    begin
        GenBuffTableQry.Open();
        while GenBuffTableQry.Read() do begin
            FileList.Add(GenBuffTableQry.Import_from_Filename);
        end;
        if FileList.Count = 0 then
            Error(GenBufferTableIsEmptyErr);
        foreach FileName in FileList do
            Choices += ',' + FileName;
        Choices := Choices.TrimStart(',');
        Choice := StrMenu(Choices);
        if Choice = 0 then
            exit(CurrFileName)
        else
            exit(Choices.Split(',').Get(Choice));
    end;

    internal procedure GetColCaptionForImportedFile(ImportConfigHeader: Record DMTImportConfigHeader; var BuffTableCaptions: Dictionary of [Integer, Text]) OK: Boolean
    var
        GenBuffTable: Record DMTGenBuffTable;
        dataLayout: Record DMTDataLayout;
        RecRef: RecordRef;
        FieldIndex: Integer;
    begin
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
        if GenBuffTable.FindLast() then begin
            NextEntryNo += GenBuffTable."Entry No.";
        end;
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