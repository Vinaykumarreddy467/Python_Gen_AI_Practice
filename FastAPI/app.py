from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}

items={"foo": "The Foo Wrestlers", "bar": "The Bar Fighters", "baz": "The Baz Brawlers", "qux": "The Qux Quarrelers", "quux": "The Quux Questers", "corge": "The Corge Champions", "grault": "The Grault Gladiators", "garply": "The Garply Guardians", "waldo": "The Waldo Warriors", "fred": "The Fred Fighters", "plugh": "The Plugh Protectors", "xyzzy": "The Xyzzy Xenophobes", "thud": "The Thud Titans"}
@app.get("/items/{item_id}")
async def read_item(item_id: int, q: str = None):
    if item_id in items:
        return {"item_id": item_id, "q": q, "item_name": items[item_id]}
    return {"error": "Item not found"}