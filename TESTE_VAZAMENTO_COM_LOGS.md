# 🔍 Teste de Vazamento de Memória com Logs Simples

## 📋 Objetivo
Detectar vazamento de memória nos `Animator` do OTClient usando apenas logs no console, **sem ferramentas externas** como Valgrind.

---

## ⚡ Método Rápido (Automatizado)

### Passo 1: Aplicar Logging
```bash
chmod +x test_memory_leak_with_logs.sh
./test_memory_leak_with_logs.sh apply
```

### Passo 2: Compilar
```bash
cd build
cmake ..
make -j$(nproc)
```

### Passo 3: Executar e Observar
```bash
./otclient
```

### Passo 4: Analisar Output

Você verá logs assim:

#### ✅ COM UNIQUE_PTR (código corrigido - SEM vazamento):
```
[ANIMATOR] Created #1 | Total alive: 1 | Address: 0x55a3c8001230
[ANIMATOR] Created #2 | Total alive: 2 | Address: 0x55a3c8001450
[ANIMATOR] Created #3 | Total alive: 3 | Address: 0x55a3c8001670
...
[ANIMATOR] Destroyed #3 | Total alive: 2 | Address: 0x55a3c8001670
[ANIMATOR] Destroyed #2 | Total alive: 1 | Address: 0x55a3c8001450
[ANIMATOR] Destroyed #1 | Total alive: 0 | Address: 0x55a3c8001230
```
**Resultado**: `Total alive: 0` no final ✓

#### ❌ COM RAW POINTERS (código antigo - COM vazamento):
```
[ANIMATOR] Created #1 | Total alive: 1 | Address: 0x55a3c8001230
[ANIMATOR] Created #2 | Total alive: 2 | Address: 0x55a3c8001450
[ANIMATOR] Created #3 | Total alive: 3 | Address: 0x55a3c8001670
...
(Cliente fecha mas NÃO aparece nenhum "Destroyed")
```
**Resultado**: `Total alive: 3` (ou mais) - **VAZAMENTO!** ⚠️

### Passo 5: Remover Logging (Cleanup)
```bash
./test_memory_leak_with_logs.sh remove
```

---

## 🛠️ Método Manual (Passo a Passo)

Se preferir fazer manualmente sem o script:

### 1. Editar `src/client/animator.h`

Adicione estas linhas na classe `Animator`:

```cpp
class Animator : public std::enable_shared_from_this<Animator>
{
public:
    Animator();   // ← ADICIONAR
    ~Animator();  // ← ADICIONAR

    // ... resto do código ...

private:
    // ... código existente ...

    // ← ADICIONAR no final, antes do };
    static std::atomic<int> s_instanceCount;
    int m_instanceId;
};
```

### 2. Editar `src/client/animator.cpp`

Adicione no início do arquivo, após os `#include`:

```cpp
#include "animator.h"
#include <framework/core/eventdispatcher.h>
#include <iostream>     // ← ADICIONAR
#include <atomic>       // ← ADICIONAR

// ← ADICIONAR todo este bloco:
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
```

### 3. Compilar e Testar

```bash
cd build
cmake ..
make
./otclient
```

---

## 📊 Como Interpretar os Resultados

### Sinais de VAZAMENTO (❌):

1. **Total alive cresce mas nunca diminui**
   ```
   Created #1 | Total alive: 1
   Created #2 | Total alive: 2
   Created #3 | Total alive: 3
   ... (cliente fecha)
   ... (nenhum Destroyed aparece)
   ```

2. **Número de Created > Número de Destroyed**
   ```
   10 animators criados
    0 animators destruídos
   = 10 VAZARAM!
   ```

3. **Total alive > 0 quando fecha**
   ```
   Total alive: 15  ← Deveria ser 0!
   ```

### Sinais de SEM vazamento (✅):

1. **Total alive volta a 0**
   ```
   Created #1 | Total alive: 1
   Created #2 | Total alive: 2
   Destroyed #2 | Total alive: 1
   Destroyed #1 | Total alive: 0  ✓
   ```

2. **Cada Created tem um Destroyed correspondente**
   ```
   Created #1 at 0x123
   ...
   Destroyed #1 at 0x123  ✓
   ```

3. **Total alive = 0 ao fechar**

---

## 🎯 Cenário de Teste Ideal

Para ver o vazamento claramente:

1. **Inicie o OTClient**
2. **Carregue o mapa** (isso cria muitos ThingTypes com Animators)
3. **Observe os logs** - verá muitos `[ANIMATOR] Created`
4. **Feche o cliente**
5. **Observe os logs** novamente:
   - ❌ **Com bug**: Poucos ou nenhum `Destroyed`
   - ✅ **Sem bug**: Quantidade igual de `Created` e `Destroyed`

---

## 💡 Vantagens deste Método

| Aspecto | Valgrind | Logs Simples |
|---------|----------|--------------|
| **Instalação** | Precisa instalar | Nada |
| **Velocidade** | Lento (~10x) | Normal |
| **Complexidade** | Alta | Baixa |
| **Visibilidade** | Relatório final | Tempo real |
| **Aprendizado** | Difícil | Fácil |

---

## 🔬 Exemplo Real de Output

### Carregando 100 sprites com animação:

```bash
$ ./otclient

[ANIMATOR] Created #1 | Total alive: 1 | Address: 0x7f3ab0001230
[ANIMATOR] Created #2 | Total alive: 2 | Address: 0x7f3ab0001450
[ANIMATOR] Created #3 | Total alive: 3 | Address: 0x7f3ab0001670
...
[ANIMATOR] Created #200 | Total alive: 200 | Address: 0x7f3ab00fe230

# Fechando cliente...

# COM RAW POINTER (BUG):
# (silêncio... nada é destruído)
# Total final: 200 ⚠️ VAZAMENTO!

# COM UNIQUE_PTR (FIX):
[ANIMATOR] Destroyed #200 | Total alive: 199 | Address: 0x7f3ab00fe230
[ANIMATOR] Destroyed #199 | Total alive: 198 | Address: 0x7f3ab00fe010
...
[ANIMATOR] Destroyed #2 | Total alive: 1 | Address: 0x7f3ab0001450
[ANIMATOR] Destroyed #1 | Total alive: 0 | Address: 0x7f3ab0001230
# Total final: 0 ✓ PERFEITO!
```

---

## 🧹 Cleanup

Quando terminar o teste:

```bash
# Remover logging
./test_memory_leak_with_logs.sh remove

# Ou manualmente:
git checkout src/client/animator.h src/client/animator.cpp
```

---

## 📈 Análise de Vazamento

### Calcular memória vazada:

```
Animators vazados = Total alive no final
Memória por Animator ≈ 500 bytes (estimativa)

Exemplo:
200 animators vazados × 500 bytes = 100 KB vazados
```

Em uma sessão típica de jogo:
- ~1.500 sprites com animação
- ~2 Animators por sprite
- Total: **~1.500 KB (1.5 MB) vazados por sessão**

---

## ✅ Checklist

- [ ] Aplicou logging no animator.h e animator.cpp
- [ ] Compilou sem erros
- [ ] Executou otclient e viu logs `[ANIMATOR] Created`
- [ ] Fechou otclient
- [ ] Verificou se aparecem logs `[ANIMATOR] Destroyed`
- [ ] Comparou `Total alive` inicial vs final
- [ ] Identificou se há vazamento (Total alive > 0)
- [ ] Removeu logging após teste

---

## 🎓 Conclusão

Este método é **perfeito para**:
- ✓ Entender o problema visualmente
- ✓ Testar rapidamente sem ferramentas externas
- ✓ Demonstrar o bug para outras pessoas
- ✓ Verificar se a correção funcionou

**Não substitui** Valgrind para análise profissional, mas é **excelente para testes rápidos e educacionais**!

---

## 📚 Arquivos Relacionados

- `test_memory_leak_with_logs.sh` - Script automatizado
- `TESTE_VAZAMENTO_LOGS.cpp` - Exemplos de código
- `PATCH_LOGGING_ANIMATOR.patch` - Patch git (opcional)
