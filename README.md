# Audius
Audius is a simple client library for interacting with the Audius protocol. (audius.org)
`nimble install audius`

# Example
'''
import audius

#Create new audius client.
let audius = newAudius()

# Search users.
for user in audius.searchUsers("Brownies"):
  echo "User: " & user.schema.name

# Create new user by id.
let user = audius.getUser("nlGNe")

# List user's tracks.
for track in user.tracks:
  echo "Track: " & track.schema.title

# List user's favorite tracks.
for favorite in user.favorites:
  echo "Favorite: " & favorite.schema.title

# List user reposted tracks.
for repost in user.reposts:
  echo "Repost: " & repost.schema.title

# List common user's tags.
for tag in user.tags:
  echo "Tag: " & tag

# Search playlists
for playlist in audius.searchPlaylists("Hot & New"):
  echo "Palylist: " & playlist.schema.playlist_name

# Create new playlist by id.
let playlist = audius.getPlaylist("DOPRl")

# List tracks in playlist.
for track in playlist.tracks:
  echo "Playlist Track: " & track.schema.title
'''

