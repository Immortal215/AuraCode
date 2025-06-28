
from llm.base import UserContext
from llm.learning_path import LessonOverview
from llm.lesson_module import LessonState, choose_module


user_context = UserContext(
    name="Jamie",
    grade_level="5",
    learning_style="visual",
)

# Sample LessonOverview
lesson_overview = LessonOverview(
    title="Mastering Loops",
    objective="Understand and apply different kinds of loops in Python",
    key_concepts=["what is a loop", "for loop basics", "range function", "nested loops"],
    difficulty=2,
    estimated_time=30
)

# Sample LessonState
lesson_state = LessonState(
    lesson_overview=lesson_overview,
    lesson_chunks=[],
    completion_percentage="25",
    current_key_concept=1 
)

# Now, call your choose_module function
choose_module(lesson_state, language="python", user_context=user_context)