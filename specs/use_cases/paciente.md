# Casos de Uso: Paciente

## 1. Cadastrar Paciente
**Ator:** Administrador
**Contexto:** O administrador deseja registrar um novo paciente no sistema.
**Ação:** Preenche os dados obrigatórios (Nome, Data de Nascimento, Responsável).
**Regras de Unicidade e Validação:**
- **Normalização de Nome:** O sistema remove espaços extras e ignora maiúsculas/minúsculas para comparação (campo `nomeBusca`).
- **Bloqueio de Duplicados:** Se existir um paciente (Ativo, Inativo ou **Arquivado**) com o mesmo nome normalizado e mesma data de nascimento, o cadastro é bloqueado e o sistema oferece a opção de reativar o registro existente.
- **Alerta de Homônimos:** Se existir um paciente com o mesmo nome normalizado, mas data de nascimento diferente, o sistema exibe um aviso solicitando confirmação para prosseguir com o novo cadastro.
- **Formatação:** A data de nascimento é validada e formatada como `dd/MM/yyyy`.

## 2. Inativar/Reativar Paciente
**Ator:** Administrador
**Ação:** Altera o status de um paciente existente.
**Regras:**
- Ao inativar, o paciente não deve aparecer em listas de seleção de novos treinamentos.
- O histórico de sessões e pagamentos é preservado.
- A reativação de um paciente arquivado limpa a data de arquivamento e retorna o status para "ativo".

## 3. Arquivar Paciente (Soft Delete)
**Ator:** Administrador
**Contexto:** O administrador deseja remover um paciente da lista de inativos sem excluir permanentemente os dados.
**Ação:** Seleciona a opção "Arquivar" na lista de pacientes inativos.
**Regras:**
- O status é alterado para `arquivado`.
- O paciente deixa de aparecer na lista de inativos, sendo movido para uma visualização restrita de "Arquivados".
- O histórico é mantido para fins de auditoria e relatórios.