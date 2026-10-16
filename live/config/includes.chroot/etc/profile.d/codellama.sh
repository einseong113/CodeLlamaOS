# CodeLlama OS 공통 환경
export PATH="/opt/llama.cpp/bin:$PATH"
export CMAKE_PREFIX_PATH="/opt/llama.cpp${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"
export LLAMA_URL="http://127.0.0.1:8080"

# OpenAI 호환 클라이언트(aider, openai SDK 등)가 로컬 서버를 보도록 설정
export OPENAI_API_BASE="http://127.0.0.1:8080/v1"
export OPENAI_BASE_URL="http://127.0.0.1:8080/v1"
export OPENAI_API_KEY="sk-local"

export EDITOR=nvim
alias ll='ls -alh'
alias vim=nvim
