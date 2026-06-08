import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProductImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    final extension = file.extension ?? 'jpg';
    final fileName = 'product_images/${DateTime.now().millisecondsSinceEpoch}_image.$extension';
    final ref = _storage.ref().child(fileName);

    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final uploadTask = ref.putData(bytes, metadata);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }
}
