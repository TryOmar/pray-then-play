import 'dart:io';

void main() async {
  print('====================================================');
  print('  PRAY THEN PLAY - WINDOWS INSTALLER BUILD SCRIPT   ');
  print('====================================================\n');

  // 1. Build Flutter Windows Release
  print('🔨 Step 1: Building Flutter Windows Release...');
  final buildResult = await Process.run(
    'flutter',
    ['build', 'windows', '--release'],
    runInShell: true,
  );
  if (buildResult.exitCode != 0) {
    print('❌ Failed to build Windows release:\n${buildResult.stderr}');
    exit(1);
  }
  print('✅ Flutter Windows Release built successfully!\n');

  // 2. Find Inno Setup Compiler (ISCC.exe)
  print('🔍 Step 2: Locating Inno Setup Compiler (ISCC.exe)...');
  final possiblePaths = [
    r'C:\Users\EVO TECH\AppData\Local\Programs\Inno Setup 6\ISCC.exe',
    r'C:\Program Files (x86)\Inno Setup 6\ISCC.exe',
    r'C:\Program Files\Inno Setup 6\ISCC.exe',
  ];

  String? isccPath;
  for (final p in possiblePaths) {
    if (File(p).existsSync()) {
      isccPath = p;
      break;
    }
  }

  if (isccPath == null) {
    print('⚠️ ISCC.exe not found in standard paths. Searching in PATH...');
    final whichResult = await Process.run('where', ['ISCC.exe'], runInShell: true);
    if (whichResult.exitCode == 0) {
      isccPath = whichResult.stdout.toString().trim().split('\n').first.trim();
    }
  }

  if (isccPath == null) {
    print('❌ Inno Setup is not installed. Please install Inno Setup 6:');
    print('   winget install -e --id JRSoftware.InnoSetup');
    exit(1);
  }

  print('✅ Found ISCC at: $isccPath\n');

  // 3. Compile Inno Setup Script
  print('📦 Step 3: Compiling Installer with Inno Setup...');
  final issFile = File('packaging/windows/setup.iss').absolute.path;
  final isccResult = await Process.run(
    isccPath,
    [issFile],
    runInShell: true,
  );

  if (isccResult.exitCode != 0) {
    print('❌ Inno Setup compilation failed:\n${isccResult.stderr}\n${isccResult.stdout}');
    exit(1);
  }

  print('====================================================');
  print('🎉 WINDOWS INSTALLER CREATED SUCCESSFULLY!');
  print('📁 Location: build\\windows\\installer\\PrayThenPlay-Setup-v2.0.0-x64.exe');
  print('====================================================\n');
}
