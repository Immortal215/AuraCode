from google import genai
from prompts import lesson_prompt, learning_path_prompt
from schemas import LessonContent, LearningPath, LessonOverview, get_user_context
from dotenv import load_dotenv
import os

load_dotenv()
api_key = os.getenv("GENAI_API_KEY")  
client = genai.Client(api_key=api_key)

def generate_content(prompt, schema, model_id = "gemini-1.5-flash"):
	response = client.models.generate_content(model=model_id, contents=prompt, config={"response_mime_type":"application/json", "response_schema":schema})
	return (response.text)

def generate_lesson(user_uid:str, lesson_overview:LessonOverview):
	user_context = get_user_context(user_uid)
	formatted_prompt = lesson_prompt.format(
		name=user_context.name,
		grade_level=user_context.grade_level,
		learning_style=user_context.learning_style,
		language="Python",
		lesson_name=lesson_overview.title,
		lesson_objective=lesson_overview.objective,
		concepts=lesson_overview.key_concepts,
		lesson_length=lesson_overview.estimated_time
	)
	json_str = generate_content(formatted_prompt, LessonContent)
	print(json_str)
	lesson_obj = LessonContent.model_validate_json(json_str)
	return lesson_obj

def generate_learning_path(user_uid:str, topic:str):
	user_context = get_user_context(user_uid)
	formatted_prompt = learning_path_prompt.format(
		name=user_context.name,
		grade_level=user_context.grade_level,
		learning_style=user_context.learning_style,
		lesson_sizing=user_context.lesson_sizing,
		language="Python",
		topic=topic
	)
	
	json_str = generate_content(formatted_prompt, LearningPath)
	print(json_str)
	LearningPath_obj = LearningPath.model_validate_json(json_str)

	return LearningPath_obj
