from typing import List, Literal, Optional
from pydantic import BaseModel, Field, root_validator
from firebase_util import get_firebase_user, get_user_data

# User Context Moodel
class UserContext(BaseModel):
    name: str
    grade_level: str
    learning_style: str
    lesson_sizing: str

# Answer options for MCQ
class Option(BaseModel):
    option: str = Field(..., description="Text of the answer option")
    is_correct: bool = Field(..., description="True if this option is the correct answer")

# Basic Module
class Module(BaseModel):
    screen_type: Literal["text", "mcq", "code", "short_answer"] = Field(..., description="Type of module screen")
    content: str = Field(..., description="Textual content or instruction for the learner")
    code: Optional[str] = Field(None, description="Optional starter code (do not use if module is meant to be a question)")
    expected_output: Optional[str] = Field(None, description="Expected output of the learner's code (required for 'code' screens)")
    question: bool = Field(..., description="Indicates if the module tests the learner")
    options: Optional[List[Option]] = Field(
        None,
        description="List of answer options (only used for 'mcq' screens)"
    )

# List of Modules in a lesson
class LessonContent(BaseModel):
    modules: List[Module] = Field(..., description="List of lesson modules")

# Metadata for a single lesson
class LessonOverview(BaseModel):
    title: str = Field(..., description="Title of the lesson")
    objective: str = Field(..., description="Objective of the lesson")
    key_concepts: List[str] = Field(..., description="Key concepts covered in the lesson")
    difficulty: int = Field(..., ge=1, le=5, description="Difficulty from 1 (easy) to 5 (hard)")
    estimated_time: int = Field(..., description="Estimated time to complete the lesson in minutes")

# Learning Path Schema
class LearningPath(BaseModel):
    name: str = Field(..., description="Name of the learning path")
    lessons: List[LessonOverview] = Field(..., description="Ordered list of lessons")

# User context resolver
def get_user_context(uid: str):
    user_record = get_firebase_user(uid)
    user_data = get_user_data(uid)

    return UserContext(
        name=user_record.display_name or "Unknown",
        grade_level="6",
        learning_style=user_data["learningStyle"],
        lesson_sizing=user_data["lessonSizing"]
    )
