from fastapi import FastAPI, HTTPException

app = FastAPI()

items = {
    "foo": "The Foo Wrestlers", 
    "bar": "The Bar Fighters", 
    "baz": "The Baz Brawlers", 
    "qux": "The Qux Quarrelers", 
    "quux": "The Quux Questers", 
    "corge": "The Corge Champions", 
    "grault": "The Grault Gladiators", 
    "garply": "The Garply Guardians", 
    "waldo": "The Waldo Warriors", 
    "fred": "The Fred Fighters", 
    "plugh": "The Plugh Protectors", 
    "xyzzy": "The Xyzzy Xenophobes", 
    "thud": "The Thud Titans"
}

@app.get("/")
async def root():
    return {"message": "Hello World"}

# 1. Updated /items endpoint to allow optional name filtering
@app.get("/items")
async def read_items(name: str = None):
    if name:
        # Performs a case-insensitive partial match search on the dictionary values
        filtered_items = {
            key: value for key, value in items.items() 
            if name.lower() in value.lower()
        }
        return filtered_items
    return items

@app.get("/items/{item_id}")
async def read_item(item_id: str, q: str = None):
    if item_id in items:
        return {"item_id": item_id, "q": q, "item_name": items[item_id]}
    raise HTTPException(status_code=404, detail="Item not found")
