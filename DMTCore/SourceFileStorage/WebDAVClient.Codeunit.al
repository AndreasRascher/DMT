
/// <summary>
/// <b>SetRequestUri</b> - Uri should be: baseUrl/remote.php/dav/files/username/
/// 
/// <b>PROPFIND_Request</b> - is the initial request to the user files
/// 
/// <b>GET_Request</b> is the request to get the files
/// </summary>
codeunit 50024 DMTWebDAVClient
{
    procedure setBasicAuth(username: Text; password: Text)
    begin
        AuthMethod := AuthMethod::BasicAuth;
        UsernameGlobal := username;
        PasswordGlobal := password;
    end;

    procedure PROPFIND_Request(var responseContentText: Text) OK: Boolean
    begin
        Clear(ResponseGlobal);
        OK := PROPFIND_Request(ResponseGlobal);
        ResponseGlobal.Content.ReadAs(responseContentText);
    end;

    procedure PROPFIND_Request(response: HttpResponseMessage) OK: Boolean
    var
        request: HttpRequestMessage;
        requestHeaders: HttpHeaders;
    begin
        addAuthentication(request);
        request.GetHeaders(requestHeaders);
        requestHeaders.Add('Accept', '*/*');
        requestHeaders.Add('Depth', '1');
        request.SetRequestUri(RequestUriGlobal);

        request.Content.Clear();
        // default request content for PROPFIND
        request.Content.WriteFrom('<?xml version=''1.0'' encoding=''utf-8''?>' +
                                 '<propfind xmlns=''DAV:''>' +
                                 '<allprop/>' +
                                 '</propfind>');
        request.Method := 'PROPFIND';

        Client.Send(request, response);
        OK := response.IsSuccessStatusCode;
    end;

    procedure ReadFileStructure(var webDAVFileRESULT: Record DMTWebDAVFile temporary; responseContent: Text) OK: Boolean
    var
        webDAVFile: Record DMTWebDAVFile;
        typeHelper: Codeunit "Type Helper";
        xDoc: XmlDocument;
        xNode, xNode2 : XmlNode;
        xNodeList: XmlNodeList;
        xNsMgr: XmlNamespaceManager;
        prop_Href: Text;
        prop_ContentLength: Integer;
        prop_LastModified: DateTime;
        prop_ContentType: Text;
        name: Text;
    begin
        webDAVFileRESULT.Reset();
        webDAVFileRESULT.DeleteAll();
        XmlDocument.ReadFrom(responseContent, xDoc);
        AddNamespaces(xNsMgr, xDoc);
        xDoc.SelectNodes('/d:multistatus/d:response', xNsMgr, xNodeList);
        foreach xNode in xNodeList do begin
            Clear(prop_Href);
            if xNode.SelectSingleNode('./d:href/text()', xNsMgr, xNode2) then
                Evaluate(prop_Href, xNode2.AsXmlText().Value);
            Clear(prop_ContentLength);
            if xNode.SelectSingleNode('./d:propstat/d:prop/d:quota-used-bytes', xNsMgr, xNode2) then
                Evaluate(prop_ContentLength, xNode2.AsXmlElement().InnerText);
            if xNode.SelectSingleNode('./d:propstat/d:prop/d:getcontentlength', xNsMgr, xNode2) then
                Evaluate(prop_ContentLength, xNode2.AsXmlElement().InnerText);
            Clear(prop_ContentType);
            if xNode.SelectSingleNode('./d:propstat/d:prop/d:getcontenttype', xNsMgr, xNode2) then
                prop_ContentType := xNode2.AsXmlElement().InnerText;
            Clear(prop_LastModified);
            if xNode.SelectSingleNode('./d:propstat/d:prop/d:getlastmodified', xNsMgr, xNode2) then
                Evaluate(prop_LastModified, xNode2.AsXmlElement().InnerText);

            webDAVFile."Is Folder" := prop_Href.EndsWith('/');
            if not webDAVFile."Is Folder" then
                webDAVFile.Size := prop_ContentLength;
            name := prop_Href;
            name := name.Substring(name.TrimEnd('/').LastIndexOf('/') + 1).TrimEnd('/');
            webDAVFile.Name := CopyStr(typeHelper.UrlDecode(name), 1, MaxStrLen(webDAVFile.Name));
            webDAVFile.Path := CopyStr(prop_Href, 1, MaxStrLen(webDAVFile.Path));
            webDAVFile.LastModified := prop_LastModified;
            webDAVFile.Insert();
        end;
        webDAVFileRESULT.Copy(webDAVFile, true);
    end;

    procedure GET_Request(responseContent: Text) OK: Boolean
    begin
        OK := GET_Request(ResponseGlobal);
        ResponseGlobal.Content().ReadAs(responseContent);
    end;

    procedure GET_Request(var response: HttpResponseMessage) OK: Boolean
    var
        request: HttpRequestMessage;
        requestHeaders: HttpHeaders;
    begin
        addAuthentication(request);
        request.GetHeaders(requestHeaders);
        requestHeaders.Add('Accept', '*/*');
        request.SetRequestUri(RequestUriGlobal);
        request.Method := 'GET';
        Client.Send(request, response);
        OK := response.IsSuccessStatusCode;
    end;

    procedure GET_Request(var IStr: InStream) OK: Boolean
    begin
        OK := GET_Request(ResponseGlobal);
        if not OK then
            Error(ResponseGlobal.ReasonPhrase);
        ResponseGlobal.Content().ReadAs(IStr);
    end;

    local procedure addAuthentication(var request: HttpRequestMessage)
    var
        base64Convert: Codeunit "Base64 Convert";
        headers: HttpHeaders;
        AuthHeader: Text;
    begin
        case AuthMethod of
            AuthMethod::" ":
                exit;
            AuthMethod::BasicAuth:
                begin
                    request.GetHeaders(headers);
                    AuthHeader := 'Basic ' + base64Convert.ToBase64(UsernameGlobal + ':' + PasswordGlobal);
                    headers.Add('Authorization', AuthHeader);
                end;
        end;
    end;

    procedure SetRequestUri(baseUrl: Text; serverRelativeUrl: Text): Text
    begin
        baseUrl := baseUrl.TrimEnd('/');
        serverRelativeUrl := serverRelativeUrl.TrimStart('/');
        serverRelativeUrl := serverRelativeUrl.TrimEnd('/');
        RequestUriGlobal := StrSubstNo('%1/%2', baseUrl, serverRelativeUrl);
    end;

    local procedure AddNamespaces(var xNsMgr: XmlNamespaceManager; xDoc: XmlDocument)
    var
        xAttribute: XmlAttribute;
        xAttributeCollection: XmlAttributeCollection;
        xElement: XmlElement;
    begin
        xNsMgr.NameTable(xDoc.NameTable());
        xDoc.GetRoot(xElement);
        xAttributeCollection := xElement.Attributes();
        if xElement.NamespaceUri() <> '' then
            //_XmlNsMgr.AddNamespace('', _XMLElement.NamespaceUri());
            xNsMgr.AddNamespace('ns', xElement.NamespaceUri());
        foreach xAttribute in xAttributeCollection do
            if StrPos(xAttribute.Name(), 'xmlns:') = 1 then
                xNsMgr.AddNamespace(DelStr(xAttribute.Name(), 1, 6), xAttribute.Value());
    end;

    procedure SplitUrl(url: Text; var serverUrl: Text; var serverRelativeUrl: Text)
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        serverUrlOld: Text;
        hostName: Text;
    begin
        // split url in server url and server relative url
        if serverUrl = '' then exit;
        serverUrlOld := serverUrl;
        hostName := WebRequestHelper.GetHostNameFromUrl(serverUrl);

        // check if url contains relative path
        serverUrl := serverUrl.TrimEnd('/');
        if serverUrl.EndsWith(hostName) then
            exit;

        // Split after host name
        serverUrl := CopyStr(serverUrlOld, 1, StrPos(serverUrl, hostName) + StrLen(hostName));
        serverRelativeUrl := serverUrlOld.Remove(1, StrPos(serverUrl, hostName) + StrLen(hostName));
    end;

    var
        Client: HttpClient;
        ResponseGlobal: HttpResponseMessage;
        AuthMethod: Option " ",BasicAuth;
        UsernameGlobal, PasswordGlobal, RequestUriGlobal : Text;
}