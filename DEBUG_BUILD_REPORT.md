# Rapport de Build de Debugging

## ✅ Actions Effectuées

Nous avons appliqué une série de correctifs pour stabiliser l'application et identifier la cause des crashs.

### 1. Modifications AndroidManifest.xml
Ajout des permissions suivantes pour éviter les crashs liés aux accès système :
```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />
```

### 2. Configuration Gradle (build.gradle.kts)
- **MultiDex activé** : `multiDexEnabled = true` (Crucial pour les apps avec Firebase)
- **Minification désactivée** : `isMinifyEnabled = false` (Pour éviter que R8 ne supprime du code nécessaire)
- **SDK Versions** : Vérifiées (Compile: 36, Target: 36)

### 3. Gestion des Erreurs (main.dart)
Ajout de `runZonedGuarded` pour capturer les erreurs qui font crasher l'application avant même qu'elle ne s'affiche :
```dart
runZonedGuarded(() async {
  // ... initialisation ...
}, (error, stackTrace) {
  debugPrint('Erreur non gérée: $error');
  // Cette erreur sera visible dans les logs (adb logcat)
});
```

### 4. Build Spécifique
L'APK a été généré avec la commande :
```bash
flutter build apk --release --no-tree-shake-icons --split-debug-info=./debug-info/
```
- **--no-tree-shake-icons** : Évite les problèmes avec les icônes manquantes (font files).
- **--split-debug-info** : Sépare les infos de debug pour réduire la taille (et parfois aider au diagnostic).

## 📱 Résultat
- **APK généré** : `build/app/outputs/flutter-apk/app-release.apk`
- **Taille** : ~68.7 MB

## 🔍 Prochaines Étapes pour Vous

1. **Installer l'APK** sur le téléphone qui crashait.
2. **Si ça crash encore**, connectez le téléphone par USB et lancez :
   ```bash
   adb logcat | grep -E "flutter|AndroidRuntime|FATAL"
   ```
   Grâce au `runZonedGuarded`, vous devriez voir la cause exacte de l'erreur.

3. **N'oubliez pas** : Si Google Sign-In ne marche pas, c'est probablement à cause des empreintes SHA-1 (voir `GOOGLE_SIGNIN_FIX.md`).
