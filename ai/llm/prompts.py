
from langchain_core.prompts import PromptTemplate

USER_CONTEXT_TEMPLATE = """
    The learner, {name} is in grade {grade_level} and prefers a "{learning_style}" learning style.
    Take this into account when designing content, tone, examples, and module type.
"""

lesson_plan_prompt = PromptTemplate.from_template(USER_CONTEXT_TEMPLATE + """

You're an expert curriculum designer for {language}. Create a learning path to help someone learn {topic} from scratch.

The learning path must be structured, clear, and progressive.

Each lesson should have:
- A clear title
- A concise objective
- A list of key concepts covered. These key concepts should break down the core concept and be very detailed

The lessons must be ordered from beginner to advanced.

Respond in structured format only.
""")

chunk_prompt = PromptTemplate.from_template(USER_CONTEXT_TEMPLATE + """
You're an expert curriculum designer for {language}. Design a sequence of 3 to 6 learning chunks to teach the concept "{concept}"

The student is currently {completion_percentage}% done with the lesson.
- If they are just starting (0 to 10%), start with introductory/explanatory chunks.
- If they are midway through (10 to 70%), focus on active practice through code blocks and varied challenge types.
- If they are near the end (70 to 100%), focus on creative application, review, or mastery checks.

For each chunk, specify:
- type: one of "text", "code", "mcq", "short_answer", or "project"
- description: a detailed description of what this stage of the lesson will include (not actual content but a description)


Make the sequence progressive, appropriate for their stage in the lesson, and engaging.

Respond with a JSON list of lesson chunks using the schema:

[
  {{
    "type": "text",
    "description": "Introduce what a loop is and give a real-world analogy"
  }},
  {{
    "type": "code",
    "description": "Write a loop that prints a line 5 times"
  }}
]

Respond ONLY with valid JSON.
""")

module_prompt = PromptTemplate.from_template(USER_CONTEXT_TEMPLATE + """
You are an expert curriculum designer for {language}. Create one learning module based on the key concept "{concept}" for a learner with a "{learning_style}" style.

Make sure text screens cover enough content to fully teach the key concept.

IMPORTANT:
- The user is currently {completion_percentage}% done with the lesson.
- If completion is OVER 5%, DO NOT include any greetings, introductions, or phrases like "Let's dive in", "Welcome", or "Today we’ll learn..."
- Just continue the lesson content without repeating what was already covered.

Return ONLY a valid JSON object matching one of the module schemas.
""")

