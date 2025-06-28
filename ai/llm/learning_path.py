from pydantic import BaseModel, Field
from .base import  UserContext, model
from .prompts import lesson_plan_prompt
from typing import List

# Learning Path schemas
class LessonOverview(BaseModel):
    title: str = Field(..., description="Title of the lesson")
    objective: str = Field(..., description="Objective of the lesson")
    key_concepts: List[str] = Field(..., description="A list of key concepts taught in the lesson")
    difficulty: int = Field(..., ge=1, le=5, description="Difficulty level from 1 (easy) to 5 (hard)")
    estimated_time: int = Field(..., description="Estimated time to complete the lesson in minutes")
    
class LearningPath(BaseModel):
    name: str = Field(..., description="Name of lesson plan")
    lessons: List[LessonOverview] = Field(...,     description="List of lessons in the exact order they should be taught, from start to finish")

lesson_plan_model = model.with_structured_output(LearningPath)
# creating a learning path
def createLearningPath(topic: str, language:str, user_context: UserContext):
    query = lesson_plan_prompt.format(
        topic=topic,
        language=language,
        name=user_context.name,
        grade_level=user_context.grade_level,
        learning_style=user_context.learning_style,
    )
    result = lesson_plan_model.invoke(query)
    return result
