import httpclient, json

const EndPoint = "https://api.audius.co"

type
  Audius* = ref object
    client: HttpClient
    headers: HttpHeaders
    appName: string
    server: string

  UserSchema* = ref object
    album_count, followee_count*, follower_count*, playlist_count*,
        repost_count*, track_count*: int
    bio*, handle*, id*, location*, name*: string
    #coverPhoto*, profitePicture*: string
    is_verified*: bool

  User* = ref object
    schema: UserSchema
    api: Audius

  TrackSchema* = ref object
    description*, genre*, id*, mood*, release_date*, tags*, title*: string
    repost_count*, favorite_count*, duration*, play_count*: int
    downloadable*: bool
    user*: UserSchema

  Track* = ref object
    schema: TrackSchema
    api: Audius

template uri(content: string): string =
  api.server & content & "?app_name=" & api.appName

proc newAudius*(appName: string = "EXAMPLEAPP"): Audius =
  new result
  result.headers = newHttpHeaders([("Accept", "application/json")])
  result.client = newHttpClient(headers = result.headers)
  result.appName = appName
  let servers = parseJson(result.client.getContent(EndPoint))
  result.server = servers["data"][0].getStr & "/v1"

# User
proc getUser*(api: Audius, id: string): User =
  new result
  let json = parseJson(api.client.getContent(uri("/users/" & id)))

  let schema = to(json["data"], UserSchema)
  result.schema = schema
  result.api = api

iterator tracks*(user: User): Track =
  let json = parseJson(user.api.client.getContent(user.api.server &
      "/users/" & user.schema.id & "/tracks"))
  for track in json["data"]:
    let result = Track()
    result.schema = to(track, TrackSchema)
    yield result

iterator searchUsers*(api: Audius, query: string,
    onlyDowloadable = false): User =
  let json = parseJson(api.client.getContent(api.server &
      "/users/search?query=" & query & "&only_downloadable=" &
      $onlyDowloadable))
  for user in json["data"]:
    let result = User(api: api)
    result.schema = to(user, UserSchema)
    yield result

#Track
proc getTrack*(api: Audius, id: string): Track =
  let json = parseJson(api.client.getContent(api.server & "/tracks/" & id))
  result.schema = to(json["data"], TrackSchema)
  result.api = api

proc getStreamTrack*(api: Audius, id: string): string =
  result = api.client.getContent(api.server & "/tracks/" & id & "/stream")

# Test
when isMainModule:
  let audius = newAudius()
  for user in audius.searchUsers("Brownies"):
    echo user.schema.name

  let user = audius.getUser("nlGNe")
  for track in user.tracks:
    echo track.schema.title
