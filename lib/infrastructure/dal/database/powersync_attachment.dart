import 'dart:async';
import 'package:powersync_attachments_helper/powersync_attachments_helper.dart';
import 'package:powersync_core/powersync_core.dart';

import 'remote_storage_adaptor.dart';

// Set up schema with an id field that can be used in watchIds().
// In this case it is photo_id
// const schema = Schema([
//   Table('users', [Column.text('name'), Column.text('photo_id')])
// ]);

// Assume PowerSync database is initialized elsewhere
// late PowerSyncDatabase db;
// Assume remote storage is implemented elsewhere
late final PhotoAttachmentQueue attachmentQueue;
final remoteStorage = SupabaseStorageAdapter();
// final db = SupabaseStorageAdapter();

class PhotoAttachmentQueue extends AbstractAttachmentQueue {
  PhotoAttachmentQueue(db, remoteStorage)
      : super(db: db, remoteStorage: remoteStorage);

  // This will create an item on the attachment queue to UPLOAD an image
  // to remote storage
  @override
  Future<Attachment> saveFile(String fileId, int size,
      {mediaType = 'image/jpeg'}) async {
    String filename = '$fileId.jpg';
    Attachment photoAttachment = Attachment(
      id: fileId,
      filename: filename,
      state: AttachmentState.queuedUpload.index,
      mediaType: mediaType,
      localUri: getLocalFilePathSuffix(filename),
      size: size,
    );

    return attachmentsService.saveAttachment(photoAttachment);
  }

  // This will create an item on the attachment queue to DELETE a file
  // in local and remote storage
  @override
  Future<Attachment> deleteFile(String fileId) async {
    String filename = '$fileId.jpg';
    Attachment photoAttachment = Attachment(
        id: fileId,
        filename: filename,
        state: AttachmentState.queuedDelete.index);

    return attachmentsService.saveAttachment(photoAttachment);
  }

  // This watcher will handle adding items to the queue based on
  // a users table element receiving a photoId
  @override
  StreamSubscription<void> watchIds({String fileExtension = 'jpg'}) {
    return db.watch('''
      SELECT image_url FROM products WHERE image_url IS NOT NULL UNION SELECT logo_url FROM stores WHERE logo_url IS NOT NULL
    ''').map((results) {
      return results.map((row) => row['image_url'] as String).toList();
    }).listen((ids) async {
      print('listen url');
      List<String> idsInQueue = await attachmentsService.getAttachmentIds();
      List<String> relevantIds =
          ids.where((element) => !idsInQueue.contains(element)).toList();
      syncingService.processIds(relevantIds, fileExtension);
    });
  }
}

// Use this in your main.dart to setup and start the queue
initializeAttachmentQueue(PowerSyncDatabase db) async {
  attachmentQueue = PhotoAttachmentQueue(db, remoteStorage);
  await attachmentQueue.init();
}
