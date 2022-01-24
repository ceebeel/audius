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