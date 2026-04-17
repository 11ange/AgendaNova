# Casos de Uso: Pagamento

## 1. Registrar Pagamento
**Ator:** Administrador
**Ação:** Vincular um recebimento a um treinamento ou sessão.
**Regras:**
- Atualizar o status do pagamento no documento correspondente (`pago`, `enviado_convenio`, etc).
- Se for parcelado, registrar o número da parcela atual (`parcelaNumero`).

## 2. Reverter Pagamento
**Ator:** Administrador
**Ação:** Corrigir um erro de lançamento financeiro.
**Regras:**
- Retornar o status do pagamento para "pendente".
- Registrar log ou observação sobre a reversão.