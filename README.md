# AgendaNova

Instalar Futter no codespaces:
sudo apt update
sudo apt install git curl -y

git clone https://github.com/flutter/flutter.git -b stable

export PATH="$PATH:$(pwd)/flutter/bin"

flutter precache

flutter doctor

flutter config --enable-web

# Crie um diretório para o SDK (se ainda não existir)
mkdir -p ~/Android/sdk

# Defina a variável de ambiente ANDROID_HOME
export ANDROID_HOME=~/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Baixe as ferramentas de linha de comando (substitua a URL pela versão mais recente se necessário)
# Você pode encontrar a URL mais recente em developer.android.com/studio#command-line
wget https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip -O android-cmdline-tools.zip

# Descompacte e mova para o local correto
unzip android-cmdline-tools.zip -d ~/Android/sdk/cmdline-tools
mv ~/Android/sdk/cmdline-tools/cmdline-tools ~/Android/sdk/cmdline-tools/latest

# Aceite as licenças do Android SDK
yes | sdkmanager --licenses

# Instale as plataformas e build-tools necessárias (ex: 34)
sdkmanager "platforms;android-34" "build-tools;34.0.0" "platform-tools"

dart pub global activate flutterfire_cli

export PATH="$PATH":"$HOME/.pub-cache/bin"

source ~/.bashrc

 flutter config --android-sdk C:\Users\lolg\android

flutter run -d web-server


Adicione sua imagem

Crie uma pasta na raiz do seu projeto chamada assets, e dentro dela outra chamada icon.

Coloque sua imagem de ícone principal (em alta resolução, de preferência 1024x1024 pixels) dentro dessa pasta e nomeie-a como icon.png. O caminho deve ser assets/icon/icon.png, como configurado no pubspec.yaml.

flutter pub run flutter_launcher_icons