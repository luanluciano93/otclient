# 🚀 Teste Rápido de Vazamento - 3 Comandos

## Para testar o vazamento COM LOGS SIMPLES:

```bash
# 1. Aplicar logging
./test_memory_leak_with_logs.sh apply

# 2. Compilar
cd build && cmake .. && make

# 3. Executar e observar
./otclient
```

### O que observar:

**❌ COM VAZAMENTO:**
```
[ANIMATOR] Created #1 | Total alive: 1
[ANIMATOR] Created #2 | Total alive: 2
... (cliente fecha)
... (NENHUM "Destroyed"!)
Total alive: 2 ⚠️ VAZAMENTO!
```

**✅ SEM VAZAMENTO:**
```
[ANIMATOR] Created #1 | Total alive: 1
[ANIMATOR] Created #2 | Total alive: 2
... (cliente fecha)
[ANIMATOR] Destroyed #2 | Total alive: 1
[ANIMATOR] Destroyed #1 | Total alive: 0
Total alive: 0 ✓ PERFEITO!
```

### Cleanup:
```bash
./test_memory_leak_with_logs.sh remove
```

---

## Ou, para teste COM VALGRIND (mais profissional):

```bash
# Teste standalone (não precisa compilar otclient)
./test_animator_leak 10
./test_valgrind.sh
```

---

## Documentação Completa

- **TESTE_VAZAMENTO_COM_LOGS.md** - Guia completo com logs
- **COMO_TESTAR_VAZAMENTO.md** - Guia do teste standalone
- **MEMORY_LEAK_TEST_RESULTS.md** - Análise técnica detalhada

---

**Escolha seu método:**
- 🎯 **Logs simples** = Rápido, fácil, visual
- 🔬 **Valgrind** = Profissional, preciso, completo
- 📊 **Ambos** = Melhor de dois mundos!
