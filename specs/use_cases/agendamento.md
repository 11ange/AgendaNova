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
**Ação:** Marcar sessão como "Realizada", "Falta", "Cancelada" ou "Bloqueada".
**Regras de Cumprimento de Contrato:**
- **Compensação Automática**: Se uma sessão for marcada como "Cancelada" ou "Bloqueada", o sistema deve gerar automaticamente uma sessão extra ao final do ciclo (após a última sessão prevista) para garantir que o número total de sessões contratadas seja cumprido.
- **Reajuste de Numeração**: Ao gerar ou remover sessões extras, a numeração sequencial das sessões (1 de 10, 2 de 10, etc.) deve ser reajustada automaticamente para manter a ordem cronológica.
- **Encerramento por Cancelamento**: Se o utilizador optar por "Desmarcar todas as futuras" ao cancelar uma sessão, o treinamento é encerrado imediatamente e o status do paciente é atualizado para inativo (se não houver outros treinamentos).

## 3. Gestão Avançada de Agenda
**Ator:** Administrador / Instrutor

### Trocar Horário do Treinamento
**Objetivo**: Mover todas as sessões restantes de um treinamento para um novo dia da semana ou horário.
**Fluxo**:
1. O utilizador seleciona "Trocar Horário" num treinamento ativo.
2. O sistema valida se o novo horário está disponível e não conflita com outros agendamentos.
3. O sistema move todas as sessões com status "Agendada" para o novo horário, mantendo a sequência.

### Bloquear Dia Inteiro
**Objetivo**: Impedir qualquer atendimento numa data específica (ex: feriado ou imprevisto).
**Fluxo**:
1. O utilizador seleciona uma data e opta por "Bloquear Dia".
2. O sistema marca todos os slots da agenda nesse dia como "Bloqueada".
3. **Compensação**: Para cada sessão de treinamento afetada pelo bloqueio, o sistema aplica a regra de "Compensação Automática", gerando sessões extras ao final dos respetivos contratos.

## 4. Cancelar Treinamento
**Ator:** Administrador
**Ação:** Interromper um plano de treinamento.
**Regras:**
- Alterar status do treinamento para "cancelado".
- Cancelar ou remover todas as sessões futuras com status "Agendada".