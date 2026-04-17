# Casos de Uso: Paciente

## 1. Cadastrar Paciente
**Ator:** Administrador
**Contexto:** O administrador deseja registrar um novo paciente no sistema.
**Ação:** Preenche os dados obrigatórios (Nome, Data de Nascimento, Responsável).
**Regras:**
- Validar se já existe um paciente com o mesmo nome (`pacienteExistsByName`).
- Formatar a data de nascimento como `dd/MM/yyyy` antes de salvar.
**Resultado:** Documento criado na coleção `pacientes` com status "ativo".

## 2. Inativar/Reativar Paciente
**Ator:** Administrador
**Ação:** Altera o status de um paciente existente.
**Regras:**
- Ao inativar, o paciente não deve aparecer em listas de seleção de novos treinamentos.
- O histórico de sessões e pagamentos deve ser preservado.