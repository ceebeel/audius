import audius

# Create new Audius client.
let client = newAudius()

# Search users.
for user in client.searchUsers("Brownies"):
  echo "User found: " & user.name

# Create new user by id.
let user = client.getUser("nlGNe")
echo "User name: " & user.name &
    " Profile Picture: " & user.profilePicture.small

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
for playlist in client.searchPlaylists("Hot & New"):
  echo "Palylist found: " & playlist.playlistName

# Create new playlist by id.
let playlist = client.getPlaylist("DOPRl")
echo "Playlist name: " & playlist.playlistName

# List tracks in playlist.
for track in playlist.tracks:
  echo "Playlist's Track: " & track.title
