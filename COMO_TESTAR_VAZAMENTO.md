# 🧪 Como Testar o Vazamento de Memória - ThingType Animator

## ⚡ Teste Rápido (30 segundos)

```bash
cd /home/user/otclient

# Compilar o teste
g++ -std=c++20 -o test_animator_leak test_animator_leak.cpp

# Executar
./test_animator_leak 10
```

### 📊 O que você verá:

#### ❌ Teste 1 - Raw Pointers (COM VAZAMENTO)
```
[ThingType_RawPointer #0] Created
  [Animator] Created at 0x4e243e0 (allocated 1KB)    ← CRIADO
  [Animator] Created at 0x4e24870 (allocated 1KB)    ← CRIADO
[ThingType_RawPointer #0] Destroyed
                                                       ← NENHUM FOI DESTRUÍDO!

⚠️  Memory leaked: 20480 bytes (20 KB)
```

#### ✅ Teste 2 - Unique_ptr (SEM VAZAMENTO)
```
[ThingType_UniquePtr #0] Created
  [Animator] Created at 0x4e2c600 (allocated 1KB)    ← CRIADO
  [Animator] Created at 0x4e2ca90 (allocated 1KB)    ← CRIADO
[ThingType_UniquePtr #0] Destroyed
  [Animator] Destroyed at 0x4e2ca90                  ← DESTRUÍDO ✓
  [Animator] Destroyed at 0x4e2c600                  ← DESTRUÍDO ✓

✅ Memory leaked: 0 bytes
```

---

## 🔬 Teste com Valgrind (Detecção Profissional)

```bash
# Instalar Valgrind (se necessário)
sudo apt-get install valgrind

# Executar teste automatizado
chmod +x test_valgrind.sh
./test_valgrind.sh
```

### 📈 Resultado Esperado:

```
LEAK SUMMARY:
   definitely lost: 160 bytes in 20 blocks       ← 20 ponteiros Animator*
   indirectly lost: 20,480 bytes in 20 blocks    ← Dados dentro dos Animators
     possibly lost: 0 bytes in 0 blocks
```

**Total vazado: 20,640 bytes**

---

## 🎯 Teste com Diferentes Volumes

### Teste Pequeno (Ver outputs claramente)
```bash
./test_animator_leak 3
```

### Teste Médio (Ver impacto na memória)
```bash
./test_animator_leak 100
```

### Teste Grande (Simular uso real)
```bash
./test_animator_leak 1000
```

Com 1000 iterações:
- **Raw pointers**: ~2 MB vazados
- **Unique_ptr**: 0 bytes vazados

---

## 🔍 Como Interpretar os Resultados

### 1. Contagem de Criações vs Destruições

#### ❌ COM VAZAMENTO:
```
Criados:     20 Animators
Destruídos:   0 Animators
Diferença:   20 Animators vazaram (20 KB)
```

#### ✅ SEM VAZAMENTO:
```
Criados:     20 Animators
Destruídos:  20 Animators
Diferença:    0 Animators (perfeito!)
```

### 2. Relatório Valgrind

#### "definitely lost: 160 bytes in 20 blocks"
- **O que é**: Os ponteiros `Animator*` que não foram deletados
- **Cálculo**: 20 objetos × 8 bytes/ponteiro = 160 bytes
- **Gravidade**: 🔴 CRÍTICO

#### "indirectly lost: 20,480 bytes in 20 blocks"
- **O que é**: A memória alocada DENTRO de cada Animator
- **Cálculo**: 20 objetos × 1024 bytes/objeto = 20,480 bytes
- **Gravidade**: 🔴 CRÍTICO

### 3. Chamadas de Stack (Stack Trace)

```
by 0x10B334: ThingType_RawPointer::createAnimator()
by 0x10A586: test_raw_pointer_leak(int)
```

Mostra exatamente ONDE o vazamento acontece!

---

## 🎓 Entendendo o Problema

### Código COM Vazamento (Original)

```cpp
class ThingType_RawPointer {
    Animator* m_animator{ nullptr };

    void createAnimator() {
        m_animator = new Animator();  // Aloca memória
    }

    ~ThingType_RawPointer() {
        // ❌ NÃO deleta m_animator!
        // VAZAMENTO!
    }
};
```

**Fluxo de memória:**
1. ✅ `new Animator()` → Aloca 1KB
2. ✅ Ponteiro salvo em `m_animator`
3. ✅ ThingType destruído
4. ❌ `m_animator` NÃO foi deletado → **VAZAMENTO!**

### Código SEM Vazamento (Corrigido)

```cpp
class ThingType_UniquePtr {
    std::unique_ptr<Animator> m_animator{ nullptr };

    void createAnimator() {
        m_animator = std::make_unique<Animator>();  // Aloca memória
    }

    ~ThingType_UniquePtr() {
        // ✅ unique_ptr deleta automaticamente!
        // Não precisa fazer nada!
    }
};
```

**Fluxo de memória:**
1. ✅ `make_unique<Animator>()` → Aloca 1KB
2. ✅ Ownership transferido para `m_animator`
3. ✅ ThingType destruído
4. ✅ `unique_ptr` destrutor deleta automaticamente → **SEM VAZAMENTO!**

---

## 📊 Comparação Lado a Lado

| Aspecto | Raw Pointer ❌ | Unique_ptr ✅ |
|---------|----------------|---------------|
| **Alocação** | `new Animator()` | `make_unique<Animator>()` |
| **Destruição** | Manual (esquecida!) | Automática |
| **Em caso de exceção** | VAZA | NÃO vaza |
| **Segurança** | Perigoso | Seguro |
| **Performance** | Igual | Igual |
| **Código extra** | Precisa lembrar de deletar | Zero |

---

## 🚀 Teste no Código Real do OTClient

### Opção 1: Reverter e Testar (Avançado)

```bash
# 1. Criar branch de teste
git checkout -b test-memory-leak

# 2. Reverter correção do Animator
git revert <commit-hash-da-correcao>

# 3. Compilar OTClient
mkdir build && cd build
cmake ..
make

# 4. Executar com Valgrind
valgrind --leak-check=full --log-file=otclient_leak.txt ./otclient

# 5. Carregar alguns sprites no jogo e fechar

# 6. Analisar relatório
grep "LEAK SUMMARY" otclient_leak.txt
```

### Opção 2: Comparar Antes/Depois (Simples)

```bash
# Ver o commit da correção
git show 1cbf0bf

# Ver exatamente o que mudou
git diff HEAD~1 src/client/thingtype.h src/client/thingtype.cpp
```

---

## 📝 Checklist de Teste

- [ ] Compilou test_animator_leak.cpp
- [ ] Executou com 10 iterações
- [ ] Viu que Animators NÃO foram destruídos no Teste 1
- [ ] Viu que Animators FORAM destruídos no Teste 2
- [ ] (Opcional) Executou com Valgrind
- [ ] (Opcional) Viu "definitely lost" no relatório
- [ ] (Opcional) Testou com 1000 iterações
- [ ] Entendeu por que raw pointers vazam
- [ ] Entendeu por que unique_ptr não vaza

---

## ✅ Conclusão

Você pode comprovar o vazamento de 3 formas:

1. **Visual** 👀: Ver que os destructors não são chamados
2. **Valgrind** 🔬: Detecção precisa com stack trace
3. **Comparação** 📊: Raw pointer vaza, unique_ptr não vaza

**Resultado**: Vazamento COMPROVADO e correção VALIDADA! ✅

---

## 📚 Arquivos Disponíveis

- `test_animator_leak.cpp` - Programa de teste
- `test_valgrind.sh` - Script automatizado com Valgrind
- `valgrind_output.txt` - Relatório completo (gerado após executar)
- `MEMORY_LEAK_TEST_RESULTS.md` - Análise detalhada
- `COMO_TESTAR_VAZAMENTO.md` - Este guia

---

**💡 Dica**: Comece pelo teste rápido para ver o problema com seus próprios olhos!
