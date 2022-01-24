import std/httpclient, std/json, jsony
from std/strutils import split
from std/uri import encodeUrl

const EndPoint = "https://api.audius.co"

type
  Audius* = ref object
    client: HttpClient
    headers: HttpHeaders
    appName: string
    server: string

  User* = object
    albumCount*, followeeCount*, followerCount*, playlistCount*, repostCount*,
        trackCount*: int
    bio*, handle*, id*, location*, name*: string
    #coverPhoto*, profitePicture*: string
    is_verified*: bool
    api*: Audius

  Track* = object
    #artwork
    description*, genre*, id*, mood*, releaseDate*, tags*, title*: string
    repostCount*, favoriteCount*, duration*, playCount*: int
    downloadable*: bool
    user*: User
    api*: Audius

  Playlist* = object
    #artwork
    description, id, playlistName: string
    repostCount, favoriteCount, totalPlayCount: int
    isAlbum: bool
    user: User
    api*: Audius

# Audius
template get(api: untyped, query: string): JsonNode =
  fromJson(api.client.getContent(api.server & query & "?app_name=" & api.appName))

proc parseHook*(s: string, i: var int, v: var Audius) =
  ## Do not use! This is a hook for jsony lib.
  discard

proc newAudius*(appName: string = "EXAMPLEAPP"): Audius =
  new result
  result.headers = newHttpHeaders([("Accept", "application/json")])
  result.client = newHttpClient(headers = result.headers)
  result.appName = appName
  result.server = fromJson(result.client.getContent(EndPoint))["data"][
      0].getStr & "/v1"

# Track
proc getTrack*(api: Audius, id: string): Track =
  let query = api.get("/tracks/" & id)["data"]
  result = fromJson($query, Track)
  result.api = api

proc getStreamTrack*(api: Audius, id: string): string =
  result = api.client.getContent(api.server & "/tracks/" & id & "/stream" &
      "?app_name=" & api.appName)

# Playlist
proc getPlaylist*(api: Audius, id: string): Playlist =
  let query = api.get("/playlists/" & id)["data"][0]
  result = fromJson($query, Playlist)
  result.api = api

iterator searchPlaylists*(api: Audius, query: string,
    onlyDowloadable = false): Playlist =
  let query = api.get("/playlists/search?query=" & encodeUrl(query) &
      "&only_downloadable=" & $onlyDowloadable)
  for playlist in query["data"]:
    var result = fromJson($playlist, Playlist)
    result.api = api
    yield result

iterator tracks*(playlist: Playlist): Track =
  let query = playlist.api.get("/playlists/" & playlist.id & "/tracks")
  echo $query
  for track in query["data"]:
    var result = fromJson($track, Track)
    result.api = playlist.api
    yield result

# User
proc getUser*(api: Audius, id: string): User =
  let query = api.get("/users/" & id & "?app_name=")["data"]
  result = fromJson($query, User)
  result.api = api

iterator searchUsers*(api: Audius, query: string,
    onlyDowloadable = false): User =
  let query = api.get("/users/search?query=" & encodeUrl(query) &
      "&only_downloadable=" & $onlyDowloadable)
  for user in query["data"]:
    var result = fromJson($user, User)
    result.api = api
    yield result

iterator tracks*(user: User): Track =
  let query = user.api.get("/users/" & user.id & "/tracks")
  for track in query["data"]:
    var result = fromJson($track, Track)
    result.api = user.api
    yield result

iterator favorites*(user: User): Track =
  let query = user.api.get("/users/" & user.id & "/favorites")
  for fav in query["data"]:
    yield user.api.getTrack(fav["favorite_item_id"].getStr)

iterator reposts*(user: User): Track =
  let query = user.api.get("/users/" & user.id & "/reposts")
  for repost in query["data"]:
    var result = fromJson($repost["item"], Track)
    result.api = user.api
    yield result

iterator tags*(user: User): string =
  ## Don't work. API is broken !?
  let query = user.api.get("/users/" & user.id & "/tags")
  for tag in query["data"].getStr.split(','):
    yield tag
