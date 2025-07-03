#!/bin/bash
set -ex

# 문제별 디렉토리 찾기
dirs=$(find . -type f -name 'main.cpp' -exec dirname {} \; | sort -u)

for dir in $dirs; do
    echo "🔍 Testing $dir"
    cd "$dir"

    g++ -std=c++17 -o main main.cpp

    # input.txt와 expected.txt를 빈 줄 기준으로 분할
    IFS='' readarray -t input_chunks < <(awk -v RS= '{gsub(/\n$/, "", $0); print $0}' input.txt)
    IFS='' readarray -t expected_chunks < <(awk -v RS= '{gsub(/\n$/, "", $0); print $0}' expected.txt)

    if [ ${#input_chunks[@]} -ne ${#expected_chunks[@]} ]; then
        echo "❌ Number of inputs and expected outputs do not match"
        echo "Inputs: ${#input_chunks[@]}, Outputs: ${#expected_chunks[@]}"
        exit 1
    fi

    for i in "${!input_chunks[@]}"; do
        echo "▶️ Test Case $((i+1))"

        # 각각 실행
        echo "${input_chunks[i]}" | ./main > output.txt

        # 기대값 저장
        echo "${expected_chunks[i]}" > expected_tmp.txt

        # 비교
        if diff -q output.txt expected_tmp.txt > /dev/null; then
            echo "✅ Passed"
        else
            echo "❌ Failed Test Case $((i+1))"
            echo "--- Input ---"
            echo "${input_chunks[i]}"
            echo "--- Expected ---"
            echo "${expected_chunks[i]}"
            echo "--- Got ---"
            cat output.txt
            exit 1
        fi
    done

    cd - > /dev/null
done
