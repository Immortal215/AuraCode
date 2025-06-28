from llm.base import model
from langchain_chroma import Chroma
from langchain_huggingface import HuggingFaceEmbeddings
from load_docs import load_local_docs_with_tags
from langchain_text_splitters import RecursiveCharacterTextSplitter



# setup vector db
embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-mpnet-base-v2")
vector_store = Chroma(
    collection_name="example_collection",
    embedding_function=embeddings,
    persist_directory="./chroma_langchain_db",
)



# add documents into vector db
if vector_store._collection.count() == 0:
    # Load and split documents
    docs = load_local_docs_with_tags("llm/data/manim")
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
    split_docs = text_splitter.split_documents(docs)
    print(f"Loaded and split {len(split_docs)} document chunks.")

    print("📚 Indexing documents...")
    vector_store.add_documents(split_docs)

def prompt(query: str) -> str:
    relevant_docs = vector_store.similarity_search(query, k=4)
    context_text = "\n\n".join(doc.page_content for doc in relevant_docs)
    prompt_text = f"""
    You are a Manim code assistant.

    Given the following code examples, generate a complete Manim script (latest syntax) that visualizes a for loop.

    Examples:
    {context_text}

    Now write the full script below:
    """
    response = model.invoke(prompt_text)
    return response.content

print(prompt("Write a Manim script that shows a for loop visualized. Use the latest Manim syntax."))