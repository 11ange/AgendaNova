# Casos de Uso: Treinamento e Sessão

## 1. Criar Treinamento
**Ator:** Administrador
**Contexto:** Um paciente deseja iniciar um plano de treinamentos semanais.
**Regras Técnicas:**
- Verificar se o paciente já possui treinamento ativo (`hasActiveTreinamento`).
- Verificar sobreposição de horário (`hasOverlap`).
- Validar se o horário está na `AgendaDisponibilidade`.
**Geração de Sessões:**
- Gerar N sessões baseadas no `numeroSessoesTotal`.
- **Salto de Bloqueio:** Se a data calculada possuir uma sessão com status "Bloqueada", pular 7 dias para a próxima data disponível.

## 2. Atualizar Status da Sessão
**Ator:** Instrutor
**Ação:** Marcar sessão como "Realizada", "Faltou" ou "Reagendada".
**Regras:**
- Se o status mudar para "Realizada", verificar se há necessidade de disparar fluxo de pagamento.
- Se for "Reagendada", permitir a criação de uma nova data vinculada ao mesmo `treinamentoId`.

## 3. Cancelar Treinamento
**Ator:** Administrador
**Ação:** Interromper um plano de treinamento.
**Regras:**
- Alterar status do treinamento para "cancelado".
- Cancelar ou remover todas as sessões futuras com status "Agendada".