import 'package:file_picker/file_picker.dart';

Future<PlatformFile?> pickAgreementFile() async {

  try {

    final result =
        await FilePicker.platform
            .pickFiles(

      type: FileType.custom,

      allowedExtensions: [
        'pdf',
        'jpg',
        'jpeg',
        'png',
      ],
    );

    if (result == null ||
        result.files.isEmpty) {

      return null;
    }

    return result.files.first;

  } catch (e) {

    

    return null;
  }
}