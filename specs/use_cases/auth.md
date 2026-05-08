# Casos de Uso: Autenticação

## Login (Sign In)
**Ator:** Instrutor
**Objetivo:** Aceder à aplicação utilizando e-mail e senha.
**Fluxo:**
1. O utilizador introduz o e-mail e a senha na tela de Login.
2. O sistema valida as credenciais via Firebase Authentication.
3. Se bem-sucedido, o utilizador é redirecionado para a tela Home.
4. Se falhar, uma mensagem de erro é exibida.

## Cadastro (Sign Up)
**Ator:** Novo Instrutor
**Objetivo:** Criar uma nova conta na aplicação.
**Fluxo:**
1. O utilizador introduz e-mail e senha na tela de Cadastro.
2. O sistema cria o utilizador no Firebase Authentication.
3. O utilizador é automaticamente logado e redirecionado para a Home.

## Logout (Sign Out)
**Ator:** Instrutor
**Objetivo:** Encerrar a sessão atual.
**Fluxo:**
1. O utilizador seleciona a opção de Logout.
2. O sistema encerra a sessão no Firebase Authentication.
3. O utilizador é redirecionado para a tela de Login.
