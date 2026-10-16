cmake_minimum_required(VERSION 3.20)
project(chat CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # clangd 용

find_package(CURL REQUIRED)
find_package(nlohmann_json REQUIRED)

add_executable(chat main.cpp)
target_link_libraries(chat PRIVATE CURL::libcurl nlohmann_json::nlohmann_json)
