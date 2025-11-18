/*
 * Simple logging instrumentation to detect Animator memory leaks
 *
 * INSTRUÇÕES:
 * 1. Adicione este código no src/client/animator.h e animator.cpp
 * 2. Compile o OTClient
 * 3. Execute e carregue alguns sprites
 * 4. Feche o cliente
 * 5. Observe os logs
 *
 * EXPECTED RESULTS:
 * - Com raw pointers: Verá "Animator created" mas NÃO verá "Animator destroyed"
 * - Com unique_ptr: Verá ambos "created" e "destroyed" em pares
 */

// ============================================================
// ADICIONAR EM src/client/animator.h
// ============================================================

class Animator {
public:
    Animator();
    ~Animator();

    // ... resto do código existente ...

private:
    static std::atomic<int> s_instanceCount;  // Contador global
    int m_instanceId;  // ID único desta instância
};

// ============================================================
// ADICIONAR EM src/client/animator.cpp
// ============================================================

#include <iostream>
#include <atomic>

// Inicializar contador estático
std::atomic<int> Animator::s_instanceCount{0};

Animator::Animator()
{
    m_instanceId = ++s_instanceCount;

    std::cout << "[ANIMATOR] Created #" << m_instanceId
              << " | Total alive: " << s_instanceCount
              << " | Address: " << (void*)this << std::endl;
}

Animator::~Animator()
{
    --s_instanceCount;

    std::cout << "[ANIMATOR] Destroyed #" << m_instanceId
              << " | Total alive: " << s_instanceCount
              << " | Address: " << (void*)this << std::endl;
}

// ============================================================
// OPCIONAL: Adicionar em src/client/thingtype.cpp
// ============================================================

// No começo das funções que criam Animators, adicione:
std::cout << "[THINGTYPE] Creating ThingType ID=" << m_id << std::endl;

// Quando criar animators:
if (spritesPhases.size() > 1) {
    std::cout << "[THINGTYPE] Allocating Animator for ThingType ID=" << m_id << std::endl;

    // VERSÃO ANTIGA (COM VAZAMENTO):
    auto* animator = new Animator;

    // VERSÃO NOVA (SEM VAZAMENTO):
    // auto animator = std::make_unique<Animator>();
}

// ============================================================
// EXEMPLO DE OUTPUT ESPERADO
// ============================================================

/*
COM RAW POINTERS (VAZAMENTO):
------------------------------
[THINGTYPE] Creating ThingType ID=100
[THINGTYPE] Allocating Animator for ThingType ID=100
[ANIMATOR] Created #1 | Total alive: 1 | Address: 0x7f8a3c001230
[ANIMATOR] Created #2 | Total alive: 2 | Address: 0x7f8a3c001450
[THINGTYPE] Creating ThingType ID=101
[ANIMATOR] Created #3 | Total alive: 3 | Address: 0x7f8a3c001670
[ANIMATOR] Created #4 | Total alive: 4 | Address: 0x7f8a3c001890

... cliente fecha ...

⚠️  NENHUM "Destroyed" foi chamado!
⚠️  Total alive: 4 (VAZAMENTO!)


COM UNIQUE_PTR (SEM VAZAMENTO):
--------------------------------
[THINGTYPE] Creating ThingType ID=100
[THINGTYPE] Allocating Animator for ThingType ID=100
[ANIMATOR] Created #1 | Total alive: 1 | Address: 0x7f8a3c001230
[ANIMATOR] Created #2 | Total alive: 2 | Address: 0x7f8a3c001450

... cliente fecha ...

[ANIMATOR] Destroyed #2 | Total alive: 1 | Address: 0x7f8a3c001450
[ANIMATOR] Destroyed #1 | Total alive: 0 | Address: 0x7f8a3c001230

✅ Todos destruídos! Total alive: 0
*/
