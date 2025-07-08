#!/bin/bash
set -e

# 최근 커밋에서 변경된 main.cpp, input.txt, expected.txt 파일이 속한 디렉토리만 추출
dirs=$(git diff --name-only HEAD^ HEAD | grep -E 'main\.cpp|input\.txt|expected\.txt' | xargs -n1 dirname | sort -u)

if [ -z "$dirs" ]; then
    echo "✅ No relevant changes, skipping tests."
    exit 0
fi

for dir in $dirs; do
    echo "🔍 Testing $dir"
    cd "$dir"

    g++ -std=c++17 -o main main.cpp

    # 기존 분할 파일 삭제
    rm -f input_case_* expected_case_*

    # === 기준으로 input.txt 쪼개기
    csplit --quiet --prefix=input_case_ --suffix-format="%03d.txt" input.txt '/^===$/+1' '{*}'
    # 마지막 파일이 === 줄만 들어있는 경우 제거
    find . -name 'input_case_*.txt' -exec sed -i '/^===$/d' {} \;

    # expected.txt도 마찬가지
    csplit --quiet --prefix=expected_case_ --suffix-format="%03d.txt" expected.txt '/^===$/+1' '{*}'
    find . -name 'expected_case_*.txt' -exec sed -i '/^===$/d' {} \;

    input_files=(input_case_*.txt)
    expected_files=(expected_case_*.txt)

    if [ ${#input_files[@]} -ne ${#expected_files[@]} ]; then
        echo "❌ Test case count mismatch"
        echo "Inputs: ${#input_files[@]}, Outputs: ${#expected_files[@]}"
        exit 1
    fi

    for i in "${!input_files[@]}"; do
        echo ""
        echo "▶️ Test Case $((i+1))"
        echo "--- Input ---"
        cat "${input_files[i]}"

        ./main < "${input_files[i]}" > output.txt

        if diff -q output.txt "${expected_files[i]}" > /dev/null; then
            echo "✅ Passed"
        else
            echo "❌ Failed Test Case $((i+1))"
            echo "--- Expected ---"
            cat "${expected_files[i]}"
            echo "--- Got ---"
            cat output.txt
            exit 1
        fi
    done

    cd - > /dev/null
done
