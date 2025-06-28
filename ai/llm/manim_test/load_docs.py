import os
from langchain_core.documents import Document

def load_local_docs_with_tags(root_dir):
    docs = []
    total_files = 0
    tagged_files = 0
    for subdir, _, files in os.walk(root_dir):
        for filename in files:
            total_files += 1
            filepath = os.path.join(subdir, filename)
            ext = os.path.splitext(filename)[1].lower()
            if ext in ('.md', '.txt', '.rst'):
                tag = "manim-docs"
            elif ext == '.py':
                tag = "manim-code"
            else:
                print(f"❌ Skipping unsupported file: {filename}")
                continue  

            try:
                with open(filepath, "r", encoding="utf-8") as f:
                    content = f.read()
                docs.append(Document(page_content=content, metadata={"source": filepath, "type": tag}))
                tagged_files += 1
                print(f"✅ Tagged: {filename} as {tag}")
            except Exception as e:
                print(f"⚠️ Failed to read {filename}: {e}")

    print(f"\n📂 Scanned {total_files} files.")
    print(f"🏷️ Tagged {tagged_files} documents for processing.\n")
    return docs
