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
        expect(
          dir.existsSync(),
          isTrue,
          reason:
              'Folder "lib/$folder" is missing but required by Section 1.2 of Standards.',
        );
      }
    });

    test('Files in lib/ use snake_case naming convention', () {
      final files = libDir.listSync(recursive: true).whereType<File>();
      final snakeCasePattern = RegExp(r'^[a-z0-9_]+\.dart$');

      for (final file in files) {
        final filename = p.basename(file.path);
        if (filename.endsWith('.dart')) {
          expect(
            snakeCasePattern.hasMatch(filename),
            isTrue,
            reason:
                'File "${file.path}" must be snake_case as per Section 2.3.',
          );
        }
      }
    });

    test('Prohibit relative imports (Package-only imports enforced)', () {
      final files = libDir.listSync(recursive: true).whereType<File>();
      final relativeImportPattern = RegExp(r'''import\s+['"]\.\.?/''');

      for (final file in files) {
        if (file.path.endsWith('.dart')) {
          final content = file.readAsStringSync();
          expect(
            relativeImportPattern.hasMatch(content),
            isFalse,
            reason:
                'File "${file.path}" uses relative imports which are prohibited by Section 2.3.',
          );
        }
      }
    });

    test('Strict Dependency Flow (Section 1.4)', () {
      final layers = [
        'ui',
        'controllers',
        'repositories',
        'services',
        'models',
        'core',
      ];

      for (int i = 0; i < layers.length; i++) {
        final currentLayer = layers[i];
        final layerDir = Directory(p.join('lib', currentLayer));
        if (!layerDir.existsSync()) continue;

        final forbiddenLayers = layers.sublist(0, i);
        if (forbiddenLayers.isEmpty) continue;

        final files = layerDir.listSync(recursive: true).whereType<File>();
        for (final file in files) {
          if (!file.path.endsWith('.dart')) continue;
          final content = file.readAsStringSync();

          for (final forbidden in forbiddenLayers) {
            final pattern = RegExp('import [\'"]package:test_case/$forbidden/');
            expect(
              pattern.hasMatch(content),
              isFalse,
              reason:
                  'Architecture Violation: Layer "$currentLayer" which is lower in the stack must not import from higher layer "$forbidden" in file "${file.path}".',
            );
          }
        }
      }
    });

    test('Prohibit raw print/debugPrint statements (Use logging instead)', () {
      final files = libDir.listSync(recursive: true).whereType<File>();
      final printPattern = RegExp(r'\b(print|debugPrint)\s*\(');

      for (final file in files) {
        if (file.path.endsWith('.dart') &&
            !file.path.contains('logger_utils.dart') &&
            !file.path.contains('logger.dart')) {
          final rawContent = file.readAsStringSync();
          final contentWithoutComments = rawContent
              .replaceAll(RegExp(r'//.*'), '')
              .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');

          expect(
            printPattern.hasMatch(contentWithoutComments),
            isFalse,
            reason:
                'File "${file.path}" uses print/debugPrint instead of the logging package (Section 2.2).',
          );
        }
      }
    });

    test('Service layer and Engine logic are pure and sync (Excluding comments)', () {
      final serviceDir = Directory(p.join('lib', 'services'));
      if (serviceDir.existsSync()) {
        final serviceFiles =
            serviceDir.listSync(recursive: true).whereType<File>();
        for (final file in serviceFiles) {
          if (file.path.endsWith('.dart')) {
            // Strip comments to avoid false positives on words like "async" in documentation
            final rawContent = file.readAsStringSync();
            final contentWithoutComments = rawContent
                .replaceAll(RegExp(r'//.*'), '')
                .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');

            expect(
              contentWithoutComments.contains('Future<'),
              isFalse,
              reason:
                  'Service logic in "${file.path}" must be synchronous (Section 1.3).',
            );
            expect(
              contentWithoutComments.contains('async'),
              isFalse,
              reason:
                  'Service logic in "${file.path}" must be pure and sync (Section 1.3).',
            );
            expect(
              contentWithoutComments.contains('DateTime.now()'),
              isFalse,
              reason:
                  'Service logic in "${file.path}" must not depend on DateTime.now() (Section 1.3).',
            );
            expect(
              contentWithoutComments.contains('Random()'),
              isFalse,
              reason:
                  'Service logic in "${file.path}" must be deterministic; Random() is prohibited (Section 1.3).',
            );
          }
        }
      }
    });

    test('Double comparisons use kDoubleTolerance', () {
      final libDir = Directory('lib');
      final files = libDir.listSync(recursive: true).whereType<File>();
      // Match direct comparisons with 0 or any decimal number.
      // This avoids false positives on integer status codes (like 200) while catching avgLoss == 0.
      final unsafeDoubleComparison = RegExp(
        r'(==|!=)\s*([0-9]+\.[0-9]+|0(\.0+)?)\b',
      );

      for (final file in files) {
        final path = file.path;
        if (path.endsWith('.dart') &&
            !path.contains('engine_config.dart') &&
            !path.contains('constants.dart') &&
            !path.contains('_test.dart')) {
          final content = file.readAsStringSync();
          final contentWithoutComments = content
              .replaceAll(RegExp(r'//.*'), '')
              .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');

          expect(
            unsafeDoubleComparison.hasMatch(contentWithoutComments),
            isFalse,
            reason:
                'File "$path" might be using direct double comparison. Use kDoubleTolerance (Section 3.2).',
          );
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
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Documentation file "$doc" is missing.',
        );
        expect(
          file.readAsStringSync().trim().isNotEmpty,
          isTrue,
          reason: 'Documentation file "$doc" is empty.',
        );
      }

      // Explicitly check for Smoke Test rule (Section 6.2)
      final standards = File('docs/PROJECT_STANDARDS.md').readAsStringSync();
      expect(
        standards.contains('Section 6.2') || standards.contains('Smoke Test'),
        isTrue,
        reason:
            'Section 6.2 (Smoke Test) must be documented in Project Standards.',
      );

      // Check for Silent on Success rule
      expect(
        standards.contains('Silent on Success'),
        isTrue,
        reason:
            '"Silent on Success" rule must be documented in Project Standards (Section 8.1).',
      );

      // Check for Strict Mode (fatal-infos)
      expect(
        standards.contains('--fatal-infos') &&
            standards.contains('--fatal-warnings'),
        isTrue,
        reason:
            'Strict Mode with fatal-infos must be documented (Section 2.2).',
      );

      // Check for Quality Gate: Use `scripts/project_guardian.sh` for local validation or install it as a git hook.
      expect(
        standards.contains('project_guardian.sh') &&
            (standards.contains('Gatekeeper') ||
                standards.contains('Guardian')),
        isTrue,
        reason:
            'project_guardian.sh as a Gatekeeper must be documented (Section 8.1).',
      );

      // Check for Logging Discipline
      expect(
        standards.contains('Logging Discipline') &&
            (standards.contains('NO print()') ||
                standards.contains('NO print()/debugPrint()')),
        isTrue,
        reason: 'Logging Discipline must be documented (Section 2.2).',
      );

      // Check for Native Plugin Fallbacks
      expect(
        standards.contains('Native Plugin Fallbacks') ||
            standards.contains('Native Plugins') ||
            standards.contains('WebView'),
        isTrue,
        reason:
            'Native Plugin Fallbacks for testing must be documented (Section 6.2).',
      );
    });

    test(
      'Meta-Test: Every Standard Section must be verified by a test case in this file',
      () {
        final standardsFile =
            File('docs/PROJECT_STANDARDS.md').readAsStringSync();
        // Current test file content
        final testFile =
            File('test/project_standards_test.dart').readAsStringSync();

        // List of critical keywords that MUST be tested if they exist in standards
        final mandatoryCheckpoints = {
          'Section 1.2': 'layered architecture',
          'Section 2.3': 'snake_case',
          'Section 1.3': 'pure and sync',
          'kDoubleTolerance': 'kDoubleTolerance',
          'Section 2.2': 'print',
          'Section 8.1': 'project_guardian.sh',
          'Section 6.2': 'Smoke Test',
        };

        mandatoryCheckpoints.forEach((section, keyword) {
          if (standardsFile.contains(section)) {
            expect(
              testFile.contains(keyword),
              isTrue,
              reason:
                  'Standard "$section" is documented but lacks a verification test in this file for keyword "$keyword".',
            );
          }
        });
      },
    );
  });
}
