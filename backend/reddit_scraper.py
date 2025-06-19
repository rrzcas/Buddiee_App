import os
import praw
from datetime import datetime, timedelta
from typing import List, Dict, Any
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import time
from prawcore.exceptions import TooManyRequests

# Load environment variables from the backend directory
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '.env'))

# Initialize Reddit client
reddit = praw.Reddit(
    client_id=os.getenv("REDDIT_CLIENT_ID"),
    client_secret=os.getenv("REDDIT_CLIENT_SECRET"),
    user_agent=os.getenv("REDDIT_USER_AGENT")
)

app = FastAPI()

# Rate limit tracking
class RateLimitTracker:
    def __init__(self):
        self.requests_this_minute = 0
        self.last_reset = datetime.utcnow()
        self.max_requests_per_minute = 60
    
    def increment(self):
        now = datetime.utcnow()
        if (now - self.last_reset).total_seconds() >= 60:
            self.requests_this_minute = 0
            self.last_reset = now
        self.requests_this_minute += 1
        return self.requests_this_minute
    
    def get_remaining(self):
        now = datetime.utcnow()
        if (now - self.last_reset).total_seconds() >= 60:
            return self.max_requests_per_minute
        return max(0, self.max_requests_per_minute - self.requests_this_minute)
    
    def get_reset_time(self):
        return self.last_reset + timedelta(minutes=1)

rate_tracker = RateLimitTracker()

class Post(BaseModel):
    id: str
    title: str
    description: str
    image_urls: List[str]
    user: Dict[str, Any]
    category: str
    location: str
    source: str
    original_url: str
    created_at: datetime
    is_private: bool
    is_pinned: bool
    is_online: bool
    comments: List[Dict[str, Any]]

def extract_location(text: str) -> str:
    """Extract location from post text."""
    london_keywords = [
        "london", "central london", "east london", "west london",
        "north london", "south london", "greater london"
    ]
    
    text_lower = text.lower()
    for keyword in london_keywords:
        if keyword in text_lower:
            return keyword.title()
    return "London, UK"  # Default location

def is_study_related(text: str) -> bool:
    """Check if post is study-related."""
    study_keywords = [
        "study", "studying", "student", "university", "college",
        "exam", "exam", "course", "lecture", "tutorial",
        "library", "campus", "academic", "research", "assignment",
        "revision", "dissertation", "masters", "phd", "bachelor"
    ]
    
    text_lower = text.lower()
    return any(keyword in text_lower for keyword in study_keywords)

def is_online_post(text: str) -> bool:
    """Check if post is for online study."""
    online_keywords = [
        "online", "virtual", "remote", "zoom", "teams",
        "discord", "skype", "webcam", "video call"
    ]
    
    text_lower = text.lower()
    return any(keyword in text_lower for keyword in online_keywords)

def handle_rate_limit(func):
    """Decorator to handle rate limiting with exponential backoff."""
    def wrapper(*args, **kwargs):
        max_retries = 3
        base_delay = 2  # Start with 2 seconds delay
        
        for attempt in range(max_retries):
            try:
                return func(*args, **kwargs)
            except TooManyRequests as e:
                if attempt == max_retries - 1:
                    raise HTTPException(status_code=429, detail="Reddit rate limit exceeded")
                
                delay = base_delay * (2 ** attempt)  # Exponential backoff
                print(f"Rate limit hit. Waiting {delay} seconds before retry...")
                time.sleep(delay)
        
        return None
    return wrapper

@app.get("/posts")
@handle_rate_limit
async def get_posts():
    """Get study buddy posts from Reddit."""
    try:
        # Calculate date 3 months ago
        three_months_ago = datetime.utcnow() - timedelta(days=90)
        
        # Target subreddits - focused on study-related subreddits
        subreddits = [
            "studybuddy", "studybuddyLondon", "londonstudybuddy",
            "studybuddyUK", "studybuddyuk", "studybuddy_london",
            "studybuddy_london_uk", "UniUK", "london", "londonuk",
            "londonstudents", "UCL", "Imperial", "KCL", "LSE",
            "Birkbeck", "CityUniversity", "SOAS", "RoyalHolloway", "Brunel",
            "Greenwich", "Westminster", "Kingston", "Roehampton", "Middlesex",
            "LondonMetropolitan", "ukstudents", "ukuni", "londoncommunity"
        ]
        
        # Keywords to exclude
        exclude_keywords = [
            "language", "french", "spanish", "german", "italian", "portuguese", "russian",
            "chinese", "japanese", "korean", "arabic", "hindi", "urdu", "bengali",
            "turkish", "dutch", "swedish", "norwegian", "danish", "polish", "greek",
            "job", "jobs", "work", "hiring", "internship", "intern", "career", "careers",
            "rent", "flatmate", "housing", "accommodation", "room", "rooms", "house", "houses"
        ]
        
        # Search queries optimized for study buddy posts
        search_queries = [
            "\"study partner\" london",
            "\"study buddy\" london",
            "\"study group\" london",
            "\"looking for study partner\" london",
            "\"need study partner\" london",
            "\"want study partner\" london",
            "\"study together\" london",
            "\"study session\" london",
            "\"revision partner\" london",
            "\"accountability partner\" london"
        ]
        
        all_posts = []
        filtered_debug_info = []
        
        # Set limits and thresholds
        max_total_posts = 50  # Maximum posts to collect
        posts_per_query = 10  # Posts per search query
        min_success_rate = 0.1  # Minimum 10% success rate to continue
        max_consecutive_failures = 3  # Stop after 3 consecutive subreddits with no posts
        max_requests_per_session = 200  # Maximum requests per session
        
        print(f"\nRate Limit Status:")
        print(f"Starting with {rate_tracker.get_remaining()} requests remaining in current window")
        print(f"Window resets at: {rate_tracker.get_reset_time()}")
        
        total_requests = 0
        consecutive_failures = 0
        successful_posts = 0
        
        for subreddit_name in subreddits:
            if len(all_posts) >= max_total_posts:
                print(f"Backend: Reached max_total_posts limit ({max_total_posts}), stopping further scraping.")
                break
                
            if total_requests >= max_requests_per_session:
                print(f"Backend: Reached maximum requests per session ({max_requests_per_session}), stopping.")
                break
                
            if consecutive_failures >= max_consecutive_failures:
                print(f"Backend: {max_consecutive_failures} consecutive subreddits with no posts, stopping.")
                break
                
            print(f"\nBackend: Starting search in r/{subreddit_name}")
            subreddit_success = False
            
            try:
                subreddit = reddit.subreddit(subreddit_name)
                
                # Use specific search queries instead of broad search
                for query in search_queries:
                    if len(all_posts) >= max_total_posts:
                        break
                        
                    if total_requests >= max_requests_per_session:
                        break
                        
                    print(f"  Searching with query: {query}")
                    print(f"  Rate Limit: {rate_tracker.get_remaining()} requests remaining")
                    
                    try:
                        query_posts = 0
                        for submission in subreddit.search(
                            query,
                            sort="new",
                            time_filter="month",
                            limit=posts_per_query
                        ):
                            total_requests += 1
                            requests_made = rate_tracker.increment()
                            
                            if requests_made % 10 == 0:
                                print(f"  Rate Limit: {rate_tracker.get_remaining()} requests remaining")
                            
                            if len(all_posts) >= max_total_posts:
                                break
                                
                            print(f"  Processing post: \"{submission.title}\" (ID: {submission.id})")
                            print(f"    Posted: {datetime.fromtimestamp(submission.created_utc)}")
                            
                            full_content = (submission.title + " " + submission.selftext).lower()
                            
                            # Check if post is recent
                            is_recent = datetime.fromtimestamp(submission.created_utc) >= three_months_ago
                            print(f"    Is recent (within 3 months)? {is_recent}")
                            if not is_recent:
                                print("    Filtered out: Post is too old.")
                                filtered_debug_info.append({"title": submission.title, "reason": "Too old"})
                                continue
                            
                            # Check for general study-relatedness
                            has_general_study_relevance = is_study_related(full_content)
                            print(f"    Has general study relevance? {has_general_study_relevance}")
                            if not has_general_study_relevance:
                                print("    Filtered out: Not generally study-related.")
                                filtered_debug_info.append({"title": submission.title, "reason": "Not study-related"})
                                continue
                            
                            # Exclude unwanted keywords
                            is_excluded = any(keyword in full_content for keyword in exclude_keywords)
                            print(f"    Is excluded by keywords? {is_excluded}")
                            if is_excluded:
                                print("    Filtered out: Contains excluded keywords.")
                                filtered_debug_info.append({"title": submission.title, "reason": "Contains excluded keywords"})
                                continue
                            
                            # Determine if online
                            is_online_post_detected = is_online_post(full_content)
                            print(f"    Is an online post detected? {is_online_post_detected}")
                            
                            # Extract location
                            location = extract_location(full_content)
                            
                            # Create post object
                            image_url = submission.url if submission.url.endswith(('.jpg', '.png', '.jpeg', '.gif')) or "i.redd.it" in submission.url else ""
                            
                            all_posts.append(Post(
                                id=submission.id,
                                title=submission.title,
                                description=submission.selftext,
                                image_urls=[image_url] if image_url else [],
                                user={
                                    "id": submission.author.id if submission.author else "deleted",
                                    "username": submission.author.name if submission.author else "deleted",
                                    "profile_image": "person.circle.fill",
                                    "location": location,
                                    "bio": ""
                                },
                                category="study",
                                location=location,
                                source="reddit",
                                original_url=f"https://reddit.com{submission.permalink}",
                                created_at=datetime.fromtimestamp(submission.created_utc),
                                is_private=False,
                                is_pinned=False,
                                is_online=is_online_post_detected,
                                comments=[]
                            ))
                            print(f"    Post PASSED all filters! Added: \"{submission.title}\"")
                            query_posts += 1
                            successful_posts += 1
                            subreddit_success = True
                            
                            # Respect rate limits
                            time.sleep(1)
                            
                        # Check success rate for this query
                        if query_posts == 0:
                            print(f"  No posts found for query: {query}")
                            if total_requests > 20 and successful_posts / total_requests < min_success_rate:
                                print(f"  Success rate too low ({successful_posts/total_requests:.2%}), stopping.")
                                break
                            
                    except TooManyRequests:
                        reset_time = rate_tracker.get_reset_time()
                        print(f"Rate limit hit! Window resets at: {reset_time}")
                        print("Waiting 60 seconds...")
                        time.sleep(60)
                        continue
                    except Exception as e:
                        print(f"Error processing query {query}: {str(e)}")
                        continue
                        
            except Exception as e:
                print(f"Backend: Error processing subreddit {subreddit_name}: {str(e)}")
                filtered_debug_info.append({"title": "Subreddit Error", "reason": f"Error in r/{subreddit_name}: {str(e)}"})
                continue
                
            # Update consecutive failures counter
            if not subreddit_success:
                consecutive_failures += 1
            else:
                consecutive_failures = 0
        
        # Deduplicate posts
        unique_posts_map = {post.id: post for post in all_posts}
        unique_posts = list(unique_posts_map.values())
        print(f"Backend: Deduplicated to {len(unique_posts)} unique posts.")
        
        # Sort posts by creation date
        sorted_posts = sorted(unique_posts, key=lambda p: p.created_at, reverse=True)
        print(f"Backend: Final count of successful posts: {len(sorted_posts)}")
        
        # Prepare status message
        status_message = f"""
Session Statistics:
Total requests made: {total_requests}
Successful posts: {successful_posts}
Success rate: {successful_posts/total_requests:.2%}

Stopping reason: {
    "Reached maximum posts limit (50)" if len(sorted_posts) >= max_total_posts
    else "Reached maximum requests (200)" if total_requests >= max_requests_per_session
    else "Success rate too low (<10%)" if total_requests > 20 and successful_posts/total_requests < min_success_rate
    else "Too many consecutive failures (3)" if consecutive_failures >= max_consecutive_failures
    else "Completed successfully"
}
"""
        
        print(f"\nFinal Rate Limit Status:")
        print(f"Made {rate_tracker.requests_this_minute} requests in current window")
        print(f"{rate_tracker.get_remaining()} requests remaining")
        print(f"Window resets at: {rate_tracker.get_reset_time()}")
        print(status_message)
        
        return {
            "success_posts": sorted_posts, 
            "filtered_debug_info": filtered_debug_info,
            "status_message": status_message,
            "is_complete": True
        }
        
    except Exception as e:
        error_message = f"Error occurred: {str(e)}"
        print(error_message)
        return {
            "success_posts": [],
            "filtered_debug_info": [],
            "status_message": error_message,
            "is_complete": True
        }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 