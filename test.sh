#!/bin/bash
set -e

dirs=$(find . -type f -name 'main.cpp' -exec dirname {} \; | sort -u)

for dir in $dirs; do
    echo "🔍 Testing $dir"
    cd "$dir"

    g++ -std=c++17 -o main main.cpp

    # split input/output on "===" delimiter
    IFS=$'\n' read -d '' -r -a input_chunks < <(awk 'BEGIN{RS="==="} {gsub(/^\n+|\n+$/, "", $0); print}' input.txt && printf '\0')
    IFS=$'\n' read -d '' -r -a expected_chunks < <(awk 'BEGIN{RS="==="} {gsub(/^\n+|\n+$/, "", $0); print}' expected.txt && printf '\0')

    if [ ${#input_chunks[@]} -ne ${#expected_chunks[@]} ]; then
        echo "❌ Number of inputs and expected outputs do not match"
        echo "Inputs: ${#input_chunks[@]}, Outputs: ${#expected_chunks[@]}"
        exit 1
    fi

    for i in "${!input_chunks[@]}"; do
        echo "▶️ Test Case $((i+1))"

        # 실행
        printf "%s\n" "${input_chunks[i]}" | ./main > output.txt

        # 기대값 저장
        printf "%s\n" "${expected_chunks[i]}" > expected_tmp.txt

        # 비교
        if diff -q output.txt expected_tmp.txt > /dev/null; then
            echo "✅ Passed"
        else
            echo "❌ Failed Test Case $((i+1))"
            echo "--- Input ---"
            printf "%s\n" "${input_chunks[i]}"
            echo "--- Expected ---"
            printf "%s\n" "${expected_chunks[i]}"
            echo "--- Got ---"
            cat output.txt
            exit 1
        fi
    done

    cd - > /dev/null
done
