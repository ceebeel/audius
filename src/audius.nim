import std/httpclient, std/json
from std/strutils import split
from std/uri import encodeUrl

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
    #artwork
    description*, genre*, id*, mood*, release_date*, tags*, title*: string
    repost_count*, favorite_count*, duration*, play_count*: int
    downloadable*: bool
    user*: UserSchema

  Track* = ref object
    schema: TrackSchema
    api: Audius

  PlaylistSchema* = ref object
    #artwork
    description, id, playlist_name: string
    repost_count, favorite_count, total_play_count: int
    is_album: bool
    user: UserSchema

  Playlist* = ref object
    schema: PlaylistSchema
    api: Audius

# Audius
template get(api: typed, query: string): JsonNode =
  parseJson(api.client.getContent(api.server & query & "?app_name=" & api.appName))

proc newAudius*(appName: string = "EXAMPLEAPP"): Audius =
  new result
  result.headers = newHttpHeaders([("Accept", "application/json")])
  result.client = newHttpClient(headers = result.headers)
  result.appName = appName
  let servers = parseJson(result.client.getContent(EndPoint))
  result.server = servers["data"][0].getStr & "/v1"

# Track
proc getTrack*(api: Audius, id: string): Track =
  new result
  let query = api.get("/tracks/" & id)
  result.schema = to(query["data"], TrackSchema)
  result.api = api

proc getStreamTrack*(api: Audius, id: string): string =
  result = api.client.getContent(api.server & "/tracks/" & id & "/stream" & "?app_name=" & api.appName)

# Playlist
proc getPlaylist*(api: Audius, id: string): Playlist =
  new result
  let query = api.get("/playlists/" & id)
  result.schema = to(query["data"][0], PlaylistSchema)
  result.api = api

iterator tracks*(playlist: Playlist): Track =
  let query = playlist.api.get("/playlists/" & playlist.schema.id & "/tracks")
  for track in query["data"]:
    let result = Track()
    result.schema = to(track, TrackSchema)
    yield result

iterator searchPlaylists*(api: Audius, query: string,
    onlyDowloadable = false): Playlist =
  let query = api.get("/playlists/search?query=" & encodeUrl(query) & "&only_downloadable=" &
      $onlyDowloadable)
  for playlist in query["data"]:
    let result = Playlist(api: api)
    result.schema = to(playlist, PlaylistSchema)
    yield result

# User
proc getUser*(api: Audius, id: string): User =
  new result
  let query = api.get("/users/" & id)
  result.schema = to(query["data"], UserSchema)
  result.api = api

iterator tracks*(user: User): Track =
  let query = user.api.get("/users/" & user.schema.id & "/tracks")
  for track in query["data"]:
    let result = Track()
    result.schema = to(track, TrackSchema)
    yield result

iterator favorites*(user: User): Track =
  let query = user.api.get("/users/" & user.schema.id & "/favorites")
  for fav in query["data"]:
    yield user.api.getTrack(fav["favorite_item_id"].getStr)

iterator reposts*(user: User): Track =
  let query = user.api.get("/users/" & user.schema.id & "/reposts")
  for repost in query["data"]:
    let result = Track()
    result.schema = to(repost["item"], TrackSchema)
    yield result

iterator tags*(user: User): string =
  # Don't work. API is broken !?
  let query = user.api.get("/users/" & user.schema.id & "/tags")
  for tag in query["data"].getStr.split(','):
    yield tag

iterator searchUsers*(api: Audius, query: string,
    onlyDowloadable = false): User =
  let query = api.get("/users/search?query=" & encodeUrl(query) & "&only_downloadable=" &
      $onlyDowloadable)
  for user in query["data"]:
    let result = User(api: api)
    result.schema = to(user, UserSchema)
    yield result


# Test
when isMainModule:
  let audius = newAudius()

#[  

  for user in audius.searchUsers("Brownies"):
    echo "User: " & user.schema.name

  let user = audius.getUser("nlGNe")

  for track in user.tracks:
    echo "Track: " & track.schema.title

  for favorite in user.favorites:
    echo "Favorite: " & favorite.schema.title

  for repost in user.reposts:
    echo "Repost: " & repost.schema.title

  for tag in user.tags:
    echo "Tag: " & tag 

  # Playlist
  for playlist in audius.searchPlaylists("Hot & New"):
    echo "Palylist: " & playlist.schema.playlist_name

  let playlist = audius.getPlaylist("DOPRl")

  for track in playlist.tracks:
    echo "Playlist Track: " & track.schema.title 
    
  ]#
