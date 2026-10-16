// 로컬 llama-server(OpenAI 호환 API)에 질문을 보내는 C++ 예제
// 빌드: cmake -B build -G Ninja && cmake --build build && ./build/chat "피보나치를 C++로"
#include <curl/curl.h>

#include <iostream>
#include <nlohmann/json.hpp>
#include <string>

using json = nlohmann::json;

static size_t write_cb(char* ptr, size_t size, size_t nmemb, void* userdata) {
    static_cast<std::string*>(userdata)->append(ptr, size * nmemb);
    return size * nmemb;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: " << argv[0] << " \"question\"\n";
        return 1;
    }

    const json body = {
        {"messages", json::array({
            {{"role", "system"}, {"content", "You are a concise C++/Python coding assistant."}},
            {{"role", "user"}, {"content", argv[1]}},
        })},
    };
    const std::string payload = body.dump();
    std::string response;

    CURL* curl = curl_easy_init();
    if (!curl) return 1;
    curl_slist* headers = curl_slist_append(nullptr, "Content-Type: application/json");
    curl_easy_setopt(curl, CURLOPT_URL, "http://127.0.0.1:8080/v1/chat/completions");
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, payload.c_str());
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_cb);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 600L);

    const CURLcode rc = curl_easy_perform(curl);
    curl_slist_free_all(headers);
    curl_easy_cleanup(curl);
    if (rc != CURLE_OK) {
        std::cerr << "request failed: " << curl_easy_strerror(rc) << "\n('llm status' 로 서버 확인)\n";
        return 1;
    }

    const json reply = json::parse(response, nullptr, false);
    if (reply.is_discarded() || !reply.contains("choices")) {
        std::cerr << "unexpected response: " << response << "\n";
        return 1;
    }
    std::cout << reply["choices"][0]["message"]["content"].get<std::string>() << "\n";
    return 0;
}
