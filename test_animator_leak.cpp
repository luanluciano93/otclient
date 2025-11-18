/*
 * Test program to demonstrate ThingType Animator memory leak
 *
 * This test creates and destroys ThingType-like objects to show
 * memory leak with raw pointers vs smart pointers
 */

#include <iostream>
#include <memory>
#include <vector>
#include <cstdlib>
#include <fstream>

// Simplified Animator class (mimics the real one)
class Animator {
public:
    Animator() {
        // Allocate some memory to make leak visible
        data = new uint8_t[1024]; // 1KB per animator
        std::cout << "  [Animator] Created at " << (void*)this << " (allocated 1KB)" << std::endl;
    }

    ~Animator() {
        delete[] data;
        std::cout << "  [Animator] Destroyed at " << (void*)this << std::endl;
    }

    void unserialize(int phases) {
        // Simulate loading animation data
    }

private:
    uint8_t* data;
};

// ========================================
// VERSION 1: WITH RAW POINTERS (OLD CODE)
// ========================================
class ThingType_RawPointer {
public:
    ThingType_RawPointer(int id) : m_id(id) {
        std::cout << "[ThingType_RawPointer #" << m_id << "] Created" << std::endl;
    }

    ~ThingType_RawPointer() {
        std::cout << "[ThingType_RawPointer #" << m_id << "] Destroyed" << std::endl;
        // BUG: No delete for m_animator and m_idleAnimator!
        // This is the MEMORY LEAK!
    }

    void createAnimator() {
        m_animator = new Animator();
    }

    void createIdleAnimator() {
        m_idleAnimator = new Animator();
    }

private:
    int m_id;
    Animator* m_animator{ nullptr };
    Animator* m_idleAnimator{ nullptr };
};

// ========================================
// VERSION 2: WITH UNIQUE_PTR (FIXED CODE)
// ========================================
class ThingType_UniquePtr {
public:
    ThingType_UniquePtr(int id) : m_id(id) {
        std::cout << "[ThingType_UniquePtr #" << m_id << "] Created" << std::endl;
    }

    ~ThingType_UniquePtr() {
        std::cout << "[ThingType_UniquePtr #" << m_id << "] Destroyed" << std::endl;
        // unique_ptr automatically deletes m_animator and m_idleAnimator
    }

    void createAnimator() {
        m_animator = std::make_unique<Animator>();
    }

    void createIdleAnimator() {
        m_idleAnimator = std::make_unique<Animator>();
    }

private:
    int m_id;
    std::unique_ptr<Animator> m_animator{ nullptr };
    std::unique_ptr<Animator> m_idleAnimator{ nullptr };
};

// ========================================
// TEST FUNCTIONS
// ========================================

void test_raw_pointer_leak(int iterations) {
    std::cout << "\n========================================" << std::endl;
    std::cout << "TEST 1: RAW POINTERS (OLD CODE - WITH LEAK)" << std::endl;
    std::cout << "========================================\n" << std::endl;

    std::cout << "Creating " << iterations << " ThingTypes with animators...\n" << std::endl;

    for (int i = 0; i < iterations; ++i) {
        ThingType_RawPointer* thing = new ThingType_RawPointer(i);
        thing->createAnimator();
        thing->createIdleAnimator();

        // Simulate object being destroyed (like when unloading sprites)
        delete thing;

        std::cout << std::endl;
    }

    std::cout << "⚠️  NOTICE: Animators were CREATED but NOT DESTROYED!" << std::endl;
    std::cout << "⚠️  Memory leaked: " << (iterations * 2 * 1024) << " bytes ("
              << (iterations * 2 * 1024 / 1024.0) << " KB)" << std::endl;
}

void test_unique_ptr_fixed(int iterations) {
    std::cout << "\n========================================" << std::endl;
    std::cout << "TEST 2: UNIQUE_PTR (FIXED CODE - NO LEAK)" << std::endl;
    std::cout << "========================================\n" << std::endl;

    std::cout << "Creating " << iterations << " ThingTypes with animators...\n" << std::endl;

    for (int i = 0; i < iterations; ++i) {
        ThingType_UniquePtr* thing = new ThingType_UniquePtr(i);
        thing->createAnimator();
        thing->createIdleAnimator();

        // Simulate object being destroyed
        delete thing;

        std::cout << std::endl;
    }

    std::cout << "✅ NOTICE: All Animators were properly CREATED and DESTROYED!" << std::endl;
    std::cout << "✅ Memory leaked: 0 bytes" << std::endl;
}

void get_memory_usage(const std::string& label) {
    // Read memory usage from /proc/self/status
    std::ifstream status("/proc/self/status");
    std::string line;

    std::cout << "\n[" << label << "] Memory Usage:" << std::endl;

    while (std::getline(status, line)) {
        if (line.substr(0, 6) == "VmRSS:" || line.substr(0, 6) == "VmSize") {
            std::cout << "  " << line << std::endl;
        }
    }
}

// ========================================
// MAIN
// ========================================
int main(int argc, char* argv[]) {
    int iterations = 5; // Default: 5 iterations for clear output

    if (argc > 1) {
        iterations = std::atoi(argv[1]);
    }

    std::cout << "╔════════════════════════════════════════════════════╗" << std::endl;
    std::cout << "║  ThingType Animator Memory Leak Test              ║" << std::endl;
    std::cout << "║  Demonstrates the difference between raw          ║" << std::endl;
    std::cout << "║  pointers and unique_ptr                           ║" << std::endl;
    std::cout << "╚════════════════════════════════════════════════════╝" << std::endl;

    get_memory_usage("Before Tests");

    // Test 1: Show the leak with raw pointers
    test_raw_pointer_leak(iterations);
    get_memory_usage("After Raw Pointer Test");

    // Test 2: Show no leak with unique_ptr
    test_unique_ptr_fixed(iterations);
    get_memory_usage("After Unique_ptr Test");

    std::cout << "\n========================================" << std::endl;
    std::cout << "SUMMARY" << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << "Raw pointers: Animators NOT destroyed → MEMORY LEAK" << std::endl;
    std::cout << "Unique_ptr:   Animators automatically destroyed → NO LEAK" << std::endl;
    std::cout << "\nTo test with more iterations: ./test_animator_leak 1000" << std::endl;

    return 0;
}
