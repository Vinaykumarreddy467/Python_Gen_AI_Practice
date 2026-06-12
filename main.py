import os
from dotenv import load_dotenv
  
load_dotenv()



huggingface=os.getenv("HUGGINGFACE_API_KEY")

def main():
    print("Hello, World!")
    print(huggingface[:20])
    # print(HUGGINGFACE_API_KEY[:7])

if __name__ == "__main__": main()