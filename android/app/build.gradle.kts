plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Certifique-se de que esta linha está presente
}

android {
    // Adicionado ndkVersion para compatibilidade com Firebase
    ndkVersion = "27.0.12077973" // CORREÇÃO: Adicione esta linha

    namespace = "com.example.agendanova"
    compileSdk = 34 // Ou a versão mais recente que você está usando

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/tools/publishing/app-signing#application-id)
        applicationId = "com.example.agendanova"
        // minSdk aumentado para 23 para compatibilidade com Firebase Auth
        minSdk = 23 // CORREÇÃO: Altere de 21 para 23
        targetSdk = 34 // Ou a versão mais recente que você está usando
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release`.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
    buildFeatures {
        viewBinding = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Dependências do Firebase já devem estar no seu pubspec.yaml
    // e serão puxadas automaticamente pelo Flutter.
    // Certifique-se de que o google-services.json está na pasta android/app/
}

