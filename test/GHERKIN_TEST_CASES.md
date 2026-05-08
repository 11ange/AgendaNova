# AgendaNova - Gherkin Test Specifications

Este documento descreve os comportamentos esperados do sistema AgendaNova através de cenários de teste escritos em formato Gherkin (Given/When/Then).

## Funcionalidade: Autenticação
Como um fonoaudiólogo
Eu quero entrar e sair do sistema com segurança
Para que meus dados e os dos pacientes fiquem protegidos

### Cenário: Login com sucesso
  Dado que o usuário tem uma conta registrada com email "fonov@teste.com"
  Quando o usuário insere o email "fonov@teste.com" e a senha "123456"
  Então o sistema deve autenticar o usuário e redirecioná-lo para a tela Home

### Cenário: Erro de login com credenciais inválidas
  Dado que o usuário tem uma conta registrada
  Quando o usuário insere um email não cadastrado ou senha incorreta
  Então o sistema deve exibir uma mensagem de erro "Credenciais inválidas"

---

## Funcionalidade: Gestão de Pacientes
Como um fonoaudiólogo
Eu quero gerenciar os dados cadastrais dos meus pacientes
Para manter o histórico clínico organizado

### Cenário: Cadastrar novo paciente com sucesso
  Dado que estou na tela de cadastro de paciente
  Quando preencho o nome "João Silva", data de nascimento "15/05/2010" e nome do responsável "Maria Silva"
  E clico em "Salvar"
  Então o paciente deve ser armazenado com o status "ativo"

### Cenário: Inativar paciente automaticamente
  Dado que o paciente "João Silva" tem um treinamento "ativo"
  Quando a última sessão desse treinamento é marcada como "Realizada" e o pagamento está concluído
  Então o sistema deve alterar o status do treinamento para "Finalizado"
  E o status do paciente deve ser alterado automaticamente para "inativo"

---

## Funcionalidade: Gestão de Treinamentos e Agendamentos
Como um fonoaudiólogo
Eu quero criar ciclos de treinamento e gerenciar as sessões
Para garantir que o contrato de treinamento seja cumprido

### Cenário: Criar treinamento e gerar sessões automáticas
  Dado que o paciente "João Silva" está ativo e sem treinamentos pendentes
  Quando crio um novo treinamento para "Segunda-feira" às "14:00" com "10 sessões"
  Então o sistema deve gerar 10 documentos de "Sessão" nas datas subsequentes correspondentes às segundas-feiras

### Cenário: Compensação automática por cancelamento (Sessão Extra)
  Dado que existe um treinamento com 10 sessões e a sessão 3 está "Agendada"
  Quando eu altero o status da sessão 3 para "Cancelada"
  Então o sistema deve reindexar as sessões 4 a 10 para 3 a 9
  E o sistema deve criar uma nova sessão (número 10) ao final do cronograma para compensar o cancelamento

### Cenário: Cancelamento total de treinamento (Desmarcar todas futuras)
  Dado que um treinamento tem sessões pendentes para o futuro
  Quando eu altero o status de uma sessão para "Cancelada" marcando a opção "Desmarcar todas futuras"
  Então todas as sessões futuras deste treinamento devem ser removidas
  E o status do treinamento deve ser alterado para "cancelado"

---

## Funcionalidade: Gestão de Pagamentos
Como um fonoaudiólogo
Eu quero registrar os recebimentos dos treinamentos
Para manter o controle financeiro do consultório

### Cenário: Registro de pagamento via Convênio (Guia)
  Dado que o treinamento do paciente foi configurado como "Convenio"
  Quando eu registro o número da guia "GUIA-123" e a data de envio
  Então o pagamento deve ser associado ao treinamento com o status "Realizado"

### Cenário: Pendência de pagamento ao fim do treinamento
  Dado que um treinamento de 10 sessões chegou à 10ª sessão
  Quando a 10ª sessão é marcada como "Realizada" mas ainda existem sessões com pagamento "Pendente"
  Então o treinamento deve ficar com o status "Pendente Pagamento"
  E o paciente deve permanecer "ativo" até que o pagamento seja quitado

---

## Funcionalidade: Agenda de Disponibilidade
Como um fonoaudiólogo
Eu quero definir meus horários de atendimento
Para organizar meus agendamentos semanais

### Cenário: Definir horários de trabalho
  Dado que estou na configuração de agenda
  Quando adiciono os horários "08:00", "09:00" e "10:00" para "Terça-feira"
  Então esses horários devem estar disponíveis para novos treinamentos neste dia

### Cenário: Impedir remoção de horário ocupado
  Dado que o horário de "Segunda-feira 14:00" tem sessões agendadas para pacientes
  Quando tento remover este horário da minha agenda de disponibilidade
  Então o sistema deve exibir um erro e impedir a remoção até que as sessões futuras sejam movidas ou canceladas

---

## Funcionalidade: Relatórios
Como um fonoaudiólogo
Eu quero gerar relatórios de produtividade e histórico
Para analisar o desempenho do consultório

### Cenário: Gerar relatório individual de paciente
  Dado que o paciente "João Silva" concluiu 2 treinamentos
  Quando solicito o "Relatório Individual" para este paciente
  Então o sistema deve retornar um documento contendo a contagem total de sessões realizadas, faltas e status de pagamento de todos os seus treinamentos

### Cenário: Gerar relatório mensal global
  Dado que estamos no mês de Maio de 2026
  Quando gero o "Relatório Mensal"
  Então o sistema deve consolidar o total de sessões realizadas, iniciadas e finalizadas por todos os pacientes no período solicitado
