page 91002 DMTGenBufferList100
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
        Fld091Editable, Fld092Editable, Fld093Editable, Fld094Editable, Fld095Editable, Fld096Editable, Fld097Editable, Fld098Editable, Fld099Editable, Fld100Editable : Boolean;
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
        Fld091Visible, Fld092Visible, Fld093Visible, Fld094Visible, Fld095Visible, Fld096Visible, Fld097Visible, Fld098Visible, Fld099Visible, Fld100Visible : Boolean;
}
