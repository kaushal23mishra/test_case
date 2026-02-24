import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Engineering Standards Compliance Tests', () {
    final libDir = Directory('lib');

    test('Directory structure follows the layered architecture', () {
      final requiredFolders = [
        'core',
        'models',
        'services',
        'controllers',
        'ui',
        'repositories',
      ];

      for (final folder in requiredFolders) {
        final dir = Directory(p.join('lib', folder));
        expect(dir.existsSync(), isTrue, 
            reason: 'Folder "lib/$folder" is missing but required by Section 1.2 of Standards.');
      }
    });

    test('Files in lib/ use snake_case naming convention', () {
      final files = libDir.listSync(recursive: true).whereType<File>();
      final snakeCasePattern = RegExp(r'^[a-z0-9_]+\.dart$');

      for (final file in files) {
        final filename = p.basename(file.path);
        if (filename.endsWith('.dart')) {
          expect(snakeCasePattern.hasMatch(filename), isTrue,
              reason: 'File "${file.path}" must be snake_case as per Section 2.3.');
        }
      }
    });

    test('Prohibit relative imports (Package-only imports enforced)', () {
      final files = libDir.listSync(recursive: true).whereType<File>();
      final relativeImportPattern = RegExp(r'''import\s+['"]\.\.?/''');

      for (final file in files) {
        if (file.path.endsWith('.dart')) {
          final content = file.readAsStringSync();
          expect(relativeImportPattern.hasMatch(content), isFalse,
              reason: 'File "${file.path}" uses relative imports which are prohibited by Section 2.3.');
        }
      }
    });

    test('Prohibit raw print statements (Use logging instead)', () {
      final files = libDir.listSync(recursive: true).whereType<File>();
      final printPattern = RegExp(r'\bprint\s*\(');

      for (final file in files) {
        if (file.path.endsWith('.dart') && !file.path.contains('logger_utils.dart')) {
          final content = file.readAsStringSync();
          expect(printPattern.hasMatch(content), isFalse,
              reason: 'File "${file.path}" uses print() instead of the logging package (Section 6.1).');
        }
      }
    });

    test('Service layer and Engine logic are pure and sync (Excluding comments)', () {
      final serviceDir = Directory(p.join('lib', 'services'));
      if (serviceDir.existsSync()) {
        final serviceFiles = serviceDir.listSync(recursive: true).whereType<File>();
        for (final file in serviceFiles) {
          if (file.path.endsWith('.dart')) {
            // Strip comments to avoid false positives on words like "async" in documentation
            final rawContent = file.readAsStringSync();
            final contentWithoutComments = rawContent
                .replaceAll(RegExp(r'//.*'), '')
                .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');

            expect(contentWithoutComments.contains('Future<'), isFalse, 
                reason: 'Service logic in "${file.path}" must be synchronous (Section 1.3).');
            expect(contentWithoutComments.contains('async'), isFalse,
                reason: 'Service logic in "${file.path}" must be pure and sync (Section 1.3).');
          }
        }
      }
    });

    test('Double comparisons use kDoubleTolerance', () {
      final files = libDir.listSync(recursive: true).whereType<File>();
      // Match something like == 0.0 or == 1.23, avoiding comments
      final unsafeDoubleComparison = RegExp(r'==\s*[0-9]+\.[0-9]+');

      for (final file in files) {
        final path = file.path;
        if (path.endsWith('.dart') && 
            !path.contains('engine_config.dart') && 
            !path.contains('_test.dart')) {
          final content = file.readAsStringSync();
          final contentWithoutComments = content
              .replaceAll(RegExp(r'//.*'), '')
              .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
              
          expect(unsafeDoubleComparison.hasMatch(contentWithoutComments), isFalse,
              reason: 'File "$path" might be using direct double comparison. Use kDoubleTolerance (Section 8.5).');
        }
      }
    });
    test('Documentation files exist and contain mandatory sections', () {
      final docs = [
        'docs/PROJECT_STANDARDS.md',
        'docs/trade_evaluation_specification.md',
        'docs/CHANGELOG.md',
        'README.md',
      ];

      for (final doc in docs) {
        final file = File(doc);
        expect(file.existsSync(), isTrue, reason: 'Documentation file "$doc" is missing.');
        expect(file.readAsStringSync().trim().isNotEmpty, isTrue, reason: 'Documentation file "$doc" is empty.');
      }

      // Explicitly check for Smoke Test rule (Section 6.2)
      final standards = File('docs/PROJECT_STANDARDS.md').readAsStringSync();
      expect(standards.contains('Section 6.2') || standards.contains('Smoke Test'), isTrue, 
          reason: 'Section 6.2 (Smoke Test) must be documented in Project Standards.');

      // Check for Silent on Success rule
      expect(standards.contains('Silent on Success'), isTrue,
          reason: '"Silent on Success" rule must be documented in Project Standards (Section 8.1).');
    });
  });
}
