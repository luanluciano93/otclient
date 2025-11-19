#!/bin/bash

# Script para testar vazamento de memória no Pathfinding usando logs simples
#
# USO:
#   ./test_pathfinding_leak_logs.sh apply     - Aplica logging
#   ./test_pathfinding_leak_logs.sh remove    - Remove logging
#   ./test_pathfinding_leak_logs.sh test      - Aplica, compila e testa

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║$(printf '%*s' 52 '' | tr ' ' ' ')${NC}"
    printf "${BLUE}║  %-48s  ║${NC}\n" "$1"
    echo -e "${BLUE}║$(printf '%*s' 52 '' | tr ' ' ' ')${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
}

add_logging() {
    print_header "Adding Pathfinding Logging"

    # Backup
    if [ ! -f src/client/map.cpp.backup ]; then
        cp src/client/map.cpp src/client/map.cpp.backup
        echo -e "${GREEN}✓ Backup created: src/client/map.cpp.backup${NC}"
    else
        echo -e "${YELLOW}⚠️  Backup already exists${NC}"
    fi

    # Check if already applied
    if grep -q "PATHFINDING_LEAK_TEST" src/client/map.cpp; then
        echo -e "${YELLOW}⚠️  Logging already applied${NC}"
        return
    fi

    echo -e "${GREEN}Adding logging to map.cpp...${NC}"

    # Add logging macros at the top of the file (after includes)
    local insert_line=$(grep -n "^#include" src/client/map.cpp | tail -1 | cut -d: -f1)
    insert_line=$((insert_line + 2))

    # Create logging code
    cat > /tmp/pathfinding_log.txt << 'EOF'

// ============================================================
// PATHFINDING MEMORY LEAK TEST - START
// ============================================================
#include <atomic>
#include <iostream>

namespace PathfindingLeakTest {
    std::atomic<int> snodeCount{0};
    std::atomic<int> nodeCount{0};

    void logSNodeCreate(void* ptr) {
        int count = ++snodeCount;
        std::cout << "\033[1;32m[PATHFIND SNode]\033[0m Created | "
                  << "\033[1;33mAlive: " << count << "\033[0m | "
                  << "Addr: " << ptr << std::endl;
    }

    void logSNodeDestroy(void* ptr) {
        int count = --snodeCount;
        std::cout << "\033[1;31m[PATHFIND SNode]\033[0m Destroyed | "
                  << "\033[1;33mAlive: " << count << "\033[0m | "
                  << "Addr: " << ptr << std::endl;
    }

    void logNodeCreate(void* ptr) {
        int count = ++nodeCount;
        std::cout << "\033[1;32m[PATHFIND Node]\033[0m Created | "
                  << "\033[1;33mAlive: " << count << "\033[0m | "
                  << "Addr: " << ptr << std::endl;
    }

    void logNodeDestroy(void* ptr) {
        int count = --nodeCount;
        std::cout << "\033[1;31m[PATHFIND Node]\033[0m Destroyed | "
                  << "\033[1;33mAlive: " << count << "\033[0m | "
                  << "Addr: " << ptr << std::endl;
    }

    void printSummary() {
        if (snodeCount > 0 || nodeCount > 0) {
            std::cout << "\033[1;41m[PATHFIND LEAK!]\033[0m "
                      << "SNode: " << snodeCount
                      << " | Node: " << nodeCount << std::endl;
        } else {
            std::cout << "\033[1;42m[PATHFIND OK]\033[0m "
                      << "No leaks detected" << std::endl;
        }
    }
}
// ============================================================
// PATHFINDING MEMORY LEAK TEST - END
// ============================================================

EOF

    # Insert logging code
    sed -i "${insert_line}r /tmp/pathfinding_log.txt" src/client/map.cpp

    # Now instrument the actual allocations/deallocations
    # For unique_ptr version (current code), add logging at construction

    # Add to SNode constructor
    sed -i 's/SNode(const Position\& pos) :/SNode(const Position\& pos) :/; /SNode(const Position\& pos) :/a\            pos(pos) { PathfindingLeakTest::logSNodeCreate(this); }' src/client/map.cpp

    # Remove the old initialization line
    sed -i '/SNode(const Position\& pos)/,/{}/ { /pos(pos) {}/! { /pos(pos)$/d; } }' src/client/map.cpp

    # Add SNode destructor
    sed -i '/struct SNode/,/^    };$/ { /Otc::Direction dir/a\        ~SNode() { PathfindingLeakTest::logSNodeDestroy(this); }
}' src/client/map.cpp

    echo -e "${GREEN}✓ Logging added successfully${NC}"
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════${NC}"
    echo -e "${GREEN}Next Steps:${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════${NC}"
    echo ""
    echo "  1️⃣  Compile OTClient:"
    echo "      ${BLUE}cd build && cmake .. && make -j\$(nproc)${NC}"
    echo ""
    echo "  2️⃣  Run OTClient:"
    echo "      ${BLUE}./otclient${NC}"
    echo ""
    echo "  3️⃣  Trigger pathfinding:"
    echo "      • Connect to a server"
    echo "      • Click to walk around"
    echo "      • Use auto-walk feature"
    echo ""
    echo "  4️⃣  Watch for logs:"
    echo "      ${GREEN}[PATHFIND SNode] Created${NC}"
    echo "      ${RED}[PATHFIND SNode] Destroyed${NC}"
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════${NC}"
    echo ""
    echo -e "${RED}With RAW POINTERS (bug):${NC}"
    echo "  ❌ Only 'Created' logs appear"
    echo "  ❌ No 'Destroyed' logs"
    echo "  ❌ Alive count keeps growing"
    echo ""
    echo -e "${GREEN}With UNIQUE_PTR (fixed):${NC}"
    echo "  ✅ Both 'Created' and 'Destroyed' logs"
    echo "  ✅ Alive count goes back to 0"
    echo ""
}

remove_logging() {
    print_header "Removing Pathfinding Logging"

    if [ -f src/client/map.cpp.backup ]; then
        mv src/client/map.cpp.backup src/client/map.cpp
        echo -e "${GREEN}✓ Restored src/client/map.cpp${NC}"
    else
        echo -e "${RED}⚠️  No backup found${NC}"
        echo -e "${YELLOW}Run 'git checkout src/client/map.cpp' to restore${NC}"
    fi

    rm -f /tmp/pathfinding_log.txt
    echo ""
    echo -e "${GREEN}✓ Logging removed${NC}"
}

run_test() {
    print_header "Pathfinding Memory Leak Test"

    add_logging

    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║            Compiling OTClient...                   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
    echo ""

    mkdir -p build
    cd build

    if cmake .. >/dev/null 2>&1 && make -j$(nproc); then
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║          ✓ Compilation Successful!                ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${MAGENTA}Run otclient and test pathfinding:${NC}"
        echo "  ${BLUE}cd build && ./otclient${NC}"
        echo ""
        echo -e "${YELLOW}Watch the console for [PATHFIND] logs!${NC}"
    else
        echo ""
        echo -e "${RED}✗ Compilation failed${NC}"
        cd ..
        remove_logging
        exit 1
    fi

    cd ..
}

show_usage() {
    cat << EOF

Usage: $0 {apply|remove|test}

Commands:
  ${GREEN}apply${NC}   - Add logging to pathfinding code
  ${RED}remove${NC}  - Remove logging (restore backup)
  ${BLUE}test${NC}    - Apply, compile and prepare for testing

Examples:
  $0 apply     # Add logging only
  $0 test      # Full test: apply + compile
  $0 remove    # Cleanup

EOF
}

# Main
case "$1" in
    apply)
        add_logging
        ;;
    remove)
        remove_logging
        ;;
    test)
        run_test
        ;;
    *)
        show_usage
        exit 1
        ;;
esac

exit 0
