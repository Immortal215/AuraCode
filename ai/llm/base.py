from dotenv import load_dotenv
from langchain_google_genai import ChatGoogleGenerativeAI
import os
from pydantic import BaseModel


# load api keys
load_dotenv()

# load llm
google_api_key = os.getenv("GOOGLE_GENERATIVE_AI_API_KEY")
if not google_api_key:
    raise ValueError("Missing GOOGLE_GENERATIVE_AI_API_KEY")
model = ChatGoogleGenerativeAI(model="gemini-1.5-flash", google_api_key=google_api_key)

class UserContext(BaseModel):
    name:str
    grade_level: str
    learning_style: str