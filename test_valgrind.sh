#!/bin/bash

echo "╔════════════════════════════════════════════════════╗"
echo "║  Valgrind Memory Leak Detection Test              ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

# Check if valgrind is installed
if ! command -v valgrind &> /dev/null; then
    echo "⚠️  Valgrind is not installed."
    echo "   To install: sudo apt-get install valgrind"
    echo ""
    echo "Running basic test without Valgrind..."
    ./test_animator_leak 10
    exit 0
fi

echo "Running memory leak detection with Valgrind..."
echo "This will take a moment..."
echo ""

# Run with valgrind
valgrind --leak-check=full \
         --show-leak-kinds=all \
         --track-origins=yes \
         --verbose \
         --log-file=valgrind_output.txt \
         ./test_animator_leak 10

echo "✅ Valgrind analysis complete!"
echo ""
echo "Key findings from valgrind_output.txt:"
echo "========================================"

# Extract leak summary
grep -A 20 "LEAK SUMMARY" valgrind_output.txt || echo "No leaks detected!"
echo ""

# Extract definitely lost
grep "definitely lost" valgrind_output.txt || echo "No definite leaks!"
echo ""

echo "Full report saved to: valgrind_output.txt"
echo ""
echo "Expected results:"
echo "  - Test 1 (raw pointers): Will show 'definitely lost' blocks"
echo "  - Test 2 (unique_ptr):   Will show proper cleanup (no leaks)"
