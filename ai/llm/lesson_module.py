from pydantic import BaseModel, Field
from .base import  UserContext, model
from .prompts import  module_prompt, chunk_prompt
from .learning_path import LessonOverview
from typing import List, Literal, Any

# Lesson state for adaptive module creation
class LessonState(BaseModel):
    lesson_overview: LessonOverview
    lesson_chunks : List[Any]
    completion_percentage: str
    current_key_concept:int

# Lessons are broken down into chunks and then new chunks are created 
class LessonChunkPlan(BaseModel):
    type: Literal["text", "code", "mcq", "short_answer"]
    description: str = Field(..., description="A basic description of what should happen on this screen")
class LessonChunkSequence(BaseModel):
    sequence: List[LessonChunkPlan]
    
# Each module screen
class TextScreen(BaseModel):
    content: str = Field(..., description="Textual explanation or content to teach the concept")
    image: str = Field(
        ..., 
        description="A short image search query (not a URL) that could be used to find a relevant illustration for the content"
    )

class MCQOption(BaseModel):
    option: str = Field(..., description="Option text for the MCQ")
    is_correct: bool = Field(..., description="Indicates if this option is the correct answer")

class MCQScreen(BaseModel):
    question: str = Field(..., description="The MCQ question to be answered")
    options: List[MCQOption] = Field(..., description="List of options for the MCQ with correctness marked")

class CodeScreen(BaseModel):
    code: str = Field(..., description="The code to be written")
    hints: List[str] = Field(..., description="List of guiding hints to help the user")

class ShortAnswerScreen(BaseModel):
    prompt: str = Field(..., description="The question prompt for the short answer")
    expected_answer: str = Field(..., description="The expected short answer for validation")

short_answer_model = model.with_structured_output(ShortAnswerScreen)
mcq_model = model.with_structured_output(MCQScreen)
text_model = model.with_structured_output(TextScreen)
code_model = model.with_structured_output(CodeScreen)

# creating a module
def create_module(concept: str, language: str, completion_percentage: str, user_context: UserContext, module_type: str ):
    query = module_prompt.format(
        concept=concept,
        completion_percentage=completion_percentage,
        language=language,
        name=user_context.name,
        grade_level=user_context.grade_level,
        learning_style=user_context.learning_style,
    )

    chosen_model = None
    if module_type == "mcq":
        chosen_model = mcq_model
    elif module_type == "text":
        chosen_model = text_model
    elif module_type == "short_answer":
        chosen_model = short_answer_model
    elif module_type == "code":
        chosen_model = code_model
    else:
        raise ValueError(f"Unsupported module_type: {module_type}")

    response = chosen_model.invoke(query)
    return response


chunk_model = model.with_structured_output(LessonChunkSequence)
def choose_module(state: LessonState,  language: str, user_context: UserContext):
    current_index = state.current_key_concept
    concept = state.lesson_overview.key_concepts[current_index]

    # Format the prompt for chunk sequence
    query = chunk_prompt.format(
        concept=concept,
        language=language,
        name=user_context.name,
        grade_level=user_context.grade_level,
        learning_style=user_context.learning_style,
        completion_percentage=state.completion_percentage
    )

    chunk_sequence = chunk_model.invoke(query)
    print(chunk_sequence)
