#[

  TODO:
    [X] User
    [X] Track
    [X] Stream
    [ ] Playlist
    [ ] Favorites
    [ ] Search
    
]#

import httpclient, json

type 
    AudiusApi* = object
        client: HttpClient
        headers: HttpHeaders
        appName: string
        server: string

    User* = object
        album_count, followee_count*, follower_count*, playlist_count*, repost_count*, track_count*: int
        bio*, handle*, id*, location*, name*: string
        #coverPhoto*, profitePicture*: string
        is_verified*: bool

    Track* = object
        description*, genre*, id*, mood*, release_date*, tags*, title*: string
        repost_count*, favorite_count*, duration*, play_count*: int
        downloadable*: bool
        user*: User

proc newAudiusApi*(appName: string): AudiusApi =
    result.headers = newHttpHeaders([("Accept", "application/json")])
    result.client = newHttpClient(headers = result.headers)
    result.appName = "&app_name=" & appName
    let servers = parseJson(result.client.getContent("https://api.audius.co"))
    result.server = servers["data"][0].getStr & "/v1"

proc getUser*(api: AudiusApi, id: string): User =
    let user = parseJson(api.client.getContent(api.server & "/users/" & id ))
    result = to(user["data"], User)

proc getTrack*(api: AudiusApi, id: string): Track =
    let track = parseJson(api.client.getContent(api.server & "/tracks/" & id ))
    result = to(track["data"], Track)

proc getStreamTrack*(api: AudiusApi, id: string): string =
    result = api.client.getContent(api.server & "/tracks/" & id & "/stream" )
