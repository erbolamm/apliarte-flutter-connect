# ApliArte Flutter Connect — Paquete Oficial de Wi-Fi Direct P2P

> Plugin oficial de Flutter para conexión Wi-Fi Direct P2P en Android e iOS | Flutter & Dart
> Único desarrollador: Javier Mateo. Idioma: Español siempre con Javier; inglés técnico estándar en código y commits.

Este archivo es la **fuente canónica de verdad** para el desarrollo en `/Users/apliarte/repos/apliarte-flutter-connect`.
Cualquier agente que opere aquí debe acatar estrictamente estas reglas.

---

## 1. Misión del Proyecto

`apliarte_flutter_connect` es la librería soberana para conectividad directa punto a punto (Wi-Fi Direct P2P) del ecosistema ApliArte:
1. **Soporte nativo moderno**: Compatible con Android Gradle 8.x, Java 17 y ciclo de vida seguro (`onDetachedFromActivity`).
2. **Reemplazo del parche obsoleto**: Elimina definitivamente la dependencia `flutter_p2p_connection` parcheada en CalcaApp.
3. **API limpia y desacoplada**: Contratos Dart tipados para descubrimiento de pares, negociación de grupo, sockets TCP y transferencia de datos.
4. **Publicación canónica**: Mantenido bajo la organización oficial ApliArte para su consumo en CalcaApp y en `pub.dev`.

---

## 2. Reglas Canónicas de Comunicación y Estructura en 3 Bloques

1. **Estructura en 3 Bloques (Lección 55)**:
   - *Bloque 1 (Al principio)*: Reporte de archivos actualizados en formato de árbol con texto a la mitad del tamaño estándar (`<small>`), compacto para pantalla móvil sin recargar la lectura y usando solo nombres base sin enlaces `file:///` ni `/Users/...`.
   - *Bloque 2 (En medio)*: Explicación concisa y natural para escucha en TTS, usando exclusivamente nombres base de archivo en código (`apliarte_flutter_connect.dart`, `pubspec.yaml`) sin rutas largas ni enlaces Markdown a rutas locales.
   - *Bloque 3 (Al final)*: Exclusivamente la pregunta y el menú de opciones estrictamente numeradas (`1.`, `2.`, `3.`...).
2. **Cero Emojis (Lección 34)**: Prohibido el uso de emojis en las respuestas a Javier.
3. **Listas Estrictamente Numeradas**: Toda pregunta, propuesta u opción debe presentarse en una lista estrictamente numerada (`1.`, `2.`, `3.`).
4. **Una Pregunta a la Vez**: Formular como máximo una sola pregunta por turno y esperar respuesta.
5. **Higiene Git**: Staging quirúrgico archivo por archivo (`git add <archivo>`). Commits convencionales en inglés (`feat:`, `fix:`, `docs:`, `chore:`), sin firmas de IA ni `Co-Authored-By`.
6. **Soberanía y Delete Test (ADR-0013 / ADR-0015)**: La carpeta `control-erbolamm/` vive excluida en `.gitignore`. Si se borra, el paquete sigue compilando y pasando sus pruebas sin errores.
7. **Memoria**: Uso obligatorio de Engram (`project: "apliarte-flutter-connect"`) para registrar hitos y decisiones técnicas.
