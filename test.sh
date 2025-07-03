#!/bin/bash
set -e

dirs=$(find . -type f -name 'main.cpp' -exec dirname {} \; | sort -u)

for dir in $dirs; do
    echo "🔍 Testing $dir"
    cd "$dir"

    g++ -std=c++17 -o main main.cpp

    # 입력과 출력을 === 기준으로 분할
    IFS=$'\x1E'  # ASCII RS(레코드 구분자)처럼 사용
    input_raw=$(awk -v RS='===\n' '{gsub(/^\n+|\n+$/, "", $0); print}' input.txt | awk '{print $0 "\x1E"}')
    expected_raw=$(awk -v RS='===\n' '{gsub(/^\n+|\n+$/, "", $0); print}' expected.txt | awk '{print $0 "\x1E"}')

    # 문자열을 배열로 쪼갬 (mapfile 없이)
    input_cases=()
    expected_cases=()

    while IFS= read -r -d $'\x1E' block; do
        input_cases+=("$block")
    done <<< "$input_raw"

    while IFS= read -r -d $'\x1E' block; do
        expected_cases+=("$block")
    done <<< "$expected_raw"

    # 비교
    if [ ${#input_cases[@]} -ne ${#expected_cases[@]} ]; then
        echo "❌ Number of test cases mismatch"
        echo "Inputs: ${#input_cases[@]}, Outputs: ${#expected_cases[@]}"
        exit 1
    fi

    for i in "${!input_cases[@]}"; do
        echo ""
        echo "▶️ Test Case $((i+1))"
        echo "--- Input ---"
        printf "%s\n" "${input_cases[i]}"

        echo "${input_cases[i]}" | ./main > output.txt
        printf "%s\n" "${expected_cases[i]}" > expected.txt.tmp

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
