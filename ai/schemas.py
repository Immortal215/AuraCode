
from typing import List, Literal, Optional
from pydantic import BaseModel, Field
from firebase_util import get_firebase_user, get_user_data

# adding changebillity per user
class UserContext(BaseModel):
    name:str
    grade_level: str
    learning_style: str
    lesson_sizing: str

# actual content
class Option(BaseModel):
    option: str = Field(..., description="Text of the answer option")
    is_correct: bool = Field(..., description="True if this option is the correct answer")

class Module(BaseModel):
    screen_type: Literal["text", "mcq", "code", "short_answer"] = Field(..., description="Type of module screen")
    content: str = Field(..., description="Textual content or instruction")
    image: Optional[str] = Field(None, description="Optional image description (only for 'text' screens)")
    code: Optional[str] = Field(None, description="Optional code snippet (only for 'code' screens)")
    question: bool = Field(..., description="Indicates if the module tests the learner")
    options: Optional[List[Option]] = Field(
        None,
        description="List of options (only for 'mcq'). Each option has text and correctness"
    )

class LessonContent(BaseModel):
    modules:List[Module] = Field( description="List of modules needed")

# For learning path
class LessonOverview(BaseModel):
    title: str = Field( description="Title of the lesson")
    objective: str = Field( description="Objective of the lesson")
    key_concepts: List[str] = Field( description="A list of key concepts taught in the lesson")
    difficulty: int = Field( ge=1, le=5, description="Difficulty level from 1 (easy) to 5 (hard)")
    estimated_time: int = Field( description="Estimated time to complete the lesson in minutes")
    
class LearningPath(BaseModel):
    name: str = Field( description="Name of lesson plan")
    lessons: List[LessonOverview] = Field(     description="List of lessons in the exact order they should be taught, from start to finish")
    
def get_user_context(uid:str):
    user_record = get_firebase_user(uid)
    user_data = get_user_data(uid)

    return UserContext(
        name=user_record.display_name or "Unknown", 
        grade_level="6", 
        learning_style=user_data["learningStyle"], 
        lesson_sizing=user_data["lessonSizing"]
    )