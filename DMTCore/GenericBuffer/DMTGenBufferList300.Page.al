page 91004 DMTGenBufferList250
{
    Caption = 'DMT GenBufferList', Comment = 'de-DE=DMT Generischer Puffer Übersicht';
    PageType = List;
    SourceTable = DMTGenBuffTable;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.") { Visible = false; }
                field("Import from Filename"; Rec."Import from Filename") { }
                field(Imported; Rec.Imported) { }
                field("Blob Content Count"; Rec."No. of Blob Contents")
                {
                    trigger OnAssistEdit()
                    begin
                        Rec.LookUpBlobContent();
                    end;
                }
                field(F001; Rec.Fld001) { Visible = Fld001Visible; Editable = Fld001Editable; }
                field(F002; Rec.Fld002) { Visible = Fld002Visible; Editable = Fld002Editable; }
                field(F003; Rec.Fld003) { Visible = Fld003Visible; Editable = Fld003Editable; }
                field(F004; Rec.Fld004) { Visible = Fld004Visible; Editable = Fld004Editable; }
                field(F005; Rec.Fld005) { Visible = Fld005Visible; Editable = Fld005Editable; }
                field(F006; Rec.Fld006) { Visible = Fld006Visible; Editable = Fld006Editable; }
                field(F007; Rec.Fld007) { Visible = Fld007Visible; Editable = Fld007Editable; }
                field(F008; Rec.Fld008) { Visible = Fld008Visible; Editable = Fld008Editable; }
                field(F009; Rec.Fld009) { Visible = Fld009Visible; Editable = Fld009Editable; }
                field(F010; Rec.Fld010) { Visible = Fld010Visible; Editable = Fld010Editable; }
                field(F011; Rec.Fld011) { Visible = Fld011Visible; Editable = Fld011Editable; }
                field(F012; Rec.Fld012) { Visible = Fld012Visible; Editable = Fld012Editable; }
                field(F013; Rec.Fld013) { Visible = Fld013Visible; Editable = Fld013Editable; }
                field(F014; Rec.Fld014) { Visible = Fld014Visible; Editable = Fld014Editable; }
                field(F015; Rec.Fld015) { Visible = Fld015Visible; Editable = Fld015Editable; }
                field(F016; Rec.Fld016) { Visible = Fld016Visible; Editable = Fld016Editable; }
                field(F017; Rec.Fld017) { Visible = Fld017Visible; Editable = Fld017Editable; }
                field(F018; Rec.Fld018) { Visible = Fld018Visible; Editable = Fld018Editable; }
                field(F019; Rec.Fld019) { Visible = Fld019Visible; Editable = Fld019Editable; }
                field(F020; Rec.Fld020) { Visible = Fld020Visible; Editable = Fld020Editable; }
                field(F021; Rec.Fld021) { Visible = Fld021Visible; Editable = Fld021Editable; }
                field(F022; Rec.Fld022) { Visible = Fld022Visible; Editable = Fld022Editable; }
                field(F023; Rec.Fld023) { Visible = Fld023Visible; Editable = Fld023Editable; }
                field(F024; Rec.Fld024) { Visible = Fld024Visible; Editable = Fld024Editable; }
                field(F025; Rec.Fld025) { Visible = Fld025Visible; Editable = Fld025Editable; }
                field(F026; Rec.Fld026) { Visible = Fld026Visible; Editable = Fld026Editable; }
                field(F027; Rec.Fld027) { Visible = Fld027Visible; Editable = Fld027Editable; }
                field(F028; Rec.Fld028) { Visible = Fld028Visible; Editable = Fld028Editable; }
                field(F029; Rec.Fld029) { Visible = Fld029Visible; Editable = Fld029Editable; }
                field(F030; Rec.Fld030) { Visible = Fld030Visible; Editable = Fld030Editable; }
                field(F031; Rec.Fld031) { Visible = Fld031Visible; Editable = Fld031Editable; }
                field(F032; Rec.Fld032) { Visible = Fld032Visible; Editable = Fld032Editable; }
                field(F033; Rec.Fld033) { Visible = Fld033Visible; Editable = Fld033Editable; }
                field(F034; Rec.Fld034) { Visible = Fld034Visible; Editable = Fld034Editable; }
                field(F035; Rec.Fld035) { Visible = Fld035Visible; Editable = Fld035Editable; }
                field(F036; Rec.Fld036) { Visible = Fld036Visible; Editable = Fld036Editable; }
                field(F037; Rec.Fld037) { Visible = Fld037Visible; Editable = Fld037Editable; }
                field(F038; Rec.Fld038) { Visible = Fld038Visible; Editable = Fld038Editable; }
                field(F039; Rec.Fld039) { Visible = Fld039Visible; Editable = Fld039Editable; }
                field(F040; Rec.Fld040) { Visible = Fld040Visible; Editable = Fld040Editable; }
                field(F041; Rec.Fld041) { Visible = Fld041Visible; Editable = Fld041Editable; }
                field(F042; Rec.Fld042) { Visible = Fld042Visible; Editable = Fld042Editable; }
                field(F043; Rec.Fld043) { Visible = Fld043Visible; Editable = Fld043Editable; }
                field(F044; Rec.Fld044) { Visible = Fld044Visible; Editable = Fld044Editable; }
                field(F045; Rec.Fld045) { Visible = Fld045Visible; Editable = Fld045Editable; }
                field(F046; Rec.Fld046) { Visible = Fld046Visible; Editable = Fld046Editable; }
                field(F047; Rec.Fld047) { Visible = Fld047Visible; Editable = Fld047Editable; }
                field(F048; Rec.Fld048) { Visible = Fld048Visible; Editable = Fld048Editable; }
                field(F049; Rec.Fld049) { Visible = Fld049Visible; Editable = Fld049Editable; }
                field(F050; Rec.Fld050) { Visible = Fld050Visible; Editable = Fld050Editable; }
                field(F051; Rec.Fld051) { Visible = Fld051Visible; Editable = Fld051Editable; }
                field(F052; Rec.Fld052) { Visible = Fld052Visible; Editable = Fld052Editable; }
                field(F053; Rec.Fld053) { Visible = Fld053Visible; Editable = Fld053Editable; }
                field(F054; Rec.Fld054) { Visible = Fld054Visible; Editable = Fld054Editable; }
                field(F055; Rec.Fld055) { Visible = Fld055Visible; Editable = Fld055Editable; }
                field(F056; Rec.Fld056) { Visible = Fld056Visible; Editable = Fld056Editable; }
                field(F057; Rec.Fld057) { Visible = Fld057Visible; Editable = Fld057Editable; }
                field(F058; Rec.Fld058) { Visible = Fld058Visible; Editable = Fld058Editable; }
                field(F059; Rec.Fld059) { Visible = Fld059Visible; Editable = Fld059Editable; }
                field(F060; Rec.Fld060) { Visible = Fld060Visible; Editable = Fld060Editable; }
                field(F061; Rec.Fld061) { Visible = Fld061Visible; Editable = Fld061Editable; }
                field(F062; Rec.Fld062) { Visible = Fld062Visible; Editable = Fld062Editable; }
                field(F063; Rec.Fld063) { Visible = Fld063Visible; Editable = Fld063Editable; }
                field(F064; Rec.Fld064) { Visible = Fld064Visible; Editable = Fld064Editable; }
                field(F065; Rec.Fld065) { Visible = Fld065Visible; Editable = Fld065Editable; }
                field(F066; Rec.Fld066) { Visible = Fld066Visible; Editable = Fld066Editable; }
                field(F067; Rec.Fld067) { Visible = Fld067Visible; Editable = Fld067Editable; }
                field(F068; Rec.Fld068) { Visible = Fld068Visible; Editable = Fld068Editable; }
                field(F069; Rec.Fld069) { Visible = Fld069Visible; Editable = Fld069Editable; }
                field(F070; Rec.Fld070) { Visible = Fld070Visible; Editable = Fld070Editable; }
                field(F071; Rec.Fld071) { Visible = Fld071Visible; Editable = Fld071Editable; }
                field(F072; Rec.Fld072) { Visible = Fld072Visible; Editable = Fld072Editable; }
                field(F073; Rec.Fld073) { Visible = Fld073Visible; Editable = Fld073Editable; }
                field(F074; Rec.Fld074) { Visible = Fld074Visible; Editable = Fld074Editable; }
                field(F075; Rec.Fld075) { Visible = Fld075Visible; Editable = Fld075Editable; }
                field(F076; Rec.Fld076) { Visible = Fld076Visible; Editable = Fld076Editable; }
                field(F077; Rec.Fld077) { Visible = Fld077Visible; Editable = Fld077Editable; }
                field(F078; Rec.Fld078) { Visible = Fld078Visible; Editable = Fld078Editable; }
                field(F079; Rec.Fld079) { Visible = Fld079Visible; Editable = Fld079Editable; }
                field(F080; Rec.Fld080) { Visible = Fld080Visible; Editable = Fld080Editable; }
                field(F081; Rec.Fld081) { Visible = Fld081Visible; Editable = Fld081Editable; }
                field(F082; Rec.Fld082) { Visible = Fld082Visible; Editable = Fld082Editable; }
                field(F083; Rec.Fld083) { Visible = Fld083Visible; Editable = Fld083Editable; }
                field(F084; Rec.Fld084) { Visible = Fld084Visible; Editable = Fld084Editable; }
                field(F085; Rec.Fld085) { Visible = Fld085Visible; Editable = Fld085Editable; }
                field(F086; Rec.Fld086) { Visible = Fld086Visible; Editable = Fld086Editable; }
                field(F087; Rec.Fld087) { Visible = Fld087Visible; Editable = Fld087Editable; }
                field(F088; Rec.Fld088) { Visible = Fld088Visible; Editable = Fld088Editable; }
                field(F089; Rec.Fld089) { Visible = Fld089Visible; Editable = Fld089Editable; }
                field(F090; Rec.Fld090) { Visible = Fld090Visible; Editable = Fld090Editable; }
                field(F091; Rec.Fld091) { Visible = Fld091Visible; Editable = Fld091Editable; }
                field(F092; Rec.Fld092) { Visible = Fld092Visible; Editable = Fld092Editable; }
                field(F093; Rec.Fld093) { Visible = Fld093Visible; Editable = Fld093Editable; }
                field(F094; Rec.Fld094) { Visible = Fld094Visible; Editable = Fld094Editable; }
                field(F095; Rec.Fld095) { Visible = Fld095Visible; Editable = Fld095Editable; }
                field(F096; Rec.Fld096) { Visible = Fld096Visible; Editable = Fld096Editable; }
                field(F097; Rec.Fld097) { Visible = Fld097Visible; Editable = Fld097Editable; }
                field(F098; Rec.Fld098) { Visible = Fld098Visible; Editable = Fld098Editable; }
                field(F099; Rec.Fld099) { Visible = Fld099Visible; Editable = Fld099Editable; }
                field(F100; Rec.Fld100) { Visible = Fld100Visible; Editable = Fld100Editable; }
                field(F101; Rec.Fld101) { Visible = Fld101Visible; Editable = Fld101Editable; }
                field(F102; Rec.Fld102) { Visible = Fld102Visible; Editable = Fld102Editable; }
                field(F103; Rec.Fld103) { Visible = Fld103Visible; Editable = Fld103Editable; }
                field(F104; Rec.Fld104) { Visible = Fld104Visible; Editable = Fld104Editable; }
                field(F105; Rec.Fld105) { Visible = Fld105Visible; Editable = Fld105Editable; }
                field(F106; Rec.Fld106) { Visible = Fld106Visible; Editable = Fld106Editable; }
                field(F107; Rec.Fld107) { Visible = Fld107Visible; Editable = Fld107Editable; }
                field(F108; Rec.Fld108) { Visible = Fld108Visible; Editable = Fld108Editable; }
                field(F109; Rec.Fld109) { Visible = Fld109Visible; Editable = Fld109Editable; }
                field(F110; Rec.Fld110) { Visible = Fld110Visible; Editable = Fld110Editable; }
                field(F111; Rec.Fld111) { Visible = Fld111Visible; Editable = Fld111Editable; }
                field(F112; Rec.Fld112) { Visible = Fld112Visible; Editable = Fld112Editable; }
                field(F113; Rec.Fld113) { Visible = Fld113Visible; Editable = Fld113Editable; }
                field(F114; Rec.Fld114) { Visible = Fld114Visible; Editable = Fld114Editable; }
                field(F115; Rec.Fld115) { Visible = Fld115Visible; Editable = Fld115Editable; }
                field(F116; Rec.Fld116) { Visible = Fld116Visible; Editable = Fld116Editable; }
                field(F117; Rec.Fld117) { Visible = Fld117Visible; Editable = Fld117Editable; }
                field(F118; Rec.Fld118) { Visible = Fld118Visible; Editable = Fld118Editable; }
                field(F119; Rec.Fld119) { Visible = Fld119Visible; Editable = Fld119Editable; }
                field(F120; Rec.Fld120) { Visible = Fld120Visible; Editable = Fld120Editable; }
                field(F121; Rec.Fld121) { Visible = Fld121Visible; Editable = Fld121Editable; }
                field(F122; Rec.Fld122) { Visible = Fld122Visible; Editable = Fld122Editable; }
                field(F123; Rec.Fld123) { Visible = Fld123Visible; Editable = Fld123Editable; }
                field(F124; Rec.Fld124) { Visible = Fld124Visible; Editable = Fld124Editable; }
                field(F125; Rec.Fld125) { Visible = Fld125Visible; Editable = Fld125Editable; }
                field(F126; Rec.Fld126) { Visible = Fld126Visible; Editable = Fld126Editable; }
                field(F127; Rec.Fld127) { Visible = Fld127Visible; Editable = Fld127Editable; }
                field(F128; Rec.Fld128) { Visible = Fld128Visible; Editable = Fld128Editable; }
                field(F129; Rec.Fld129) { Visible = Fld129Visible; Editable = Fld129Editable; }
                field(F130; Rec.Fld130) { Visible = Fld130Visible; Editable = Fld130Editable; }
                field(F131; Rec.Fld131) { Visible = Fld131Visible; Editable = Fld131Editable; }
                field(F132; Rec.Fld132) { Visible = Fld132Visible; Editable = Fld132Editable; }
                field(F133; Rec.Fld133) { Visible = Fld133Visible; Editable = Fld133Editable; }
                field(F134; Rec.Fld134) { Visible = Fld134Visible; Editable = Fld134Editable; }
                field(F135; Rec.Fld135) { Visible = Fld135Visible; Editable = Fld135Editable; }
                field(F136; Rec.Fld136) { Visible = Fld136Visible; Editable = Fld136Editable; }
                field(F137; Rec.Fld137) { Visible = Fld137Visible; Editable = Fld137Editable; }
                field(F138; Rec.Fld138) { Visible = Fld138Visible; Editable = Fld138Editable; }
                field(F139; Rec.Fld139) { Visible = Fld139Visible; Editable = Fld139Editable; }
                field(F140; Rec.Fld140) { Visible = Fld140Visible; Editable = Fld140Editable; }
                field(F141; Rec.Fld141) { Visible = Fld141Visible; Editable = Fld141Editable; }
                field(F142; Rec.Fld142) { Visible = Fld142Visible; Editable = Fld142Editable; }
                field(F143; Rec.Fld143) { Visible = Fld143Visible; Editable = Fld143Editable; }
                field(F144; Rec.Fld144) { Visible = Fld144Visible; Editable = Fld144Editable; }
                field(F145; Rec.Fld145) { Visible = Fld145Visible; Editable = Fld145Editable; }
                field(F146; Rec.Fld146) { Visible = Fld146Visible; Editable = Fld146Editable; }
                field(F147; Rec.Fld147) { Visible = Fld147Visible; Editable = Fld147Editable; }
                field(F148; Rec.Fld148) { Visible = Fld148Visible; Editable = Fld148Editable; }
                field(F149; Rec.Fld149) { Visible = Fld149Visible; Editable = Fld149Editable; }
                field(F150; Rec.Fld150) { Visible = Fld150Visible; Editable = Fld150Editable; }
                field(F151; Rec.Fld151) { Visible = Fld151Visible; Editable = Fld151Editable; }
                field(F152; Rec.Fld152) { Visible = Fld152Visible; Editable = Fld152Editable; }
                field(F153; Rec.Fld153) { Visible = Fld153Visible; Editable = Fld153Editable; }
                field(F154; Rec.Fld154) { Visible = Fld154Visible; Editable = Fld154Editable; }
                field(F155; Rec.Fld155) { Visible = Fld155Visible; Editable = Fld155Editable; }
                field(F156; Rec.Fld156) { Visible = Fld156Visible; Editable = Fld156Editable; }
                field(F157; Rec.Fld157) { Visible = Fld157Visible; Editable = Fld157Editable; }
                field(F158; Rec.Fld158) { Visible = Fld158Visible; Editable = Fld158Editable; }
                field(F159; Rec.Fld159) { Visible = Fld159Visible; Editable = Fld159Editable; }
                field(F160; Rec.Fld160) { Visible = Fld160Visible; Editable = Fld160Editable; }
                field(F161; Rec.Fld161) { Visible = Fld161Visible; Editable = Fld161Editable; }
                field(F162; Rec.Fld162) { Visible = Fld162Visible; Editable = Fld162Editable; }
                field(F163; Rec.Fld163) { Visible = Fld163Visible; Editable = Fld163Editable; }
                field(F164; Rec.Fld164) { Visible = Fld164Visible; Editable = Fld164Editable; }
                field(F165; Rec.Fld165) { Visible = Fld165Visible; Editable = Fld165Editable; }
                field(F166; Rec.Fld166) { Visible = Fld166Visible; Editable = Fld166Editable; }
                field(F167; Rec.Fld167) { Visible = Fld167Visible; Editable = Fld167Editable; }
                field(F168; Rec.Fld168) { Visible = Fld168Visible; Editable = Fld168Editable; }
                field(F169; Rec.Fld169) { Visible = Fld169Visible; Editable = Fld169Editable; }
                field(F170; Rec.Fld170) { Visible = Fld170Visible; Editable = Fld170Editable; }
                field(F171; Rec.Fld171) { Visible = Fld171Visible; Editable = Fld171Editable; }
                field(F172; Rec.Fld172) { Visible = Fld172Visible; Editable = Fld172Editable; }
                field(F173; Rec.Fld173) { Visible = Fld173Visible; Editable = Fld173Editable; }
                field(F174; Rec.Fld174) { Visible = Fld174Visible; Editable = Fld174Editable; }
                field(F175; Rec.Fld175) { Visible = Fld175Visible; Editable = Fld175Editable; }
                field(F176; Rec.Fld176) { Visible = Fld176Visible; Editable = Fld176Editable; }
                field(F177; Rec.Fld177) { Visible = Fld177Visible; Editable = Fld177Editable; }
                field(F178; Rec.Fld178) { Visible = Fld178Visible; Editable = Fld178Editable; }
                field(F179; Rec.Fld179) { Visible = Fld179Visible; Editable = Fld179Editable; }
                field(F180; Rec.Fld180) { Visible = Fld180Visible; Editable = Fld180Editable; }
                field(F181; Rec.Fld181) { Visible = Fld181Visible; Editable = Fld181Editable; }
                field(F182; Rec.Fld182) { Visible = Fld182Visible; Editable = Fld182Editable; }
                field(F183; Rec.Fld183) { Visible = Fld183Visible; Editable = Fld183Editable; }
                field(F184; Rec.Fld184) { Visible = Fld184Visible; Editable = Fld184Editable; }
                field(F185; Rec.Fld185) { Visible = Fld185Visible; Editable = Fld185Editable; }
                field(F186; Rec.Fld186) { Visible = Fld186Visible; Editable = Fld186Editable; }
                field(F187; Rec.Fld187) { Visible = Fld187Visible; Editable = Fld187Editable; }
                field(F188; Rec.Fld188) { Visible = Fld188Visible; Editable = Fld188Editable; }
                field(F189; Rec.Fld189) { Visible = Fld189Visible; Editable = Fld189Editable; }
                field(F190; Rec.Fld190) { Visible = Fld190Visible; Editable = Fld190Editable; }
                field(F191; Rec.Fld191) { Visible = Fld191Visible; Editable = Fld191Editable; }
                field(F192; Rec.Fld192) { Visible = Fld192Visible; Editable = Fld192Editable; }
                field(F193; Rec.Fld193) { Visible = Fld193Visible; Editable = Fld193Editable; }
                field(F194; Rec.Fld194) { Visible = Fld194Visible; Editable = Fld194Editable; }
                field(F195; Rec.Fld195) { Visible = Fld195Visible; Editable = Fld195Editable; }
                field(F196; Rec.Fld196) { Visible = Fld196Visible; Editable = Fld196Editable; }
                field(F197; Rec.Fld197) { Visible = Fld197Visible; Editable = Fld197Editable; }
                field(F198; Rec.Fld198) { Visible = Fld198Visible; Editable = Fld198Editable; }
                field(F199; Rec.Fld199) { Visible = Fld199Visible; Editable = Fld199Editable; }
                field(F200; Rec.Fld200) { Visible = Fld200Visible; Editable = Fld200Editable; }
                field(F201; Rec.Fld200) { Visible = Fld201Visible; Editable = Fld201Editable; }
                field(F202; Rec.Fld200) { Visible = Fld202Visible; Editable = Fld202Editable; }
                field(F203; Rec.Fld200) { Visible = Fld203Visible; Editable = Fld203Editable; }
                field(F204; Rec.Fld200) { Visible = Fld204Visible; Editable = Fld204Editable; }
                field(F205; Rec.Fld200) { Visible = Fld205Visible; Editable = Fld205Editable; }
                field(F206; Rec.Fld206) { Visible = Fld206Visible; Editable = Fld206Editable; }
                field(F207; Rec.Fld207) { Visible = Fld207Visible; Editable = Fld207Editable; }
                field(F208; Rec.Fld208) { Visible = Fld208Visible; Editable = Fld208Editable; }
                field(F209; Rec.Fld209) { Visible = Fld209Visible; Editable = Fld209Editable; }
                field(F210; Rec.Fld210) { Visible = Fld210Visible; Editable = Fld210Editable; }
                field(F211; Rec.Fld211) { Visible = Fld211Visible; Editable = Fld211Editable; }
                field(F212; Rec.Fld212) { Visible = Fld212Visible; Editable = Fld212Editable; }
                field(F213; Rec.Fld213) { Visible = Fld213Visible; Editable = Fld213Editable; }
                field(F214; Rec.Fld214) { Visible = Fld214Visible; Editable = Fld214Editable; }
                field(F215; Rec.Fld215) { Visible = Fld215Visible; Editable = Fld215Editable; }
                field(F216; Rec.Fld216) { Visible = Fld216Visible; Editable = Fld216Editable; }
                field(F217; Rec.Fld217) { Visible = Fld217Visible; Editable = Fld217Editable; }
                field(F218; Rec.Fld218) { Visible = Fld218Visible; Editable = Fld218Editable; }
                field(F219; Rec.Fld219) { Visible = Fld219Visible; Editable = Fld219Editable; }
                field(F220; Rec.Fld220) { Visible = Fld220Visible; Editable = Fld220Editable; }
                field(F221; Rec.Fld221) { Visible = Fld221Visible; Editable = Fld221Editable; }
                field(F222; Rec.Fld222) { Visible = Fld222Visible; Editable = Fld222Editable; }
                field(F223; Rec.Fld223) { Visible = Fld223Visible; Editable = Fld223Editable; }
                field(F224; Rec.Fld224) { Visible = Fld224Visible; Editable = Fld224Editable; }
                field(F225; Rec.Fld225) { Visible = Fld225Visible; Editable = Fld225Editable; }
                field(F226; Rec.Fld226) { Visible = Fld226Visible; Editable = Fld226Editable; }
                field(F227; Rec.Fld227) { Visible = Fld227Visible; Editable = Fld227Editable; }
                field(F228; Rec.Fld228) { Visible = Fld228Visible; Editable = Fld228Editable; }
                field(F229; Rec.Fld229) { Visible = Fld229Visible; Editable = Fld229Editable; }
                field(F230; Rec.Fld230) { Visible = Fld230Visible; Editable = Fld230Editable; }
                field(F231; Rec.Fld231) { Visible = Fld231Visible; Editable = Fld231Editable; }
                field(F232; Rec.Fld232) { Visible = Fld232Visible; Editable = Fld232Editable; }
                field(F233; Rec.Fld233) { Visible = Fld233Visible; Editable = Fld233Editable; }
                field(F234; Rec.Fld234) { Visible = Fld234Visible; Editable = Fld234Editable; }
                field(F235; Rec.Fld235) { Visible = Fld235Visible; Editable = Fld235Editable; }
                field(F236; Rec.Fld236) { Visible = Fld236Visible; Editable = Fld236Editable; }
                field(F237; Rec.Fld237) { Visible = Fld237Visible; Editable = Fld237Editable; }
                field(F238; Rec.Fld238) { Visible = Fld238Visible; Editable = Fld238Editable; }
                field(F239; Rec.Fld239) { Visible = Fld239Visible; Editable = Fld239Editable; }
                field(F240; Rec.Fld240) { Visible = Fld240Visible; Editable = Fld240Editable; }
                field(F241; Rec.Fld241) { Visible = Fld241Visible; Editable = Fld241Editable; }
                field(F242; Rec.Fld242) { Visible = Fld242Visible; Editable = Fld242Editable; }
                field(F243; Rec.Fld243) { Visible = Fld243Visible; Editable = Fld243Editable; }
                field(F244; Rec.Fld244) { Visible = Fld244Visible; Editable = Fld244Editable; }
                field(F245; Rec.Fld245) { Visible = Fld245Visible; Editable = Fld245Editable; }
                field(F246; Rec.Fld246) { Visible = Fld246Visible; Editable = Fld246Editable; }
                field(F247; Rec.Fld247) { Visible = Fld247Visible; Editable = Fld247Editable; }
                field(F248; Rec.Fld248) { Visible = Fld248Visible; Editable = Fld248Editable; }
                field(F249; Rec.Fld249) { Visible = Fld249Visible; Editable = Fld249Editable; }
                field(F250; Rec.Fld250) { Visible = Fld250Visible; Editable = Fld250Editable; }
                field(F251; Rec.Fld251) { Visible = Fld251Visible; Editable = Fld251Editable; }
                field(F252; Rec.Fld252) { Visible = Fld252Visible; Editable = Fld252Editable; }
                field(F253; Rec.Fld253) { Visible = Fld253Visible; Editable = Fld253Editable; }
                field(F254; Rec.Fld254) { Visible = Fld254Visible; Editable = Fld254Editable; }
                field(F255; Rec.Fld255) { Visible = Fld255Visible; Editable = Fld255Editable; }
                field(F256; Rec.Fld256) { Visible = Fld256Visible; Editable = Fld256Editable; }
                field(F257; Rec.Fld257) { Visible = Fld257Visible; Editable = Fld257Editable; }
                field(F258; Rec.Fld258) { Visible = Fld258Visible; Editable = Fld258Editable; }
                field(F259; Rec.Fld259) { Visible = Fld259Visible; Editable = Fld259Editable; }
                field(F260; Rec.Fld260) { Visible = Fld260Visible; Editable = Fld260Editable; }
                field(F261; Rec.Fld261) { Visible = Fld261Visible; Editable = Fld261Editable; }
                field(F262; Rec.Fld262) { Visible = Fld262Visible; Editable = Fld262Editable; }
                field(F263; Rec.Fld263) { Visible = Fld263Visible; Editable = Fld263Editable; }
                field(F264; Rec.Fld264) { Visible = Fld264Visible; Editable = Fld264Editable; }
                field(F265; Rec.Fld265) { Visible = Fld265Visible; Editable = Fld265Editable; }
                field(F266; Rec.Fld266) { Visible = Fld266Visible; Editable = Fld266Editable; }
                field(F267; Rec.Fld267) { Visible = Fld267Visible; Editable = Fld267Editable; }
                field(F268; Rec.Fld268) { Visible = Fld268Visible; Editable = Fld268Editable; }
                field(F269; Rec.Fld269) { Visible = Fld269Visible; Editable = Fld269Editable; }
                field(F270; Rec.Fld270) { Visible = Fld270Visible; Editable = Fld270Editable; }
                field(F271; Rec.Fld271) { Visible = Fld271Visible; Editable = Fld271Editable; }
                field(F272; Rec.Fld272) { Visible = Fld272Visible; Editable = Fld272Editable; }
                field(F273; Rec.Fld273) { Visible = Fld273Visible; Editable = Fld273Editable; }
                field(F274; Rec.Fld274) { Visible = Fld274Visible; Editable = Fld274Editable; }
                field(F275; Rec.Fld275) { Visible = Fld275Visible; Editable = Fld275Editable; }
                field(F276; Rec.Fld276) { Visible = Fld276Visible; Editable = Fld276Editable; }
                field(F277; Rec.Fld277) { Visible = Fld277Visible; Editable = Fld277Editable; }
                field(F278; Rec.Fld278) { Visible = Fld278Visible; Editable = Fld278Editable; }
                field(F279; Rec.Fld279) { Visible = Fld279Visible; Editable = Fld279Editable; }
                field(F280; Rec.Fld280) { Visible = Fld280Visible; Editable = Fld280Editable; }
                field(F281; Rec.Fld281) { Visible = Fld281Visible; Editable = Fld281Editable; }
                field(F282; Rec.Fld282) { Visible = Fld282Visible; Editable = Fld282Editable; }
                field(F283; Rec.Fld283) { Visible = Fld283Visible; Editable = Fld283Editable; }
                field(F284; Rec.Fld284) { Visible = Fld284Visible; Editable = Fld284Editable; }
                field(F285; Rec.Fld285) { Visible = Fld285Visible; Editable = Fld285Editable; }
                field(F286; Rec.Fld286) { Visible = Fld286Visible; Editable = Fld286Editable; }
                field(F287; Rec.Fld287) { Visible = Fld287Visible; Editable = Fld287Editable; }
                field(F288; Rec.Fld288) { Visible = Fld288Visible; Editable = Fld288Editable; }
                field(F289; Rec.Fld289) { Visible = Fld289Visible; Editable = Fld289Editable; }
                field(F290; Rec.Fld290) { Visible = Fld290Visible; Editable = Fld290Editable; }
                field(F291; Rec.Fld291) { Visible = Fld291Visible; Editable = Fld291Editable; }
                field(F292; Rec.Fld292) { Visible = Fld292Visible; Editable = Fld292Editable; }
                field(F293; Rec.Fld293) { Visible = Fld293Visible; Editable = Fld293Editable; }
                field(F294; Rec.Fld294) { Visible = Fld294Visible; Editable = Fld294Editable; }
                field(F295; Rec.Fld295) { Visible = Fld295Visible; Editable = Fld295Editable; }
                field(F296; Rec.Fld296) { Visible = Fld296Visible; Editable = Fld296Editable; }
                field(F297; Rec.Fld297) { Visible = Fld297Visible; Editable = Fld297Editable; }
                field(F298; Rec.Fld298) { Visible = Fld298Visible; Editable = Fld298Editable; }
                field(F299; Rec.Fld299) { Visible = Fld299Visible; Editable = Fld299Editable; }
                field(F300; Rec.Fld300) { Visible = Fld300Visible; Editable = Fld300Editable; }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Fld001Editable := Fld001Editable;
    end;

    trigger OnOpenPage()
    begin
        InitVisibility();
        InitEditable();
    end;

    local procedure InitEditable()
    begin
        Fld001Editable := GetEditable(Rec.FieldNo(Fld001));
        Fld002Editable := GetEditable(Rec.FieldNo(Fld002));
        Fld003Editable := GetEditable(Rec.FieldNo(Fld003));
        Fld004Editable := GetEditable(Rec.FieldNo(Fld004));
        Fld005Editable := GetEditable(Rec.FieldNo(Fld005));
        Fld006Editable := GetEditable(Rec.FieldNo(Fld006));
        Fld007Editable := GetEditable(Rec.FieldNo(Fld007));
        Fld008Editable := GetEditable(Rec.FieldNo(Fld008));
        Fld009Editable := GetEditable(Rec.FieldNo(Fld009));
        Fld010Editable := GetEditable(Rec.FieldNo(Fld010));
        Fld011Editable := GetEditable(Rec.FieldNo(Fld011));
        Fld012Editable := GetEditable(Rec.FieldNo(Fld012));
        Fld013Editable := GetEditable(Rec.FieldNo(Fld013));
        Fld014Editable := GetEditable(Rec.FieldNo(Fld014));
        Fld015Editable := GetEditable(Rec.FieldNo(Fld015));
        Fld016Editable := GetEditable(Rec.FieldNo(Fld016));
        Fld017Editable := GetEditable(Rec.FieldNo(Fld017));
        Fld018Editable := GetEditable(Rec.FieldNo(Fld018));
        Fld019Editable := GetEditable(Rec.FieldNo(Fld019));
        Fld020Editable := GetEditable(Rec.FieldNo(Fld020));
        Fld021Editable := GetEditable(Rec.FieldNo(Fld021));
        Fld022Editable := GetEditable(Rec.FieldNo(Fld022));
        Fld023Editable := GetEditable(Rec.FieldNo(Fld023));
        Fld024Editable := GetEditable(Rec.FieldNo(Fld024));
        Fld025Editable := GetEditable(Rec.FieldNo(Fld025));
        Fld026Editable := GetEditable(Rec.FieldNo(Fld026));
        Fld027Editable := GetEditable(Rec.FieldNo(Fld027));
        Fld028Editable := GetEditable(Rec.FieldNo(Fld028));
        Fld029Editable := GetEditable(Rec.FieldNo(Fld029));
        Fld030Editable := GetEditable(Rec.FieldNo(Fld030));
        Fld031Editable := GetEditable(Rec.FieldNo(Fld031));
        Fld032Editable := GetEditable(Rec.FieldNo(Fld032));
        Fld033Editable := GetEditable(Rec.FieldNo(Fld033));
        Fld034Editable := GetEditable(Rec.FieldNo(Fld034));
        Fld035Editable := GetEditable(Rec.FieldNo(Fld035));
        Fld036Editable := GetEditable(Rec.FieldNo(Fld036));
        Fld037Editable := GetEditable(Rec.FieldNo(Fld037));
        Fld038Editable := GetEditable(Rec.FieldNo(Fld038));
        Fld039Editable := GetEditable(Rec.FieldNo(Fld039));
        Fld040Editable := GetEditable(Rec.FieldNo(Fld040));
        Fld041Editable := GetEditable(Rec.FieldNo(Fld041));
        Fld042Editable := GetEditable(Rec.FieldNo(Fld042));
        Fld043Editable := GetEditable(Rec.FieldNo(Fld043));
        Fld044Editable := GetEditable(Rec.FieldNo(Fld044));
        Fld045Editable := GetEditable(Rec.FieldNo(Fld045));
        Fld046Editable := GetEditable(Rec.FieldNo(Fld046));
        Fld047Editable := GetEditable(Rec.FieldNo(Fld047));
        Fld048Editable := GetEditable(Rec.FieldNo(Fld048));
        Fld049Editable := GetEditable(Rec.FieldNo(Fld049));
        Fld050Editable := GetEditable(Rec.FieldNo(Fld050));
        Fld051Editable := GetEditable(Rec.FieldNo(Fld051));
        Fld052Editable := GetEditable(Rec.FieldNo(Fld052));
        Fld053Editable := GetEditable(Rec.FieldNo(Fld053));
        Fld054Editable := GetEditable(Rec.FieldNo(Fld054));
        Fld055Editable := GetEditable(Rec.FieldNo(Fld055));
        Fld056Editable := GetEditable(Rec.FieldNo(Fld056));
        Fld057Editable := GetEditable(Rec.FieldNo(Fld057));
        Fld058Editable := GetEditable(Rec.FieldNo(Fld058));
        Fld059Editable := GetEditable(Rec.FieldNo(Fld059));
        Fld060Editable := GetEditable(Rec.FieldNo(Fld060));
        Fld061Editable := GetEditable(Rec.FieldNo(Fld061));
        Fld062Editable := GetEditable(Rec.FieldNo(Fld062));
        Fld063Editable := GetEditable(Rec.FieldNo(Fld063));
        Fld064Editable := GetEditable(Rec.FieldNo(Fld064));
        Fld065Editable := GetEditable(Rec.FieldNo(Fld065));
        Fld066Editable := GetEditable(Rec.FieldNo(Fld066));
        Fld067Editable := GetEditable(Rec.FieldNo(Fld067));
        Fld068Editable := GetEditable(Rec.FieldNo(Fld068));
        Fld069Editable := GetEditable(Rec.FieldNo(Fld069));
        Fld070Editable := GetEditable(Rec.FieldNo(Fld070));
        Fld071Editable := GetEditable(Rec.FieldNo(Fld071));
        Fld072Editable := GetEditable(Rec.FieldNo(Fld072));
        Fld073Editable := GetEditable(Rec.FieldNo(Fld073));
        Fld074Editable := GetEditable(Rec.FieldNo(Fld074));
        Fld075Editable := GetEditable(Rec.FieldNo(Fld075));
        Fld076Editable := GetEditable(Rec.FieldNo(Fld076));
        Fld077Editable := GetEditable(Rec.FieldNo(Fld077));
        Fld078Editable := GetEditable(Rec.FieldNo(Fld078));
        Fld079Editable := GetEditable(Rec.FieldNo(Fld079));
        Fld080Editable := GetEditable(Rec.FieldNo(Fld080));
        Fld081Editable := GetEditable(Rec.FieldNo(Fld081));
        Fld082Editable := GetEditable(Rec.FieldNo(Fld082));
        Fld083Editable := GetEditable(Rec.FieldNo(Fld083));
        Fld084Editable := GetEditable(Rec.FieldNo(Fld084));
        Fld085Editable := GetEditable(Rec.FieldNo(Fld085));
        Fld086Editable := GetEditable(Rec.FieldNo(Fld086));
        Fld087Editable := GetEditable(Rec.FieldNo(Fld087));
        Fld088Editable := GetEditable(Rec.FieldNo(Fld088));
        Fld089Editable := GetEditable(Rec.FieldNo(Fld089));
        Fld090Editable := GetEditable(Rec.FieldNo(Fld090));
        Fld091Editable := GetEditable(Rec.FieldNo(Fld091));
        Fld092Editable := GetEditable(Rec.FieldNo(Fld092));
        Fld093Editable := GetEditable(Rec.FieldNo(Fld093));
        Fld094Editable := GetEditable(Rec.FieldNo(Fld094));
        Fld095Editable := GetEditable(Rec.FieldNo(Fld095));
        Fld096Editable := GetEditable(Rec.FieldNo(Fld096));
        Fld097Editable := GetEditable(Rec.FieldNo(Fld097));
        Fld098Editable := GetEditable(Rec.FieldNo(Fld098));
        Fld099Editable := GetEditable(Rec.FieldNo(Fld099));
        Fld100Editable := GetEditable(Rec.FieldNo(Fld100));
        Fld101Editable := GetEditable(Rec.FieldNo(Fld101));
        Fld102Editable := GetEditable(Rec.FieldNo(Fld102));
        Fld103Editable := GetEditable(Rec.FieldNo(Fld103));
        Fld104Editable := GetEditable(Rec.FieldNo(Fld104));
        Fld105Editable := GetEditable(Rec.FieldNo(Fld105));
        Fld106Editable := GetEditable(Rec.FieldNo(Fld106));
        Fld107Editable := GetEditable(Rec.FieldNo(Fld107));
        Fld108Editable := GetEditable(Rec.FieldNo(Fld108));
        Fld109Editable := GetEditable(Rec.FieldNo(Fld109));
        Fld110Editable := GetEditable(Rec.FieldNo(Fld110));
        Fld111Editable := GetEditable(Rec.FieldNo(Fld111));
        Fld112Editable := GetEditable(Rec.FieldNo(Fld112));
        Fld113Editable := GetEditable(Rec.FieldNo(Fld113));
        Fld114Editable := GetEditable(Rec.FieldNo(Fld114));
        Fld115Editable := GetEditable(Rec.FieldNo(Fld115));
        Fld116Editable := GetEditable(Rec.FieldNo(Fld116));
        Fld117Editable := GetEditable(Rec.FieldNo(Fld117));
        Fld118Editable := GetEditable(Rec.FieldNo(Fld118));
        Fld119Editable := GetEditable(Rec.FieldNo(Fld119));
        Fld120Editable := GetEditable(Rec.FieldNo(Fld120));
        Fld121Editable := GetEditable(Rec.FieldNo(Fld121));
        Fld122Editable := GetEditable(Rec.FieldNo(Fld122));
        Fld123Editable := GetEditable(Rec.FieldNo(Fld123));
        Fld124Editable := GetEditable(Rec.FieldNo(Fld124));
        Fld125Editable := GetEditable(Rec.FieldNo(Fld125));
        Fld126Editable := GetEditable(Rec.FieldNo(Fld126));
        Fld127Editable := GetEditable(Rec.FieldNo(Fld127));
        Fld128Editable := GetEditable(Rec.FieldNo(Fld128));
        Fld129Editable := GetEditable(Rec.FieldNo(Fld129));
        Fld130Editable := GetEditable(Rec.FieldNo(Fld130));
        Fld131Editable := GetEditable(Rec.FieldNo(Fld131));
        Fld132Editable := GetEditable(Rec.FieldNo(Fld132));
        Fld133Editable := GetEditable(Rec.FieldNo(Fld133));
        Fld134Editable := GetEditable(Rec.FieldNo(Fld134));
        Fld135Editable := GetEditable(Rec.FieldNo(Fld135));
        Fld136Editable := GetEditable(Rec.FieldNo(Fld136));
        Fld137Editable := GetEditable(Rec.FieldNo(Fld137));
        Fld138Editable := GetEditable(Rec.FieldNo(Fld138));
        Fld139Editable := GetEditable(Rec.FieldNo(Fld139));
        Fld140Editable := GetEditable(Rec.FieldNo(Fld140));
        Fld141Editable := GetEditable(Rec.FieldNo(Fld141));
        Fld142Editable := GetEditable(Rec.FieldNo(Fld142));
        Fld143Editable := GetEditable(Rec.FieldNo(Fld143));
        Fld144Editable := GetEditable(Rec.FieldNo(Fld144));
        Fld145Editable := GetEditable(Rec.FieldNo(Fld145));
        Fld146Editable := GetEditable(Rec.FieldNo(Fld146));
        Fld147Editable := GetEditable(Rec.FieldNo(Fld147));
        Fld148Editable := GetEditable(Rec.FieldNo(Fld148));
        Fld149Editable := GetEditable(Rec.FieldNo(Fld149));
        Fld150Editable := GetEditable(Rec.FieldNo(Fld150));
        Fld151Editable := GetEditable(Rec.FieldNo(Fld151));
        Fld152Editable := GetEditable(Rec.FieldNo(Fld152));
        Fld153Editable := GetEditable(Rec.FieldNo(Fld153));
        Fld154Editable := GetEditable(Rec.FieldNo(Fld154));
        Fld155Editable := GetEditable(Rec.FieldNo(Fld155));
        Fld156Editable := GetEditable(Rec.FieldNo(Fld156));
        Fld157Editable := GetEditable(Rec.FieldNo(Fld157));
        Fld158Editable := GetEditable(Rec.FieldNo(Fld158));
        Fld159Editable := GetEditable(Rec.FieldNo(Fld159));
        Fld160Editable := GetEditable(Rec.FieldNo(Fld160));
        Fld161Editable := GetEditable(Rec.FieldNo(Fld161));
        Fld162Editable := GetEditable(Rec.FieldNo(Fld162));
        Fld163Editable := GetEditable(Rec.FieldNo(Fld163));
        Fld164Editable := GetEditable(Rec.FieldNo(Fld164));
        Fld165Editable := GetEditable(Rec.FieldNo(Fld165));
        Fld166Editable := GetEditable(Rec.FieldNo(Fld166));
        Fld167Editable := GetEditable(Rec.FieldNo(Fld167));
        Fld168Editable := GetEditable(Rec.FieldNo(Fld168));
        Fld169Editable := GetEditable(Rec.FieldNo(Fld169));
        Fld170Editable := GetEditable(Rec.FieldNo(Fld170));
        Fld171Editable := GetEditable(Rec.FieldNo(Fld171));
        Fld172Editable := GetEditable(Rec.FieldNo(Fld172));
        Fld173Editable := GetEditable(Rec.FieldNo(Fld173));
        Fld174Editable := GetEditable(Rec.FieldNo(Fld174));
        Fld175Editable := GetEditable(Rec.FieldNo(Fld175));
        Fld176Editable := GetEditable(Rec.FieldNo(Fld176));
        Fld177Editable := GetEditable(Rec.FieldNo(Fld177));
        Fld178Editable := GetEditable(Rec.FieldNo(Fld178));
        Fld179Editable := GetEditable(Rec.FieldNo(Fld179));
        Fld180Editable := GetEditable(Rec.FieldNo(Fld180));
        Fld181Editable := GetEditable(Rec.FieldNo(Fld181));
        Fld182Editable := GetEditable(Rec.FieldNo(Fld182));
        Fld183Editable := GetEditable(Rec.FieldNo(Fld183));
        Fld184Editable := GetEditable(Rec.FieldNo(Fld184));
        Fld185Editable := GetEditable(Rec.FieldNo(Fld185));
        Fld186Editable := GetEditable(Rec.FieldNo(Fld186));
        Fld187Editable := GetEditable(Rec.FieldNo(Fld187));
        Fld188Editable := GetEditable(Rec.FieldNo(Fld188));
        Fld189Editable := GetEditable(Rec.FieldNo(Fld189));
        Fld190Editable := GetEditable(Rec.FieldNo(Fld190));
        Fld191Editable := GetEditable(Rec.FieldNo(Fld191));
        Fld192Editable := GetEditable(Rec.FieldNo(Fld192));
        Fld193Editable := GetEditable(Rec.FieldNo(Fld193));
        Fld194Editable := GetEditable(Rec.FieldNo(Fld194));
        Fld195Editable := GetEditable(Rec.FieldNo(Fld195));
        Fld196Editable := GetEditable(Rec.FieldNo(Fld196));
        Fld197Editable := GetEditable(Rec.FieldNo(Fld197));
        Fld198Editable := GetEditable(Rec.FieldNo(Fld198));
        Fld199Editable := GetEditable(Rec.FieldNo(Fld199));
        Fld200Editable := GetEditable(Rec.FieldNo(Fld200));
        Fld201Editable := GetEditable(Rec.FieldNo(Fld201));
        Fld202Editable := GetEditable(Rec.FieldNo(Fld202));
        Fld203Editable := GetEditable(Rec.FieldNo(Fld203));
        Fld204Editable := GetEditable(Rec.FieldNo(Fld204));
        Fld205Editable := GetEditable(Rec.FieldNo(Fld205));
        Fld206Editable := GetEditable(Rec.FieldNo(Fld206));
        Fld207Editable := GetEditable(Rec.FieldNo(Fld207));
        Fld208Editable := GetEditable(Rec.FieldNo(Fld208));
        Fld209Editable := GetEditable(Rec.FieldNo(Fld209));
        Fld210Editable := GetEditable(Rec.FieldNo(Fld210));
        Fld211Editable := GetEditable(Rec.FieldNo(Fld211));
        Fld212Editable := GetEditable(Rec.FieldNo(Fld212));
        Fld213Editable := GetEditable(Rec.FieldNo(Fld213));
        Fld214Editable := GetEditable(Rec.FieldNo(Fld214));
        Fld215Editable := GetEditable(Rec.FieldNo(Fld215));
        Fld216Editable := GetEditable(Rec.FieldNo(Fld216));
        Fld217Editable := GetEditable(Rec.FieldNo(Fld217));
        Fld218Editable := GetEditable(Rec.FieldNo(Fld218));
        Fld219Editable := GetEditable(Rec.FieldNo(Fld219));
        Fld220Editable := GetEditable(Rec.FieldNo(Fld220));
        Fld221Editable := GetEditable(Rec.FieldNo(Fld221));
        Fld222Editable := GetEditable(Rec.FieldNo(Fld222));
        Fld223Editable := GetEditable(Rec.FieldNo(Fld223));
        Fld224Editable := GetEditable(Rec.FieldNo(Fld224));
        Fld225Editable := GetEditable(Rec.FieldNo(Fld225));
        Fld226Editable := GetEditable(Rec.FieldNo(Fld226));
        Fld227Editable := GetEditable(Rec.FieldNo(Fld227));
        Fld228Editable := GetEditable(Rec.FieldNo(Fld228));
        Fld229Editable := GetEditable(Rec.FieldNo(Fld229));
        Fld230Editable := GetEditable(Rec.FieldNo(Fld230));
        Fld231Editable := GetEditable(Rec.FieldNo(Fld231));
        Fld232Editable := GetEditable(Rec.FieldNo(Fld232));
        Fld233Editable := GetEditable(Rec.FieldNo(Fld233));
        Fld234Editable := GetEditable(Rec.FieldNo(Fld234));
        Fld235Editable := GetEditable(Rec.FieldNo(Fld235));
        Fld236Editable := GetEditable(Rec.FieldNo(Fld236));
        Fld237Editable := GetEditable(Rec.FieldNo(Fld237));
        Fld238Editable := GetEditable(Rec.FieldNo(Fld238));
        Fld239Editable := GetEditable(Rec.FieldNo(Fld239));
        Fld240Editable := GetEditable(Rec.FieldNo(Fld240));
        Fld241Editable := GetEditable(Rec.FieldNo(Fld241));
        Fld242Editable := GetEditable(Rec.FieldNo(Fld242));
        Fld243Editable := GetEditable(Rec.FieldNo(Fld243));
        Fld244Editable := GetEditable(Rec.FieldNo(Fld244));
        Fld245Editable := GetEditable(Rec.FieldNo(Fld245));
        Fld246Editable := GetEditable(Rec.FieldNo(Fld246));
        Fld247Editable := GetEditable(Rec.FieldNo(Fld247));
        Fld248Editable := GetEditable(Rec.FieldNo(Fld248));
        Fld249Editable := GetEditable(Rec.FieldNo(Fld249));

        Fld250Editable := GetEditable(Rec.FieldNo(Fld250));
        Fld251Editable := GetEditable(Rec.FieldNo(Fld251));
        Fld252Editable := GetEditable(Rec.FieldNo(Fld252));
        Fld253Editable := GetEditable(Rec.FieldNo(Fld253));
        Fld254Editable := GetEditable(Rec.FieldNo(Fld254));
        Fld255Editable := GetEditable(Rec.FieldNo(Fld255));
        Fld256Editable := GetEditable(Rec.FieldNo(Fld256));
        Fld257Editable := GetEditable(Rec.FieldNo(Fld257));
        Fld258Editable := GetEditable(Rec.FieldNo(Fld258));
        Fld259Editable := GetEditable(Rec.FieldNo(Fld259));

        Fld260Editable := GetEditable(Rec.FieldNo(Fld260));
        Fld261Editable := GetEditable(Rec.FieldNo(Fld261));
        Fld262Editable := GetEditable(Rec.FieldNo(Fld262));
        Fld263Editable := GetEditable(Rec.FieldNo(Fld263));
        Fld264Editable := GetEditable(Rec.FieldNo(Fld264));
        Fld265Editable := GetEditable(Rec.FieldNo(Fld265));
        Fld266Editable := GetEditable(Rec.FieldNo(Fld266));
        Fld267Editable := GetEditable(Rec.FieldNo(Fld267));
        Fld268Editable := GetEditable(Rec.FieldNo(Fld268));
        Fld269Editable := GetEditable(Rec.FieldNo(Fld269));

        Fld270Editable := GetEditable(Rec.FieldNo(Fld270));
        Fld271Editable := GetEditable(Rec.FieldNo(Fld271));
        Fld272Editable := GetEditable(Rec.FieldNo(Fld272));
        Fld273Editable := GetEditable(Rec.FieldNo(Fld273));
        Fld274Editable := GetEditable(Rec.FieldNo(Fld274));
        Fld275Editable := GetEditable(Rec.FieldNo(Fld275));
        Fld276Editable := GetEditable(Rec.FieldNo(Fld276));
        Fld277Editable := GetEditable(Rec.FieldNo(Fld277));
        Fld278Editable := GetEditable(Rec.FieldNo(Fld278));
        Fld279Editable := GetEditable(Rec.FieldNo(Fld279));

        Fld280Editable := GetEditable(Rec.FieldNo(Fld280));
        Fld281Editable := GetEditable(Rec.FieldNo(Fld281));
        Fld282Editable := GetEditable(Rec.FieldNo(Fld282));
        Fld283Editable := GetEditable(Rec.FieldNo(Fld283));
        Fld284Editable := GetEditable(Rec.FieldNo(Fld284));
        Fld285Editable := GetEditable(Rec.FieldNo(Fld285));
        Fld286Editable := GetEditable(Rec.FieldNo(Fld286));
        Fld287Editable := GetEditable(Rec.FieldNo(Fld287));
        Fld288Editable := GetEditable(Rec.FieldNo(Fld288));
        Fld289Editable := GetEditable(Rec.FieldNo(Fld289));

        Fld290Editable := GetEditable(Rec.FieldNo(Fld290));
        Fld291Editable := GetEditable(Rec.FieldNo(Fld291));
        Fld292Editable := GetEditable(Rec.FieldNo(Fld292));
        Fld293Editable := GetEditable(Rec.FieldNo(Fld293));
        Fld294Editable := GetEditable(Rec.FieldNo(Fld294));
        Fld295Editable := GetEditable(Rec.FieldNo(Fld295));
        Fld296Editable := GetEditable(Rec.FieldNo(Fld296));
        Fld297Editable := GetEditable(Rec.FieldNo(Fld297));
        Fld298Editable := GetEditable(Rec.FieldNo(Fld298));
        Fld299Editable := GetEditable(Rec.FieldNo(Fld299));
        Fld300Editable := GetEditable(Rec.FieldNo(Fld300));
    end;

    local procedure InitVisibility()
    begin
        Fld001Visible := GetVisibility(Rec.FieldNo(Fld001));
        Fld002Visible := GetVisibility(Rec.FieldNo(Fld002));
        Fld003Visible := GetVisibility(Rec.FieldNo(Fld003));
        Fld004Visible := GetVisibility(Rec.FieldNo(Fld004));
        Fld005Visible := GetVisibility(Rec.FieldNo(Fld005));
        Fld006Visible := GetVisibility(Rec.FieldNo(Fld006));
        Fld007Visible := GetVisibility(Rec.FieldNo(Fld007));
        Fld008Visible := GetVisibility(Rec.FieldNo(Fld008));
        Fld009Visible := GetVisibility(Rec.FieldNo(Fld009));
        Fld010Visible := GetVisibility(Rec.FieldNo(Fld010));
        Fld011Visible := GetVisibility(Rec.FieldNo(Fld011));
        Fld012Visible := GetVisibility(Rec.FieldNo(Fld012));
        Fld013Visible := GetVisibility(Rec.FieldNo(Fld013));
        Fld014Visible := GetVisibility(Rec.FieldNo(Fld014));
        Fld015Visible := GetVisibility(Rec.FieldNo(Fld015));
        Fld016Visible := GetVisibility(Rec.FieldNo(Fld016));
        Fld017Visible := GetVisibility(Rec.FieldNo(Fld017));
        Fld018Visible := GetVisibility(Rec.FieldNo(Fld018));
        Fld019Visible := GetVisibility(Rec.FieldNo(Fld019));
        Fld020Visible := GetVisibility(Rec.FieldNo(Fld020));
        Fld021Visible := GetVisibility(Rec.FieldNo(Fld021));
        Fld022Visible := GetVisibility(Rec.FieldNo(Fld022));
        Fld023Visible := GetVisibility(Rec.FieldNo(Fld023));
        Fld024Visible := GetVisibility(Rec.FieldNo(Fld024));
        Fld025Visible := GetVisibility(Rec.FieldNo(Fld025));
        Fld026Visible := GetVisibility(Rec.FieldNo(Fld026));
        Fld027Visible := GetVisibility(Rec.FieldNo(Fld027));
        Fld028Visible := GetVisibility(Rec.FieldNo(Fld028));
        Fld029Visible := GetVisibility(Rec.FieldNo(Fld029));
        Fld030Visible := GetVisibility(Rec.FieldNo(Fld030));
        Fld031Visible := GetVisibility(Rec.FieldNo(Fld031));
        Fld032Visible := GetVisibility(Rec.FieldNo(Fld032));
        Fld033Visible := GetVisibility(Rec.FieldNo(Fld033));
        Fld034Visible := GetVisibility(Rec.FieldNo(Fld034));
        Fld035Visible := GetVisibility(Rec.FieldNo(Fld035));
        Fld036Visible := GetVisibility(Rec.FieldNo(Fld036));
        Fld037Visible := GetVisibility(Rec.FieldNo(Fld037));
        Fld038Visible := GetVisibility(Rec.FieldNo(Fld038));
        Fld039Visible := GetVisibility(Rec.FieldNo(Fld039));
        Fld040Visible := GetVisibility(Rec.FieldNo(Fld040));
        Fld041Visible := GetVisibility(Rec.FieldNo(Fld041));
        Fld042Visible := GetVisibility(Rec.FieldNo(Fld042));
        Fld043Visible := GetVisibility(Rec.FieldNo(Fld043));
        Fld044Visible := GetVisibility(Rec.FieldNo(Fld044));
        Fld045Visible := GetVisibility(Rec.FieldNo(Fld045));
        Fld046Visible := GetVisibility(Rec.FieldNo(Fld046));
        Fld047Visible := GetVisibility(Rec.FieldNo(Fld047));
        Fld048Visible := GetVisibility(Rec.FieldNo(Fld048));
        Fld049Visible := GetVisibility(Rec.FieldNo(Fld049));
        Fld050Visible := GetVisibility(Rec.FieldNo(Fld050));
        Fld051Visible := GetVisibility(Rec.FieldNo(Fld051));
        Fld052Visible := GetVisibility(Rec.FieldNo(Fld052));
        Fld053Visible := GetVisibility(Rec.FieldNo(Fld053));
        Fld054Visible := GetVisibility(Rec.FieldNo(Fld054));
        Fld055Visible := GetVisibility(Rec.FieldNo(Fld055));
        Fld056Visible := GetVisibility(Rec.FieldNo(Fld056));
        Fld057Visible := GetVisibility(Rec.FieldNo(Fld057));
        Fld058Visible := GetVisibility(Rec.FieldNo(Fld058));
        Fld059Visible := GetVisibility(Rec.FieldNo(Fld059));
        Fld060Visible := GetVisibility(Rec.FieldNo(Fld060));
        Fld061Visible := GetVisibility(Rec.FieldNo(Fld061));
        Fld062Visible := GetVisibility(Rec.FieldNo(Fld062));
        Fld063Visible := GetVisibility(Rec.FieldNo(Fld063));
        Fld064Visible := GetVisibility(Rec.FieldNo(Fld064));
        Fld065Visible := GetVisibility(Rec.FieldNo(Fld065));
        Fld066Visible := GetVisibility(Rec.FieldNo(Fld066));
        Fld067Visible := GetVisibility(Rec.FieldNo(Fld067));
        Fld068Visible := GetVisibility(Rec.FieldNo(Fld068));
        Fld069Visible := GetVisibility(Rec.FieldNo(Fld069));
        Fld070Visible := GetVisibility(Rec.FieldNo(Fld070));
        Fld071Visible := GetVisibility(Rec.FieldNo(Fld071));
        Fld072Visible := GetVisibility(Rec.FieldNo(Fld072));
        Fld073Visible := GetVisibility(Rec.FieldNo(Fld073));
        Fld074Visible := GetVisibility(Rec.FieldNo(Fld074));
        Fld075Visible := GetVisibility(Rec.FieldNo(Fld075));
        Fld076Visible := GetVisibility(Rec.FieldNo(Fld076));
        Fld077Visible := GetVisibility(Rec.FieldNo(Fld077));
        Fld078Visible := GetVisibility(Rec.FieldNo(Fld078));
        Fld079Visible := GetVisibility(Rec.FieldNo(Fld079));
        Fld080Visible := GetVisibility(Rec.FieldNo(Fld080));
        Fld081Visible := GetVisibility(Rec.FieldNo(Fld081));
        Fld082Visible := GetVisibility(Rec.FieldNo(Fld082));
        Fld083Visible := GetVisibility(Rec.FieldNo(Fld083));
        Fld084Visible := GetVisibility(Rec.FieldNo(Fld084));
        Fld085Visible := GetVisibility(Rec.FieldNo(Fld085));
        Fld086Visible := GetVisibility(Rec.FieldNo(Fld086));
        Fld087Visible := GetVisibility(Rec.FieldNo(Fld087));
        Fld088Visible := GetVisibility(Rec.FieldNo(Fld088));
        Fld089Visible := GetVisibility(Rec.FieldNo(Fld089));
        Fld090Visible := GetVisibility(Rec.FieldNo(Fld090));
        Fld091Visible := GetVisibility(Rec.FieldNo(Fld091));
        Fld092Visible := GetVisibility(Rec.FieldNo(Fld092));
        Fld093Visible := GetVisibility(Rec.FieldNo(Fld093));
        Fld094Visible := GetVisibility(Rec.FieldNo(Fld094));
        Fld095Visible := GetVisibility(Rec.FieldNo(Fld095));
        Fld096Visible := GetVisibility(Rec.FieldNo(Fld096));
        Fld097Visible := GetVisibility(Rec.FieldNo(Fld097));
        Fld098Visible := GetVisibility(Rec.FieldNo(Fld098));
        Fld099Visible := GetVisibility(Rec.FieldNo(Fld099));
        Fld100Visible := GetVisibility(Rec.FieldNo(Fld100));
        Fld101Visible := GetVisibility(Rec.FieldNo(Fld101));
        Fld102Visible := GetVisibility(Rec.FieldNo(Fld102));
        Fld103Visible := GetVisibility(Rec.FieldNo(Fld103));
        Fld104Visible := GetVisibility(Rec.FieldNo(Fld104));
        Fld105Visible := GetVisibility(Rec.FieldNo(Fld105));
        Fld106Visible := GetVisibility(Rec.FieldNo(Fld106));
        Fld107Visible := GetVisibility(Rec.FieldNo(Fld107));
        Fld108Visible := GetVisibility(Rec.FieldNo(Fld108));
        Fld109Visible := GetVisibility(Rec.FieldNo(Fld109));
        Fld110Visible := GetVisibility(Rec.FieldNo(Fld110));
        Fld111Visible := GetVisibility(Rec.FieldNo(Fld111));
        Fld112Visible := GetVisibility(Rec.FieldNo(Fld112));
        Fld113Visible := GetVisibility(Rec.FieldNo(Fld113));
        Fld114Visible := GetVisibility(Rec.FieldNo(Fld114));
        Fld115Visible := GetVisibility(Rec.FieldNo(Fld115));
        Fld116Visible := GetVisibility(Rec.FieldNo(Fld116));
        Fld117Visible := GetVisibility(Rec.FieldNo(Fld117));
        Fld118Visible := GetVisibility(Rec.FieldNo(Fld118));
        Fld119Visible := GetVisibility(Rec.FieldNo(Fld119));
        Fld120Visible := GetVisibility(Rec.FieldNo(Fld120));
        Fld121Visible := GetVisibility(Rec.FieldNo(Fld121));
        Fld122Visible := GetVisibility(Rec.FieldNo(Fld122));
        Fld123Visible := GetVisibility(Rec.FieldNo(Fld123));
        Fld124Visible := GetVisibility(Rec.FieldNo(Fld124));
        Fld125Visible := GetVisibility(Rec.FieldNo(Fld125));
        Fld126Visible := GetVisibility(Rec.FieldNo(Fld126));
        Fld127Visible := GetVisibility(Rec.FieldNo(Fld127));
        Fld128Visible := GetVisibility(Rec.FieldNo(Fld128));
        Fld129Visible := GetVisibility(Rec.FieldNo(Fld129));
        Fld130Visible := GetVisibility(Rec.FieldNo(Fld130));
        Fld131Visible := GetVisibility(Rec.FieldNo(Fld131));
        Fld132Visible := GetVisibility(Rec.FieldNo(Fld132));
        Fld133Visible := GetVisibility(Rec.FieldNo(Fld133));
        Fld134Visible := GetVisibility(Rec.FieldNo(Fld134));
        Fld135Visible := GetVisibility(Rec.FieldNo(Fld135));
        Fld136Visible := GetVisibility(Rec.FieldNo(Fld136));
        Fld137Visible := GetVisibility(Rec.FieldNo(Fld137));
        Fld138Visible := GetVisibility(Rec.FieldNo(Fld138));
        Fld139Visible := GetVisibility(Rec.FieldNo(Fld139));
        Fld140Visible := GetVisibility(Rec.FieldNo(Fld140));
        Fld141Visible := GetVisibility(Rec.FieldNo(Fld141));
        Fld142Visible := GetVisibility(Rec.FieldNo(Fld142));
        Fld143Visible := GetVisibility(Rec.FieldNo(Fld143));
        Fld144Visible := GetVisibility(Rec.FieldNo(Fld144));
        Fld145Visible := GetVisibility(Rec.FieldNo(Fld145));
        Fld146Visible := GetVisibility(Rec.FieldNo(Fld146));
        Fld147Visible := GetVisibility(Rec.FieldNo(Fld147));
        Fld148Visible := GetVisibility(Rec.FieldNo(Fld148));
        Fld149Visible := GetVisibility(Rec.FieldNo(Fld149));
        Fld150Visible := GetVisibility(Rec.FieldNo(Fld150));
        Fld151Visible := GetVisibility(Rec.FieldNo(Fld151));
        Fld152Visible := GetVisibility(Rec.FieldNo(Fld152));
        Fld153Visible := GetVisibility(Rec.FieldNo(Fld153));
        Fld154Visible := GetVisibility(Rec.FieldNo(Fld154));
        Fld155Visible := GetVisibility(Rec.FieldNo(Fld155));
        Fld156Visible := GetVisibility(Rec.FieldNo(Fld156));
        Fld157Visible := GetVisibility(Rec.FieldNo(Fld157));
        Fld158Visible := GetVisibility(Rec.FieldNo(Fld158));
        Fld159Visible := GetVisibility(Rec.FieldNo(Fld159));
        Fld160Visible := GetVisibility(Rec.FieldNo(Fld160));
        Fld161Visible := GetVisibility(Rec.FieldNo(Fld161));
        Fld162Visible := GetVisibility(Rec.FieldNo(Fld162));
        Fld163Visible := GetVisibility(Rec.FieldNo(Fld163));
        Fld164Visible := GetVisibility(Rec.FieldNo(Fld164));
        Fld165Visible := GetVisibility(Rec.FieldNo(Fld165));
        Fld166Visible := GetVisibility(Rec.FieldNo(Fld166));
        Fld167Visible := GetVisibility(Rec.FieldNo(Fld167));
        Fld168Visible := GetVisibility(Rec.FieldNo(Fld168));
        Fld169Visible := GetVisibility(Rec.FieldNo(Fld169));
        Fld170Visible := GetVisibility(Rec.FieldNo(Fld170));
        Fld171Visible := GetVisibility(Rec.FieldNo(Fld171));
        Fld172Visible := GetVisibility(Rec.FieldNo(Fld172));
        Fld173Visible := GetVisibility(Rec.FieldNo(Fld173));
        Fld174Visible := GetVisibility(Rec.FieldNo(Fld174));
        Fld175Visible := GetVisibility(Rec.FieldNo(Fld175));
        Fld176Visible := GetVisibility(Rec.FieldNo(Fld176));
        Fld177Visible := GetVisibility(Rec.FieldNo(Fld177));
        Fld178Visible := GetVisibility(Rec.FieldNo(Fld178));
        Fld179Visible := GetVisibility(Rec.FieldNo(Fld179));
        Fld180Visible := GetVisibility(Rec.FieldNo(Fld180));
        Fld181Visible := GetVisibility(Rec.FieldNo(Fld181));
        Fld182Visible := GetVisibility(Rec.FieldNo(Fld182));
        Fld183Visible := GetVisibility(Rec.FieldNo(Fld183));
        Fld184Visible := GetVisibility(Rec.FieldNo(Fld184));
        Fld185Visible := GetVisibility(Rec.FieldNo(Fld185));
        Fld186Visible := GetVisibility(Rec.FieldNo(Fld186));
        Fld187Visible := GetVisibility(Rec.FieldNo(Fld187));
        Fld188Visible := GetVisibility(Rec.FieldNo(Fld188));
        Fld189Visible := GetVisibility(Rec.FieldNo(Fld189));
        Fld190Visible := GetVisibility(Rec.FieldNo(Fld190));
        Fld191Visible := GetVisibility(Rec.FieldNo(Fld191));
        Fld192Visible := GetVisibility(Rec.FieldNo(Fld192));
        Fld193Visible := GetVisibility(Rec.FieldNo(Fld193));
        Fld194Visible := GetVisibility(Rec.FieldNo(Fld194));
        Fld195Visible := GetVisibility(Rec.FieldNo(Fld195));
        Fld196Visible := GetVisibility(Rec.FieldNo(Fld196));
        Fld197Visible := GetVisibility(Rec.FieldNo(Fld197));
        Fld198Visible := GetVisibility(Rec.FieldNo(Fld198));
        Fld199Visible := GetVisibility(Rec.FieldNo(Fld199));
        Fld200Visible := GetVisibility(Rec.FieldNo(Fld200));
        Fld201Visible := GetVisibility(Rec.FieldNo(Fld201));
        Fld202Visible := GetVisibility(Rec.FieldNo(Fld202));
        Fld203Visible := GetVisibility(Rec.FieldNo(Fld203));
        Fld204Visible := GetVisibility(Rec.FieldNo(Fld204));
        Fld205Visible := GetVisibility(Rec.FieldNo(Fld205));
        Fld206Visible := GetVisibility(Rec.FieldNo(Fld206));
        Fld207Visible := GetVisibility(Rec.FieldNo(Fld207));
        Fld208Visible := GetVisibility(Rec.FieldNo(Fld208));
        Fld209Visible := GetVisibility(Rec.FieldNo(Fld209));
        Fld210Visible := GetVisibility(Rec.FieldNo(Fld210));
        Fld211Visible := GetVisibility(Rec.FieldNo(Fld211));
        Fld212Visible := GetVisibility(Rec.FieldNo(Fld212));
        Fld213Visible := GetVisibility(Rec.FieldNo(Fld213));
        Fld214Visible := GetVisibility(Rec.FieldNo(Fld214));
        Fld215Visible := GetVisibility(Rec.FieldNo(Fld215));
        Fld216Visible := GetVisibility(Rec.FieldNo(Fld216));
        Fld217Visible := GetVisibility(Rec.FieldNo(Fld217));
        Fld218Visible := GetVisibility(Rec.FieldNo(Fld218));
        Fld219Visible := GetVisibility(Rec.FieldNo(Fld219));
        Fld220Visible := GetVisibility(Rec.FieldNo(Fld220));
        Fld221Visible := GetVisibility(Rec.FieldNo(Fld221));
        Fld222Visible := GetVisibility(Rec.FieldNo(Fld222));
        Fld223Visible := GetVisibility(Rec.FieldNo(Fld223));
        Fld224Visible := GetVisibility(Rec.FieldNo(Fld224));
        Fld225Visible := GetVisibility(Rec.FieldNo(Fld225));
        Fld226Visible := GetVisibility(Rec.FieldNo(Fld226));
        Fld227Visible := GetVisibility(Rec.FieldNo(Fld227));
        Fld228Visible := GetVisibility(Rec.FieldNo(Fld228));
        Fld229Visible := GetVisibility(Rec.FieldNo(Fld229));
        Fld230Visible := GetVisibility(Rec.FieldNo(Fld230));
        Fld231Visible := GetVisibility(Rec.FieldNo(Fld231));
        Fld232Visible := GetVisibility(Rec.FieldNo(Fld232));
        Fld233Visible := GetVisibility(Rec.FieldNo(Fld233));
        Fld234Visible := GetVisibility(Rec.FieldNo(Fld234));
        Fld235Visible := GetVisibility(Rec.FieldNo(Fld235));
        Fld236Visible := GetVisibility(Rec.FieldNo(Fld236));
        Fld237Visible := GetVisibility(Rec.FieldNo(Fld237));
        Fld238Visible := GetVisibility(Rec.FieldNo(Fld238));
        Fld239Visible := GetVisibility(Rec.FieldNo(Fld239));
        Fld240Visible := GetVisibility(Rec.FieldNo(Fld240));
        Fld241Visible := GetVisibility(Rec.FieldNo(Fld241));
        Fld242Visible := GetVisibility(Rec.FieldNo(Fld242));
        Fld243Visible := GetVisibility(Rec.FieldNo(Fld243));
        Fld244Visible := GetVisibility(Rec.FieldNo(Fld244));
        Fld245Visible := GetVisibility(Rec.FieldNo(Fld245));
        Fld246Visible := GetVisibility(Rec.FieldNo(Fld246));
        Fld247Visible := GetVisibility(Rec.FieldNo(Fld247));
        Fld248Visible := GetVisibility(Rec.FieldNo(Fld248));
        Fld249Visible := GetVisibility(Rec.FieldNo(Fld249));
        Fld250Visible := GetVisibility(Rec.FieldNo(Fld250));
        Fld251Visible := GetVisibility(Rec.FieldNo(Fld251));
        Fld252Visible := GetVisibility(Rec.FieldNo(Fld252));
        Fld253Visible := GetVisibility(Rec.FieldNo(Fld253));
        Fld254Visible := GetVisibility(Rec.FieldNo(Fld254));
        Fld255Visible := GetVisibility(Rec.FieldNo(Fld255));
        Fld256Visible := GetVisibility(Rec.FieldNo(Fld256));
        Fld257Visible := GetVisibility(Rec.FieldNo(Fld257));
        Fld258Visible := GetVisibility(Rec.FieldNo(Fld258));
        Fld259Visible := GetVisibility(Rec.FieldNo(Fld259));
        Fld260Visible := GetVisibility(Rec.FieldNo(Fld260));
        Fld261Visible := GetVisibility(Rec.FieldNo(Fld261));
        Fld262Visible := GetVisibility(Rec.FieldNo(Fld262));
        Fld263Visible := GetVisibility(Rec.FieldNo(Fld263));
        Fld264Visible := GetVisibility(Rec.FieldNo(Fld264));
        Fld265Visible := GetVisibility(Rec.FieldNo(Fld265));
        Fld266Visible := GetVisibility(Rec.FieldNo(Fld266));
        Fld267Visible := GetVisibility(Rec.FieldNo(Fld267));
        Fld268Visible := GetVisibility(Rec.FieldNo(Fld268));
        Fld269Visible := GetVisibility(Rec.FieldNo(Fld269));
        Fld270Visible := GetVisibility(Rec.FieldNo(Fld270));
        Fld271Visible := GetVisibility(Rec.FieldNo(Fld271));
        Fld272Visible := GetVisibility(Rec.FieldNo(Fld272));
        Fld273Visible := GetVisibility(Rec.FieldNo(Fld273));
        Fld274Visible := GetVisibility(Rec.FieldNo(Fld274));
        Fld275Visible := GetVisibility(Rec.FieldNo(Fld275));
        Fld276Visible := GetVisibility(Rec.FieldNo(Fld276));
        Fld277Visible := GetVisibility(Rec.FieldNo(Fld277));
        Fld278Visible := GetVisibility(Rec.FieldNo(Fld278));
        Fld279Visible := GetVisibility(Rec.FieldNo(Fld279));
        Fld280Visible := GetVisibility(Rec.FieldNo(Fld280));
        Fld281Visible := GetVisibility(Rec.FieldNo(Fld281));
        Fld282Visible := GetVisibility(Rec.FieldNo(Fld282));
        Fld283Visible := GetVisibility(Rec.FieldNo(Fld283));
        Fld284Visible := GetVisibility(Rec.FieldNo(Fld284));
        Fld285Visible := GetVisibility(Rec.FieldNo(Fld285));
        Fld286Visible := GetVisibility(Rec.FieldNo(Fld286));
        Fld287Visible := GetVisibility(Rec.FieldNo(Fld287));
        Fld288Visible := GetVisibility(Rec.FieldNo(Fld288));
        Fld289Visible := GetVisibility(Rec.FieldNo(Fld289));
        Fld290Visible := GetVisibility(Rec.FieldNo(Fld290));
        Fld291Visible := GetVisibility(Rec.FieldNo(Fld291));
        Fld292Visible := GetVisibility(Rec.FieldNo(Fld292));
        Fld293Visible := GetVisibility(Rec.FieldNo(Fld293));
        Fld294Visible := GetVisibility(Rec.FieldNo(Fld294));
        Fld295Visible := GetVisibility(Rec.FieldNo(Fld295));
        Fld296Visible := GetVisibility(Rec.FieldNo(Fld296));
        Fld297Visible := GetVisibility(Rec.FieldNo(Fld297));
        Fld298Visible := GetVisibility(Rec.FieldNo(Fld298));
        Fld299Visible := GetVisibility(Rec.FieldNo(Fld299));
        Fld300Visible := GetVisibility(Rec.FieldNo(Fld300));
    end;

    procedure GetEditable(FieldNo: Integer) IsEditable: Boolean
    begin
        /* Only show Columns with Caption */
        IsEditable := DMTGenBufferFieldCaptions.HasCaption(FieldNo);
    end;

    procedure GetVisibility(FieldNo: Integer) IsEditable: Boolean
    begin
        /* Only show Columns with Caption */
        IsEditable := DMTGenBufferFieldCaptions.HasCaption(FieldNo);
    end;

    var
        DMTGenBufferFieldCaptions: Codeunit DMTSessionStorage;
        // [InDataSet]
        Fld001Editable, Fld002Editable, Fld003Editable, Fld004Editable, Fld005Editable, Fld006Editable, Fld007Editable, Fld008Editable, Fld009Editable, Fld010Editable,
        Fld011Editable, Fld012Editable, Fld013Editable, Fld014Editable, Fld015Editable, Fld016Editable, Fld017Editable, Fld018Editable, Fld019Editable, Fld020Editable,
        Fld021Editable, Fld022Editable, Fld023Editable, Fld024Editable, Fld025Editable, Fld026Editable, Fld027Editable, Fld028Editable, Fld029Editable, Fld030Editable,
        Fld031Editable, Fld032Editable, Fld033Editable, Fld034Editable, Fld035Editable, Fld036Editable, Fld037Editable, Fld038Editable, Fld039Editable, Fld040Editable,
        Fld041Editable, Fld042Editable, Fld043Editable, Fld044Editable, Fld045Editable, Fld046Editable, Fld047Editable, Fld048Editable, Fld049Editable, Fld050Editable,
        Fld051Editable, Fld052Editable, Fld053Editable, Fld054Editable, Fld055Editable, Fld056Editable, Fld057Editable, Fld058Editable, Fld059Editable, Fld060Editable,
        Fld061Editable, Fld062Editable, Fld063Editable, Fld064Editable, Fld065Editable, Fld066Editable, Fld067Editable, Fld068Editable, Fld069Editable, Fld070Editable,
        Fld071Editable, Fld072Editable, Fld073Editable, Fld074Editable, Fld075Editable, Fld076Editable, Fld077Editable, Fld078Editable, Fld079Editable, Fld080Editable,
        Fld081Editable, Fld082Editable, Fld083Editable, Fld084Editable, Fld085Editable, Fld086Editable, Fld087Editable, Fld088Editable, Fld089Editable, Fld090Editable,
        Fld091Editable, Fld092Editable, Fld093Editable, Fld094Editable, Fld095Editable, Fld096Editable, Fld097Editable, Fld098Editable, Fld099Editable, Fld100Editable,
        Fld101Editable, Fld102Editable, Fld103Editable, Fld104Editable, Fld105Editable, Fld106Editable, Fld107Editable, Fld108Editable, Fld109Editable, Fld110Editable,
        Fld111Editable, Fld112Editable, Fld113Editable, Fld114Editable, Fld115Editable, Fld116Editable, Fld117Editable, Fld118Editable, Fld119Editable, Fld120Editable,
        Fld121Editable, Fld122Editable, Fld123Editable, Fld124Editable, Fld125Editable, Fld126Editable, Fld127Editable, Fld128Editable, Fld129Editable, Fld130Editable,
        Fld131Editable, Fld132Editable, Fld133Editable, Fld134Editable, Fld135Editable, Fld136Editable, Fld137Editable, Fld138Editable, Fld139Editable, Fld140Editable,
        Fld141Editable, Fld142Editable, Fld143Editable, Fld144Editable, Fld145Editable, Fld146Editable, Fld147Editable, Fld148Editable, Fld149Editable, Fld150Editable,
        Fld151Editable, Fld152Editable, Fld153Editable, Fld154Editable, Fld155Editable, Fld156Editable, Fld157Editable, Fld158Editable, Fld159Editable, Fld160Editable,
        Fld161Editable, Fld162Editable, Fld163Editable, Fld164Editable, Fld165Editable, Fld166Editable, Fld167Editable, Fld168Editable, Fld169Editable, Fld170Editable,
        Fld171Editable, Fld172Editable, Fld173Editable, Fld174Editable, Fld175Editable, Fld176Editable, Fld177Editable, Fld178Editable, Fld179Editable, Fld180Editable,
        Fld181Editable, Fld182Editable, Fld183Editable, Fld184Editable, Fld185Editable, Fld186Editable, Fld187Editable, Fld188Editable, Fld189Editable, Fld190Editable,
        Fld191Editable, Fld192Editable, Fld193Editable, Fld194Editable, Fld195Editable, Fld196Editable, Fld197Editable, Fld198Editable, Fld199Editable, Fld200Editable,
        Fld201Editable, Fld202Editable, Fld203Editable, Fld204Editable, Fld205Editable, Fld206Editable, Fld207Editable, Fld208Editable, Fld209Editable, Fld210Editable,
        Fld211Editable, Fld212Editable, Fld213Editable, Fld214Editable, Fld215Editable, Fld216Editable, Fld217Editable, Fld218Editable, Fld219Editable, Fld220Editable,
        Fld221Editable, Fld222Editable, Fld223Editable, Fld224Editable, Fld225Editable, Fld226Editable, Fld227Editable, Fld228Editable, Fld229Editable, Fld230Editable,
        Fld231Editable, Fld232Editable, Fld233Editable, Fld234Editable, Fld235Editable, Fld236Editable, Fld237Editable, Fld238Editable, Fld239Editable, Fld240Editable,
        Fld241Editable, Fld242Editable, Fld243Editable, Fld244Editable, Fld245Editable, Fld246Editable, Fld247Editable, Fld248Editable, Fld249Editable, Fld250Editable,
        Fld251Editable, Fld252Editable, Fld253Editable, Fld254Editable, Fld255Editable, Fld256Editable, Fld257Editable, Fld258Editable, Fld259Editable, Fld260Editable,
        Fld261Editable, Fld262Editable, Fld263Editable, Fld264Editable, Fld265Editable, Fld266Editable, Fld267Editable, Fld268Editable, Fld269Editable, Fld270Editable,
        Fld271Editable, Fld272Editable, Fld273Editable, Fld274Editable, Fld275Editable, Fld276Editable, Fld277Editable, Fld278Editable, Fld279Editable, Fld280Editable,
        Fld281Editable, Fld282Editable, Fld283Editable, Fld284Editable, Fld285Editable, Fld286Editable, Fld287Editable, Fld288Editable, Fld289Editable, Fld290Editable,
        Fld291Editable, Fld292Editable, Fld293Editable, Fld294Editable, Fld295Editable, Fld296Editable, Fld297Editable, Fld298Editable, Fld299Editable, Fld300Editable : Boolean;
        // [InDataSet]
        Fld001Visible, Fld002Visible, Fld003Visible, Fld004Visible, Fld005Visible, Fld006Visible, Fld007Visible, Fld008Visible, Fld009Visible, Fld010Visible,
        Fld011Visible, Fld012Visible, Fld013Visible, Fld014Visible, Fld015Visible, Fld016Visible, Fld017Visible, Fld018Visible, Fld019Visible, Fld020Visible,
        Fld021Visible, Fld022Visible, Fld023Visible, Fld024Visible, Fld025Visible, Fld026Visible, Fld027Visible, Fld028Visible, Fld029Visible, Fld030Visible,
        Fld031Visible, Fld032Visible, Fld033Visible, Fld034Visible, Fld035Visible, Fld036Visible, Fld037Visible, Fld038Visible, Fld039Visible, Fld040Visible,
        Fld041Visible, Fld042Visible, Fld043Visible, Fld044Visible, Fld045Visible, Fld046Visible, Fld047Visible, Fld048Visible, Fld049Visible, Fld050Visible,
        Fld051Visible, Fld052Visible, Fld053Visible, Fld054Visible, Fld055Visible, Fld056Visible, Fld057Visible, Fld058Visible, Fld059Visible, Fld060Visible,
        Fld061Visible, Fld062Visible, Fld063Visible, Fld064Visible, Fld065Visible, Fld066Visible, Fld067Visible, Fld068Visible, Fld069Visible, Fld070Visible,
        Fld071Visible, Fld072Visible, Fld073Visible, Fld074Visible, Fld075Visible, Fld076Visible, Fld077Visible, Fld078Visible, Fld079Visible, Fld080Visible,
        Fld081Visible, Fld082Visible, Fld083Visible, Fld084Visible, Fld085Visible, Fld086Visible, Fld087Visible, Fld088Visible, Fld089Visible, Fld090Visible,
        Fld091Visible, Fld092Visible, Fld093Visible, Fld094Visible, Fld095Visible, Fld096Visible, Fld097Visible, Fld098Visible, Fld099Visible, Fld100Visible,
        Fld101Visible, Fld102Visible, Fld103Visible, Fld104Visible, Fld105Visible, Fld106Visible, Fld107Visible, Fld108Visible, Fld109Visible, Fld110Visible,
        Fld111Visible, Fld112Visible, Fld113Visible, Fld114Visible, Fld115Visible, Fld116Visible, Fld117Visible, Fld118Visible, Fld119Visible, Fld120Visible,
        Fld121Visible, Fld122Visible, Fld123Visible, Fld124Visible, Fld125Visible, Fld126Visible, Fld127Visible, Fld128Visible, Fld129Visible, Fld130Visible,
        Fld131Visible, Fld132Visible, Fld133Visible, Fld134Visible, Fld135Visible, Fld136Visible, Fld137Visible, Fld138Visible, Fld139Visible, Fld140Visible,
        Fld141Visible, Fld142Visible, Fld143Visible, Fld144Visible, Fld145Visible, Fld146Visible, Fld147Visible, Fld148Visible, Fld149Visible, Fld150Visible,
        Fld151Visible, Fld152Visible, Fld153Visible, Fld154Visible, Fld155Visible, Fld156Visible, Fld157Visible, Fld158Visible, Fld159Visible, Fld160Visible,
        Fld161Visible, Fld162Visible, Fld163Visible, Fld164Visible, Fld165Visible, Fld166Visible, Fld167Visible, Fld168Visible, Fld169Visible, Fld170Visible,
        Fld171Visible, Fld172Visible, Fld173Visible, Fld174Visible, Fld175Visible, Fld176Visible, Fld177Visible, Fld178Visible, Fld179Visible, Fld180Visible,
        Fld181Visible, Fld182Visible, Fld183Visible, Fld184Visible, Fld185Visible, Fld186Visible, Fld187Visible, Fld188Visible, Fld189Visible, Fld190Visible,
        Fld191Visible, Fld192Visible, Fld193Visible, Fld194Visible, Fld195Visible, Fld196Visible, Fld197Visible, Fld198Visible, Fld199Visible, Fld200Visible,
        Fld201Visible, Fld202Visible, Fld203Visible, Fld204Visible, Fld205Visible, Fld206Visible, Fld207Visible, Fld208Visible, Fld209Visible, Fld210Visible,
        Fld211Visible, Fld212Visible, Fld213Visible, Fld214Visible, Fld215Visible, Fld216Visible, Fld217Visible, Fld218Visible, Fld219Visible, Fld220Visible,
        Fld221Visible, Fld222Visible, Fld223Visible, Fld224Visible, Fld225Visible, Fld226Visible, Fld227Visible, Fld228Visible, Fld229Visible, Fld230Visible,
        Fld231Visible, Fld232Visible, Fld233Visible, Fld234Visible, Fld235Visible, Fld236Visible, Fld237Visible, Fld238Visible, Fld239Visible, Fld240Visible,
        Fld241Visible, Fld242Visible, Fld243Visible, Fld244Visible, Fld245Visible, Fld246Visible, Fld247Visible, Fld248Visible, Fld249Visible, Fld250Visible,
        Fld251Visible, Fld252Visible, Fld253Visible, Fld254Visible, Fld255Visible, Fld256Visible, Fld257Visible, Fld258Visible, Fld259Visible, Fld260Visible,
        Fld261Visible, Fld262Visible, Fld263Visible, Fld264Visible, Fld265Visible, Fld266Visible, Fld267Visible, Fld268Visible, Fld269Visible, Fld270Visible,
        Fld271Visible, Fld272Visible, Fld273Visible, Fld274Visible, Fld275Visible, Fld276Visible, Fld277Visible, Fld278Visible, Fld279Visible, Fld280Visible,
        Fld281Visible, Fld282Visible, Fld283Visible, Fld284Visible, Fld285Visible, Fld286Visible, Fld287Visible, Fld288Visible, Fld289Visible, Fld290Visible,
        Fld291Visible, Fld292Visible, Fld293Visible, Fld294Visible, Fld295Visible, Fld296Visible, Fld297Visible, Fld298Visible, Fld299Visible, Fld300Visible : Boolean;
}
