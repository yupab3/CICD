#!/bin/bash
set -ex

# main.cpp가 들어있는 모든 디렉토리 찾기
dirs=$(find . -type f -name 'main.cpp' -exec dirname {} \; | sort -u)

if [ -z "$dirs" ]; then
  echo "⚠️ No main.cpp found in any directory"
  exit 1
fi

for dir in $dirs; do
    echo "🔍 Testing $dir"
    cd "$dir"

    g++ -std=c++17 -o main main.cpp
    ./main < input.txt > output.txt

    if diff -q output.txt expected.txt > /dev/null; then
        echo "✅ Passed: $dir"
    else
        echo "❌ Failed in $dir"
        echo "--- Expected ---"
        cat expected.txt
        echo "--- Got ---"
        cat output.txt
        exit 1
    fi

    cd - > /dev/null
done
