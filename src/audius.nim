import httpclient, json

type 
    AudiusApi* = object
        client: HttpClient
        headers: HttpHeaders
        appName: string
        server: string

proc newAudiusApi*(appName: string): AudiusApi =
    result.headers = newHttpHeaders([("Accept", "application/json")])
    result.client = newHttpClient(headers = result.headers)
    result.appName = "&app_name=" & appName
    let servers = parseJson(result.client.getContent("https://api.audius.co"))
    result.server = servers["data"][0].getStr & "/v1"