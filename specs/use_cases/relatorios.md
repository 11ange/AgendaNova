# Casos de Uso: Relatórios

## Gerar Relatório Mensal Global
**Ator:** Instrutor
**Objetivo:** Visualizar estatísticas consolidadas de todas as sessões e treinamentos de um mês específico.
**Fluxo:**
1. O utilizador seleciona o mês e o ano.
2. O sistema contabiliza:
   - Total de sessões agendadas, realizadas, faltas, canceladas e bloqueadas no período.
   - Treinamentos iniciados e finalizados, agrupados por forma de pagamento (Pix, Dinheiro, Convénio).
3. O sistema gera um objeto `Relatorio` com os dados consolidados.

## Gerar Relatório Individual do Paciente
**Ator:** Instrutor
**Objetivo:** Obter o histórico detalhado de um paciente específico.
**Fluxo:**
1. O utilizador seleciona um paciente.
2. O sistema recupera:
   - Dados básicos do paciente (nome, idade, responsável).
   - Lista de todos os treinamentos do paciente.
   - Detalhes de cada sessão (data, status, pagamento, observações).
3. O sistema gera um relatório individualizado para visualização ou partilha.
