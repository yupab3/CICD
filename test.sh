#!/bin/bash
set -e

dirs=$(find . -type f -name 'main.cpp' -exec dirname {} \; | sort -u)

for dir in $dirs; do
    echo "🔍 Testing $dir"
    cd "$dir"

    g++ -std=c++17 -o main main.cpp

    # 테스트 케이스들을 === 구분자로 나눔 (입력)
    mapfile -t input_cases < <(awk -v RS='===\n' '{sub(/^\n+|\n+$/, "", $0); print}' input.txt)
    mapfile -t expected_cases < <(awk -v RS='===\n' '{sub(/^\n+|\n+$/, "", $0); print}' expected.txt)

    if [ "${#input_cases[@]}" -ne "${#expected_cases[@]}" ]; then
        echo "❌ Number of test cases mismatch"
        echo "Inputs: ${#input_cases[@]}, Outputs: ${#expected_cases[@]}"
        exit 1
    fi

    for i in "${!input_cases[@]}"; do
        echo ""
        echo "▶️ Test Case $((i+1))"
        echo "--- Input ---"
        printf "%s\n" "${input_cases[i]}"

        # 실행
        echo "${input_cases[i]}" | ./main > output.txt

        # 기대 출력 임시 저장
        echo "${expected_cases[i]}" > expected.txt.tmp

        # 결과 비교
        if diff -q output.txt expected.txt.tmp > /dev/null; then
            echo "✅ Passed"
        else
            echo "❌ Failed Test Case $((i+1))"
            echo "--- Expected ---"
            cat expected.txt.tmp
            echo "--- Got ---"
            cat output.txt
            exit 1
        fi
    done

    cd - > /dev/null
done
