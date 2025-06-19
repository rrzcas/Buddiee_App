# Study Buddy Backend

This is the backend service for the Study Buddy app, handling Reddit post scraping using PRAW.

## Setup

1. Create a Reddit API application:
   - Go to https://www.reddit.com/prefs/apps
   - Click "Create App" or "Create Another App"
   - Fill in the details:
     - Name: Study Buddy App
     - Type: Script
     - Description: Study buddy finder app
     - About URL: (leave blank)
     - Redirect URI: http://localhost:8000
   - Click "Create app"
   - Note down the client ID and client secret

2. Set up environment variables:
   - Copy `.env.example` to `.env`
   - Fill in your Reddit API credentials:
     ```
     REDDIT_CLIENT_ID=your_client_id_here
     REDDIT_CLIENT_SECRET=your_client_secret_here
     REDDIT_USER_AGENT=study_buddy_app/1.0
     ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Run the server:
   ```bash
   python reddit_scraper.py
   ```

The server will start on http://localhost:8000

## API Endpoints

### GET /posts
Returns a list of study buddy posts from Reddit.

Response format:
```json
[
  {
    "id": "string",
    "title": "string",
    "description": "string",
    "image_urls": ["string"],
    "user": {
      "id": "string",
      "username": "string",
      "profile_image": "string",
      "location": "string",
      "bio": "string"
    },
    "category": "string",
    "location": "string",
    "source": "string",
    "original_url": "string",
    "created_at": "datetime",
    "is_private": boolean,
    "is_pinned": boolean,
    "is_online": boolean,
    "comments": []
  }
]
```

## Features

- Scrapes study buddy posts from multiple subreddits
- Filters posts from the last 3 months
- Extracts location information
- Determines if posts are for online or in-person study
- Handles rate limiting automatically
- Provides a REST API for the iOS app 