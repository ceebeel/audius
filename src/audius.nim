##[
  The `audius` module is simple wrapper to the Audius API (v1).

  Audius is a decentralized music streaming service. (`audius.co<https://audius.co/>`_ / `audius.org<https://audius.org/>`_)

  The Audius API is entirely free to use. 
  
  We ask that you adhere to the guidelines in this `doc<https://audiusproject.github.io/api-docs/>`_ and always credit artists.

  Examples
  ========
  .. code-block:: nim
    import audius

    # Create new Audius client.
    let audius = newAudius()

    # Search users.
    for user in audius.searchUsers("Brownies"):
      echo "User found: " & user.name

    # Create new user by id.
    let user = audius.getUser("nlGNe")
    echo "User name: " & user.name

    # List user's tracks.
    for track in user.tracks:
      echo "User's Track: " & track.title

    # List user's favorite tracks.
    for favorite in user.favorites:
      echo "User's Favorite: " & favorite.title

    # List user reposted tracks.
    for repost in user.reposts:
      echo "User's Repost: " & repost.title

    # List common user's tags.
    for tag in user.tags:
      echo "User's Tag: " & tag

    # Search playlists
    for playlist in audius.searchPlaylists("Hot & New"):
      echo "Palylist found: " & playlist.playlistName

    # Create new playlist by id.
    let playlist = audius.getPlaylist("DOPRl")
    echo "Playlist name:"

    # List tracks in playlist.
    for track in playlist.tracks:
      echo "Playlist's Track: " & track.title
]##

import std/httpclient, std/json, jsony
from std/strutils import split
from std/uri import encodeUrl

const EndPoint = "https://api.audius.co"

type
  Audius* = ref object
    ## Audius API client.
    client: HttpClient
    headers: HttpHeaders
    appName: string
    server: string

  User* = object
    ## `User schema<https://audiusproject.github.io/api-docs/#tocS_user>`_
    albumCount*, followeeCount*, followerCount*, playlistCount*, repostCount*,
        trackCount*: int
    bio*, handle*, id*, location*, name*: string
    #coverPhoto*, profitePicture*: string
    isVerified*: bool
    api: Audius

  Track* = object
    ## `Track schema<https://audiusproject.github.io/api-docs/#tocS_Track>`_
    #artwork
    description*, genre*, id*, mood*, releaseDate*, tags*, title*: string
    repostCount*, favoriteCount*, duration*, playCount*: int
    downloadable*: bool
    user*: User
    api: Audius

  Playlist* = object
    ## `Playlist schema<https://audiusproject.github.io/api-docs/#tocS_playlist>`_
    #artwork
    description*, id*, playlistName*: string
    repostCount*, favoriteCount*, totalPlayCount*: int
    isAlbum*: bool
    user*: User
    api: Audius

# Audius
template get(api: untyped, query: string): JsonNode =
  ## Simple template api (string) to jsonNode.
  fromJson(api.client.getContent(api.server & query & "?app_name=" & api.appName))

proc parseHook*(s: string, i: var int, v: var Audius) =
  ## Warning: Do not use! This is a hook for jsony lib.
  discard

proc newAudius*(appName: string = "EXAMPLEAPP"): Audius =
  ## This create a new `Audius <#Audius>`_ API (v1) client and select a host.
  new result
  result.headers = newHttpHeaders([("Accept", "application/json")])
  result.client = newHttpClient(headers = result.headers)
  result.appName = appName
  result.server = fromJson(result.client.getContent(EndPoint))["data"][
      0].getStr & "/v1"

# Track
proc getTrack*(api: Audius, id: string): Track =
  ## Fetch a track. 
  ## `/tracks/{track_id}<https://audiusproject.github.io/api-docs/#get-track>`_
  let query = api.get("/tracks/" & id)["data"]
  result = fromJson($query, Track)
  result.api = api

proc getStreamTrack*(api: Audius, id: string): string =
  ## Get the track's streamable mp3 file. 
  ## `/tracks/{track_id}/stream<https://audiusproject.github.io/api-docs/#stream-track>`_
  ##
  ## Todo: `Range header <https://developer.mozilla.org/en-US/docs/Web/HTTP/Range_requests>`_.
  result = api.client.getContent(api.server & "/tracks/" & id & "/stream" &
      "?app_name=" & api.appName)

# Playlist
proc getPlaylist*(api: Audius, id: string): Playlist =
  ## Fetch a playlist. 
  ## `/playlists/{playlist_id}<https://audiusproject.github.io/api-docs/#get-playlist>`_
  let query = api.get("/playlists/" & id)["data"][0]
  result = fromJson($query, Playlist)
  result.api = api

iterator searchPlaylists*(api: Audius, query: string,
    onlyDowloadable = false): Playlist =
  ## Search for a playlist. 
  ## `/playlists/search<https://audiusproject.github.io/api-docs/#search-playlists>`_
  let query = api.get("/playlists/search?query=" & encodeUrl(query) &
      "&only_downloadable=" & $onlyDowloadable)
  for playlist in query["data"]:
    var result = fromJson($playlist, Playlist)
    result.api = api
    yield result

proc searchPlaylists*(api: Audius, query: string,
    onlyDowloadable = false): seq[Playlist] =
  ## Search for a playlist. 
  ## `/playlists/search<https://audiusproject.github.io/api-docs/#search-playlists>`_
  for playlist in api.searchPlaylists(query, onlyDowloadable):
    result.add playlist

iterator tracks*(playlist: Playlist): Track =
  ## Search for a track. 
  ## `/tracks/search<https://audiusproject.github.io/api-docs/#search-tracks>`_
  let query = playlist.api.get("/playlists/" & playlist.id & "/tracks")
  echo $query
  for track in query["data"]:
    var result = fromJson($track, Track)
    result.api = playlist.api
    yield result

proc tracks*(playlist: Playlist): seq[Track] =
  ## Search for a track. 
  ## `/tracks/search<https://audiusproject.github.io/api-docs/#search-tracks>`_
  for track in playlist.tracks:
    result.add track

# User
proc getUser*(api: Audius, id: string): User =
  ## Fetch a single user. 
  ## `/users/{user_id}<https://audiusproject.github.io/api-docs/#get-user>`_
  let query = api.get("/users/" & id & "?app_name=")["data"]
  result = fromJson($query, User)
  result.api = api

iterator searchUsers*(api: Audius, query: string,
    onlyDowloadable = false): User =
  ## Search for a user. 
  ## `/users/search<https://audiusproject.github.io/api-docs/#search-users>`_
  let query = api.get("/users/search?query=" & encodeUrl(query) &
      "&only_downloadable=" & $onlyDowloadable)
  for user in query["data"]:
    var result = fromJson($user, User)
    result.api = api
    yield result

proc searchUsers*(api: Audius, query: string,
    onlyDowloadable = false): seq[User] =
  ## Search for a user. 
  ## `/users/search<https://audiusproject.github.io/api-docs/#search-users>`_
  for user in api.searchUsers(query, onlyDowloadable):
    result.add user

iterator tracks*(user: User): Track =
  ## Fetch a list of tracks for a user. 
  ## `/users/{user_id}/tracks<https://audiusproject.github.io/api-docs/#get-user-39-s-tracks>`_
  let query = user.api.get("/users/" & user.id & "/tracks")
  for track in query["data"]:
    var result = fromJson($track, Track)
    result.api = user.api
    yield result

proc tracks*(user: User): seq[Track] =
  ## Fetch a list of tracks for a user. 
  ## `/users/{user_id}/tracks<https://audiusproject.github.io/api-docs/#get-user-39-s-tracks>`_
  for track in user.tracks:
    result.add track

iterator favorites*(user: User): Track =
  ## Fetch favorited tracks for a user. 
  ## `/users/{user_id}/favorites<https://audiusproject.github.io/api-docs/#get-user-39-s-favorite-tracks>`_
  let query = user.api.get("/users/" & user.id & "/favorites")
  for fav in query["data"]:
    yield user.api.getTrack(fav["favorite_item_id"].getStr)

proc favorites*(user: User): seq[Track] =
  ## Fetch favorited tracks for a user. 
  ## `/users/{user_id}/favorites<https://audiusproject.github.io/api-docs/#get-user-39-s-favorite-tracks>`_
  for track in user.favorites:
    result.add track

iterator reposts*(user: User): Track =
  ## Fetch reposted tracks for a user. 
  ## `/users/{user_id}/reposts<https://audiusproject.github.io/api-docs/#get-user-39-s-reposts>`_
  let query = user.api.get("/users/" & user.id & "/reposts")
  for repost in query["data"]:
    var result = fromJson($repost["item"], Track)
    result.api = user.api
    yield result

proc reposts*(user: User): seq[Track] =
  ## Fetch reposted tracks for a user. 
  ## `/users/{user_id}/reposts<https://audiusproject.github.io/api-docs/#get-user-39-s-reposts>`_
  for track in user.reposts:
    result.add track

iterator tags*(user: User): string =
  ## Warning: This don't work. API is broken !?
  ##
  ## Fetch most used tags in a user's tracks. 
  ## `/users/{user_id}/tags<https://audiusproject.github.io/api-docs/#get-user-39-s-most-used-track-tags>`_
  let query = user.api.get("/users/" & user.id & "/tags")
  for tag in query["data"].getStr.split(','):
    yield tag
