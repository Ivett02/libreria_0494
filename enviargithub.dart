import 'dart:io';

void main() async {
  // Colores ANSI para una mejor estética en la terminal
  const green = '\x1B[32m';
  const blue = '\x1B[34m';
  const yellow = '\x1B[33m';
  const reset = '\x1B[0m';
  const bold = '\x1B[1m';

  print('\n$blue$bold==========================================$reset');
  print('$blue$bold   🚀 AGENTE INTERACTIVO GITHUB - DART   $reset');
  print('$blue$bold==========================================$reset\n');

  // 1. Pedir el link del repositorio
  stdout.write('$bold[1/3]$reset Introduce el link del repositorio de GitHub: ');
  String? repoUrl = stdin.readLineSync()?.trim();
  if (repoUrl == null || repoUrl.isEmpty) {
    print('$yellow⚠️ Error: El link del repositorio es obligatorio.$reset');
    return;
  }

  // 2. Pedir el mensaje del commit
  stdout.write('$bold[2/3]$reset Introduce el mensaje del commit: ');
  String? commitMessage = stdin.readLineSync()?.trim();
  if (commitMessage == null || commitMessage.isEmpty) {
    print('$yellow⚠️ Error: El mensaje de commit es obligatorio.$reset');
    return;
  }

  // 3. Pedir el nombre de la rama
  stdout.write('$bold[3/3]$reset Introduce el nombre de la rama $blue(Enter para "main")$reset: ');
  String? branchName = stdin.readLineSync()?.trim();
  if (branchName == null || branchName.isEmpty) {
    branchName = 'main';
  }

  print('\n$blue⚙️ Procesando comandos de Git...$reset\n');

  try {
    // Verificar si git esta inicializado
    if (!Directory('.git').existsSync()) {
      print('$yellow📦 Inicializando repositorio git...$reset');
      await _runCommand('git', ['init']);
    }

    print('$yellow➕ Agregando archivos...$reset');
    await _runCommand('git', ['add', '.']);

    print('$yellow💾 Realizando commit...$reset');
    await _runCommand('git', ['commit', '-m', commitMessage]);

    print('$yellow🌿 Configurando rama: $branchName...$reset');
    await _runCommand('git', ['branch', '-M', branchName]);

    print('$yellow🔗 Configurando remote "origin"...$reset');
    var remoteResult = await Process.run('git', ['remote', 'add', 'origin', repoUrl]);
    if (remoteResult.exitCode != 0) {
      // Si ya existe, lo actualizamos
      await _runCommand('git', ['remote', 'set-url', 'origin', repoUrl]);
    }

    print('$yellow⬆️ Subiendo código a GitHub (esto puede tardar dependiendo de tu conexión)...$reset');
    await _runCommand('git', ['push', '-u', 'origin', branchName]);

    print('\n$green$bold✨ ¡ÉXITO! Tu proyecto ha sido enviado correctamente a GitHub.$reset');
    print('$green🔗 Repo: $repoUrl$reset\n');

  } catch (e) {
    print('\n$yellow❌ Error detectado:$reset');
    print(e.toString());
    print('\n${yellow}Asegúrate de tener Git instalado y haber creado el repositorio en GitHub.$reset\n');
  }
}

/// Función auxiliar para ejecutar comandos y mostrar salida en caso de error
Future<void> _runCommand(String command, List<String> args) async {
  var result = await Process.run(command, args);
  if (result.exitCode != 0) {
    throw Exception('Error en "$command ${args.join(' ')}":\n${result.stderr}');
  }
}
