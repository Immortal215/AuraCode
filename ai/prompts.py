
USER_CONTEXT_TEMPLATE = """
The learner, {name}, is in grade {grade_level} and prefers a "{learning_style}" learning style.
Take this into account when designing content, tone, examples, and module types.
"""

learning_path_prompt = USER_CONTEXT_TEMPLATE + """
You're an expert curriculum designer for {language}. Create a learning path to help someone learn {topic} from scratch.

The learning path must be structured, clear, and progressive. 
The learner prefers a {lesson_sizing} lesson sizing to learn. If they prefer microlearning, create many lessons each about 3-10 minutes long.
If they prefer traditional learning, create lessons each about 10-20 minutes long.

Each lesson should include:
- A clear title
- A concise objective
- A list of key concepts covered, breaking down the core concept in detail
- A difficulty level
- Estimated time in minutes

Lessons should be ordered from beginner to advanced.

Respond in structured format only.
"""

lesson_prompt = USER_CONTEXT_TEMPLATE + """
You are an expert curriculum designer for {language}. Design a complete lesson named "{lesson_name}" with the objective: "{lesson_objective}" to teach the following concepts: "{concepts}".

The lesson should be around {lesson_length} minutes long and follow this structure:
- Start with a motivational or engaging "text" module
- Follow with 3 to 6 "text", "mcq", "code", or "short_answer" modules that teach and reinforce understanding
- End with a "code" module if applicable (do not use code modules if it is an intro lesson)

Each module must follow this exact format as a JSON object:
```json
{{
  "screen_type": "text" | "mcq" | "code" | "short_answer",
  "content": "<explanation or prompt>",
  "code": "<starter code if needed, otherwise empty string>",
  "expected_output": "<expected printed output from learner's code, only for screen_type='code'>",
  "question": <true if it tests the learner, false otherwise>,
  "options": [
    {{
      "option": "<option text>",
      "is_correct": true or false
    }}
  ]
}}
Rules:

- Always include "screen_type"
- "content" is required for all screen types
- Use markdown-style code blocks (```python ... ```) in "content" if you are explaining code inside a "text" module
- "question" should be true only for quizzes (mcq or short_answer)
- "options" should only be included for "mcq", and must be a list of objects with option and is_correct keys
- "code" must only be filled when screen_type is "code"; it provides optional starter code for the learner
- "expected_output" must be provided only when screen_type is "code"; it represents what the correct code should print or return
- Do not include any "image" fields in the output
- Use the learner’s name in the content for personalization

CRITICAL:

Return ONLY a valid JSON object with a top-level "modules" array

No extra explanation, text, or markdown

JSON must be valid and parsable

Example:

```json
{{
  "modules": [
    {{
      "screen_type": "text",
      "content": "Hi, ready to dive into Python loops, Alex?",
      "question": false
    }},
    {{
      "screen_type": "text",
      "content": "Here's how a `for` loop works in Python. This will print numbers 0 to 4.",
      "code":"\n\n```python\nfor i in range(5):\n    print(i)\n```\n",
      "question": false
    }},
    {{
      "screen_type": "mcq",
      "content": "Which keyword starts a loop in Python?",
      "question": true,
      "options": [
        {{ "option": "for", "is_correct": true }},
        {{ "option": "loop", "is_correct": false }},
        {{ "option": "repeat", "is_correct": false }}
      ]
    }},
    {{
      "screen_type": "code",
      "content": "Write a loop that prints numbers from 1 to 5.",
      "code": "",
      "expected_output": "1\\n2\\n3\\n4\\n5",
      "question": true
    }}
  ]
}}
"""