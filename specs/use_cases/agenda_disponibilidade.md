# Casos de Uso: Agenda de Disponibilidade

## Definir Agenda de Trabalho
**Ator:** Instrutor
**Objetivo:** Estabelecer os horários de atendimento disponíveis para cada dia da semana.
**Regras:**
- O utilizador pode adicionar ou remover horários livremente para qualquer dia da semana (Segunda a Domingo).
- **Validação de Remoção**: Não é permitido remover um horário se houver sessões futuras com status "Agendada" já marcadas para esse dia e hora.
- Alterações na agenda não afetam treinamentos já criados, exceto para impedir a remoção de horários com compromissos ativos.
- Novos treinamentos só podem ser criados em horários definidos nesta agenda.
