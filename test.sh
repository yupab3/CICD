#!/bin/bash
set -ex  # -x: 실행되는 명령어 출력 / -e: 에러시 중단

# 문제 디렉토리 목록 가져오기
dirs=$(find . -type d -regex './[0-9]\+')

if [ -z "$dirs" ]; then
  echo "⚠️ No problem directories found"
  exit 1
fi

# 각 문제 디렉토리마다 테스트
for dir in $dirs; do
    echo "🔍 Testing $dir"
    cd "$dir"

    if [ ! -f main.cpp ]; then
        echo "❌ No main.cpp in $dir"
        cd - > /dev/null
        continue
    fi

    g++ -std=c++17 -o main main.cpp

    # 실행 및 비교
    ./main < input.txt > output.txt

    if diff -q output.txt expected.txt > /dev/null; then
        echo "✅ Passed"
    else
        echo "❌ Failed in $dir"
        echo "Expected:"
        cat expected.txt
        echo "Got:"
        cat output.txt
        exit 1
    fi

    cd - > /dev/null
done