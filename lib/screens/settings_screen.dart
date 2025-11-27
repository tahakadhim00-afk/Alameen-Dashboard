import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../database_helper.dart';
import '../main.dart';
import '../models/subscriber.dart';
import '../utils/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.backupRestore,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            ListTile(
              leading: const Icon(Icons.backup),
              title: Text(AppStrings.backupData),
              onTap: () => _backupData(context),
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: Text(AppStrings.restoreData),
              onTap: () => _restoreData(context),
            ),
            const SizedBox(height: 24.0),
            Text(
              AppStrings.language,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              onTap: () {
                Provider.of<LocaleProvider>(context, listen: false)
                    .setLocale(const Locale('en'));
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('العربية'),
              onTap: () {
                Provider.of<LocaleProvider>(context, listen: false)
                    .setLocale(const Locale('ar'));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _backupData(BuildContext context) async {
    try {
      final subscribers = await DatabaseHelper().getAllSubscribers();
      if (subscribers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.noDataToBackup)),
        );
        return;
      }

      final jsonString = jsonEncode(subscribers.map((e) => e.toMap()).toList());
      final result = await FilePicker.platform.saveFile(
        dialogTitle: AppStrings.saveBackupFile,
        fileName: 'al_ameen_backup_${DateTime.now().toIso8601String()}.json',
        bytes: utf8.encode(jsonString),
      );

      if (result != null) {
        // The file is already saved by file_picker when bytes are provided.
        // No need to write to file again.
        // final file = File(result);
        // await file.writeAsString(jsonString);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.backupSuccessful} $result')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.backupFailed} $e')),
      );
    }
  }

  Future<void> _restoreData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        if (!filePath.toLowerCase().endsWith('.json')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.pleaseSelectAValidJsonFile)),
          );
          return;
        }

        final file = File(filePath);
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString) as List;
        final subscribers = data.map((e) => Subscriber.fromMap(e)).toList();

        await DatabaseHelper().deleteAllSubscribers();
        for (final subscriber in subscribers) {
          await DatabaseHelper().insertSubscriber(subscriber);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.restoredSuccessfully} ${subscribers.length} ${AppStrings.records}',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.restoreCanceled)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.restoreFailed} $e')),
      );
    }
  }
}
