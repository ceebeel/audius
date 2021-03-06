<div align="center">
  <img width="128px" src="https://github.com/ceebeel/audius/raw/master/audius.nim.svg"></img>
  <h1>Nim Audius API Library</h1>
  <p>A simple client library for interacting with the Audius free API. (audius.org)</p>


[![Build Status](https://nimble.directory/ci/badges/audius/nimdevel/status.svg)](https://nimble.directory/ci/badges/audius/nimdevel/output.html)
[![Build Status](https://nimble.directory/ci/badges/audius/nimdevel/docstatus.svg)](https://nimble.directory/ci/badges/audius/nimdevel/doc_build_output.html)
[![Build Status](https://nimble.directory/ci/badges/audius/version.svg)](https://nimble.directory/ci/badges/audius/nimdevel/doc_build_output.html)
</div>


\
Check the module [documentation](https://ceebeel.github.io/audius/).
The official API documentation can be found [here](https://audiusproject.github.io/api-docs/#audius-api-docs).

## Installation
```
nimble install audius
```

## Example
```nim
import audius

#Create new audius client.
let client = newAudius()

# Search users.
for user in client.searchUsers("Brownies"):
  echo "User: " & user.name

# Create new user by id.
let user = client.getUser("nlGNe")

# List user's tracks.
for track in user.tracks:
  echo "Track: " & track.title

# List user's favorite tracks.
for favorite in user.favorites:
  echo "Favorite: " & favorite.title

# List user reposted tracks.
for repost in user.reposts:
  echo "Repost: " & repost.title

# List common user's tags.
for tag in user.tags:
  echo "Tag: " & tag

# Search playlists
for playlist in client.searchPlaylists("Hot & New"):
  echo "Palylist: " & playlist.playlistName

# Create new playlist by id.
let playlist = client.getPlaylist("DOPRl")

# List tracks in playlist.
for track in playlist.tracks:
  echo "Playlist Track: " & track.title
```
## Compilation 
- Use SSL:
```nim r -d:ssl examples/simple.nim```
- Add [cacert.pem](bin/cacert.pem) in your running directory.
