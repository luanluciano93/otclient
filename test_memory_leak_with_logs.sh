#!/bin/bash

# Script para testar vazamento de memória usando logs simples
#
# USO:
#   ./test_memory_leak_with_logs.sh apply     - Aplica logging
#   ./test_memory_leak_with_logs.sh remove    - Remove logging
#   ./test_memory_leak_with_logs.sh test      - Aplica, compila e testa

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  $1${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
}

add_logging() {
    print_header "Adding Animator Logging Instrumentation"

    # Backup original files
    cp src/client/animator.h src/client/animator.h.backup
    cp src/client/animator.cpp src/client/animator.cpp.backup

    echo -e "${YELLOW}Backups created:${NC}"
    echo "  - src/client/animator.h.backup"
    echo "  - src/client/animator.cpp.backup"
    echo ""

    # Add to animator.h (adicionar antes de 'private:')
    echo -e "${GREEN}Adding to animator.h...${NC}"

    # Verifica se já foi adicionado
    if grep -q "s_instanceCount" src/client/animator.h; then
        echo -e "${YELLOW}⚠️  Logging already added to animator.h${NC}"
    else
        # Adiciona constructor/destructor declarations após a linha "public:"
        sed -i '/^public:$/a\    Animator();\n    ~Animator();' src/client/animator.h

        # Adiciona membros privados antes do }; final
        sed -i '/^};$/i\    // Memory leak detection\n    static std::atomic<int> s_instanceCount;\n    int m_instanceId;' src/client/animator.h

        echo -e "${GREEN}✓ animator.h updated${NC}"
    fi

    # Add to animator.cpp
    echo -e "${GREEN}Adding to animator.cpp...${NC}"

    if grep -q "s_instanceCount" src/client/animator.cpp; then
        echo -e "${YELLOW}⚠️  Logging already added to animator.cpp${NC}"
    else
        # Cria arquivo temporário com o código de logging
        cat > /tmp/animator_logging.txt << 'EOF'
#include <iostream>
#include <atomic>

// Initialize static counter
std::atomic<int> Animator::s_instanceCount{0};

Animator::Animator()
{
    m_instanceId = ++s_instanceCount;
    std::cout << "\033[1;32m[ANIMATOR]\033[0m Created #" << m_instanceId
              << " | \033[1;33mTotal alive: " << s_instanceCount << "\033[0m"
              << " | Address: " << (void*)this << std::endl;
}

Animator::~Animator()
{
    --s_instanceCount;
    std::cout << "\033[1;31m[ANIMATOR]\033[0m Destroyed #" << m_instanceId
              << " | \033[1;33mTotal alive: " << s_instanceCount << "\033[0m"
              << " | Address: " << (void*)this << std::endl;
}

EOF

        # Adiciona após os includes
        sed -i '/#include "animator.h"/r /tmp/animator_logging.txt' src/client/animator.cpp

        echo -e "${GREEN}✓ animator.cpp updated${NC}"
        rm /tmp/animator_logging.txt
    fi

    echo ""
    echo -e "${GREEN}✓ Logging instrumentation added successfully!${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Compile: cd build && cmake .. && make"
    echo "  2. Run otclient and load some sprites"
    echo "  3. Close otclient"
    echo "  4. Check output for [ANIMATOR] logs"
    echo ""
    echo -e "${YELLOW}Expected with RAW POINTERS (bug):${NC}"
    echo "  - You'll see 'Created' but NOT 'Destroyed'"
    echo "  - Total alive will increase and never decrease"
    echo ""
    echo -e "${YELLOW}Expected with UNIQUE_PTR (fixed):${NC}"
    echo "  - You'll see both 'Created' and 'Destroyed'"
    echo "  - Total alive will return to 0 when closing"
}

remove_logging() {
    print_header "Removing Animator Logging Instrumentation"

    if [ -f src/client/animator.h.backup ]; then
        mv src/client/animator.h.backup src/client/animator.h
        echo -e "${GREEN}✓ Restored animator.h${NC}"
    else
        echo -e "${RED}⚠️  No backup found for animator.h${NC}"
    fi

    if [ -f src/client/animator.cpp.backup ]; then
        mv src/client/animator.cpp.backup src/client/animator.cpp
        echo -e "${GREEN}✓ Restored animator.cpp${NC}"
    else
        echo -e "${RED}⚠️  No backup found for animator.cpp${NC}"
    fi

    echo ""
    echo -e "${GREEN}✓ Logging instrumentation removed${NC}"
}

run_test() {
    print_header "Running Memory Leak Test with Logging"

    add_logging

    echo -e "${BLUE}Compiling OTClient...${NC}"
    mkdir -p build
    cd build

    if cmake .. && make -j$(nproc); then
        echo ""
        echo -e "${GREEN}✓ Compilation successful!${NC}"
        echo ""
        echo -e "${YELLOW}Now you can run otclient:${NC}"
        echo "  cd build"
        echo "  ./otclient"
        echo ""
        echo -e "${YELLOW}Watch for [ANIMATOR] logs in the console${NC}"
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
    echo "Usage: $0 {apply|remove|test}"
    echo ""
    echo "Commands:"
    echo "  apply   - Add logging instrumentation to Animator class"
    echo "  remove  - Remove logging instrumentation (restore backups)"
    echo "  test    - Apply logging, compile and prepare for testing"
    echo ""
    echo "Example:"
    echo "  $0 apply     # Add logging"
    echo "  $0 test      # Apply, compile and test"
    echo "  $0 remove    # Clean up when done"
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
