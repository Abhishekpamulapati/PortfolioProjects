# 🎧 Spotify API Batch Processing Toolkit

A robust and scalable toolkit for batch processing operations using the Spotify Web API. This project simplifies authentication, handles token lifecycle, and extracts paginated data from Spotify endpoints—perfect for anyone aiming to automate content curation or build data-driven music apps.

---

## ✨ Highlights

- 🎚️ Quick setup through the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)  
- 🔑 Secure OAuth2 credential and token management  
- 📦 Paginated fetching of:  
  - `/v1/browse/new-releases`  
  - `/v1/albums`  
- 🧭 Modular codebase with clear instructions and extendable architecture  
- 🧪 Environment variable management using `python-dotenv`  
- 🧩 Clean separation of concerns via `authentication.py`, `endpoint.py`, and `main.py`

---

## 🛠️ Getting Started

### 1. Register Your Spotify App

Create an app [here](https://developer.spotify.com/dashboard) to generate credentials:

- **Client ID**  
- **Client Secret**  
- **Redirect URI**

---

### 2. Clone and Configure

```bash
git clone https://github.com/<your-username>/<your-repository>.git
cd <your-repository>
```
### 3. 🔧 Environment Setup
Create a .env file inside the src/ directory with the following content:

CLIENT_ID=your_spotify_client_id

CLIENT_SECRET=your_spotify_client_secret

APP_NAME=SpotifyAPPName


Read Spotify API documentation for more details on these parameters.:

Follow the instructions in `placeholder.ipynb` to install dependencies and set up your environment.



### 4. 🎯 Usage Overview
🔐 Authentication Module (authentication.py)
Handles OAuth2 token generation and refresh logic:
from authentication import get_token
import os

token = get_token(
    client_id=os.getenv("CLIENT_ID"),
    client_secret=os.getenv("CLIENT_SECRET"),
    url="https://accounts.spotify.com/api/token"
)


📡 Endpoint Module (endpoint.py)
Fetches paginated data from Spotify endpoints:
from endpoint import get_paginated_new_releases, get_paginated_album_tracks

new_releases = get_paginated_new_releases(
    base_url="https://api.spotify.com/v1/browse/new-releases",
    access_token=token["access_token"],
    get_token=get_token,
    client_id=os.getenv("CLIENT_ID"),
    client_secret=os.getenv("CLIENT_SECRET"),
    url="https://accounts.spotify.com/api/token"
)


🌱 Environment Loader (main.py)
Loads credentials from .env using python-dotenv:
from dotenv import load_dotenv

load_dotenv(dotenv_path="./src/.env", override=True)



### 5. 🔄 Pagination Engine
Built-in support for paginated data processing with smart retries and rate limit awareness.
Example:
from spotify_batch import SpotifyBatchClient

client = SpotifyBatchClient()
new_releases = client.get_new_releases(pages=5)
albums_data = client.get_albums_by_ids(album_ids)



### 6. 📘 Documentation
Detailed step-by-step instructions and usage scenarios can be found in placeholder.ipynb.

🤝 Thank you for checking it out!
Feel free to fork, practice, or reach out with questions.

