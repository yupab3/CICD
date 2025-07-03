#!/bin/bash
set -e

# 모든 문제 디렉토리를 반복
for dir in $(find . -type d -regex './[0-9]\+'); do
    echo "🔍 Testing $dir"
    cd "$dir"
    
    if [ ! -f main.cpp ]; then
        echo "❌ No main.cpp in $dir"
        cd - > /dev/null
        continue
    fi

    g++ -std=c++17 -o main main.cpp
    if [ $? -ne 0 ]; then
        echo "❌ Compilation failed in $dir"
        cd - > /dev/null
        continue
    fi

    # 실행 결과를 비교
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