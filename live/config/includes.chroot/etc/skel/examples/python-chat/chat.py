"""로컬 llama-server 에 스트리밍으로 질문하는 Python 예제 (표준 라이브러리만 사용).

실행:  python3 chat.py "리스트 컴프리헨션과 map 차이?"
OpenAI SDK 를 쓰고 싶다면:
    python3 -m venv .venv && . .venv/bin/activate && pip install openai
    OpenAI(base_url="http://127.0.0.1:8080/v1", api_key="sk-local")
"""
import json
import sys
import urllib.request

URL = "http://127.0.0.1:8080/v1/chat/completions"


def ask(question: str) -> None:
    body = json.dumps(
        {"messages": [{"role": "user", "content": question}], "stream": True}
    ).encode()
    req = urllib.request.Request(URL, body, {"Content-Type": "application/json"})
    with urllib.request.urlopen(req) as resp:
        for raw in resp:
            line = raw.decode().strip()
            if not line.startswith("data:") or line.endswith("[DONE]"):
                continue
            delta = json.loads(line[5:])["choices"][0]["delta"]
            print(delta.get("content") or "", end="", flush=True)
    print()


if __name__ == "__main__":
    ask(" ".join(sys.argv[1:]) or "Hello!")
