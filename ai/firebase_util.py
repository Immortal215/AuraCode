import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import Header, HTTPException, status
from firebase_admin import auth


# setting up firebase app
cred = credentials.Certificate("firebase.json")
firebase_admin.initialize_app(cred, {
    'databaseURL':'https://auracode-8c2ed-default-rtdb.firebaseio.com/'
})

# setting up firestore client
firestore_db = firestore.client()

# middleware to verify auth
def verify_firebase_token(authorization: str = Header(None)) -> str:
    if not authorization:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Authorization header missing")

    parts = authorization.split()
    if len(parts) != 2 or parts[0].lower() != "bearer":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid authorization header format")

    id_token = parts[1]

    try:
        decoded_token = auth.verify_id_token(id_token)
        return decoded_token['uid']
    except Exception:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired token")

def get_firebase_user(uid: str):
    try:
        user_record = auth.get_user(uid)
        return user_record
    except auth.UserNotFoundError:
        print(f"No user found for UID: {uid}")
        return None
    except Exception as e:
        print(f"Error fetching user: {e}")
        return None
    
def get_user_data(uid: str):
    doc_ref = firestore_db.collection("users").document(uid)
    doc = doc_ref.get()
    if doc.exists:
        print(doc.to_dict())  
        return doc.to_dict()
    else:
        print("No such document!")
        return None
