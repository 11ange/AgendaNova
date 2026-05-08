# Casos de Uso: Sistema

## 1. Definir Agenda de Disponibilidade
**Ator:** Instrutor
**Ação:** Define os horários de trabalho para cada dia da semana.
**Regras:**
- As alterações não afetam treinamentos já criados, apenas novas validações de `CriarTreinamento`.

## 2. Gerar Relatórios
**Tipos:**
- **Individual:** Histórico de frequência e financeiro de um único paciente.
- **Mensal Global:** Consolidado de sessões realizadas e faturamento do mês.

## 3. Interface e Identidade Visual (UI)
**Indicadores de Status e Pagamento:**
O sistema utiliza indicadores textuais e visuais para facilitar a gestão das sessões:

1. **Status de Execução:**
   - **Agendada:** Apenas cor Azul Clara (sem texto informativo).
   - **Realizada:** Texto "REALIZADA" (Azul Escuro).
   - **Falta:** Texto "FALTA" (Vermelho).
   - **Cancelada:** Texto "CANCELADA" (Cinza).

2. **Status de Pagamento (Nomenclatura Padrão):**
   - **Pendente:** Texto "PENDENTE" (Laranja).
   - **Realizado:** Texto "**PAGO**" (Verde) - Padronizado em todas as telas para evitar confusão com o status de execução "Realizada".

3. **Visualização Combinada:**
   - Em listas de sessões e controle de pagamentos, os status são exibidos de forma combinada quando aplicável (ex: `REALIZADA | PAGO`).

## 4. Regras de Negócio de Sessões
- **Re-indexação Automática:** As sessões são numeradas (ex: "1 de 10") e mantêm a ordem cronológica mesmo após reagendamentos.
- **Compensação Automática:** Sessões canceladas ou bloqueadas são automaticamente adicionadas ao final do treinamento para cumprir o contrato.