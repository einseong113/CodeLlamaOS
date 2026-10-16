예제 목록
  cpp-chat/     C++ (libcurl + nlohmann/json) 로 llama-server API 호출, CMake 프로젝트
  python-chat/  Python 으로 스트리밍 호출

먼저 모델을 고르고 서버를 켜세요:
  llm list
  llm use medium

llama.cpp 라이브러리(libllama)를 직접 링크하는 C++ 프로젝트는
  cmake -B build -DCMAKE_PREFIX_PATH=/opt/llama.cpp
  find_package(llama REQUIRED)   # 헤더: /opt/llama.cpp/include

llama-cpp-python 이 필요하면 (컴파일러가 이미 설치되어 있음):
  python3 -m venv .venv && . .venv/bin/activate && pip install llama-cpp-python
