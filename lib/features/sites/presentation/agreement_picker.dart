import 'package:file_picker/file_picker.dart';

Future<PlatformFile?> pickAgreementFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  );
  return result?.files.first;
}