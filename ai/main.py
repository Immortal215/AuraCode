from fastapi import Depends, FastAPI
from pydantic import BaseModel
from firebase_util import verify_firebase_token, firestore_db
from ai import generate_learning_path, generate_lesson
from schemas import LessonOverview, LearningPath

app = FastAPI()

class LearningPathRequest(BaseModel):
    topic: str


@app.post("/create_learning_path")
def create_learning_path(data: LearningPathRequest, uid: str = Depends(verify_firebase_token)):
    learn_path_model = generate_learning_path(topic=data.topic, user_uid=uid)
    doc_ref = firestore_db.collection("users").document(uid).collection("learning_paths").document()
    doc_ref.set(learn_path_model.model_dump(mode="json"))
    return {"success": True, "learning_path_id": doc_ref.id}


class LessonRequest(BaseModel):
    learning_path_id: str
    lesson_index: int
    
@app.post("/create_lesson")
def create_lesson(data: LessonRequest, uid: str = Depends(verify_firebase_token)):
    path_ref = firestore_db.collection("users").document(uid).collection("learning_paths").document(data.learning_path_id)
    doc_ref = firestore_db.collection("users").document(uid) \
        .collection("learning_paths").document(data.learning_path_id) \
        .collection("modules").document(str(data.lesson_index))
    
    learning_path = path_ref.get()
    if not learning_path:
        return {"success":False}
    
    lesson_data = learning_path.to_dict()["lessons"][data.lesson_index]
    lesson_overview_object = LessonOverview.parse_obj(lesson_data)
    lesson_model = generate_lesson(lesson_overview=lesson_overview_object, user_uid=uid)

    doc_ref.set(lesson_model.model_dump(mode="json"))

    return {"success": True, "modules": lesson_model.modules}
