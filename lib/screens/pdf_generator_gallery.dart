// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:scan_plus/configs/configs.dart';
import 'package:scan_plus/screens/photo_viewer.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

/// @no doc
typedef ScannerFilePicker = Future<File?>? Function();

/// @no doc
class PdfGeneratorGallery extends StatefulWidget {
  final ScannerFilePicker filePicker;
  final Map<dynamic, String> labelsConfig;

  const PdfGeneratorGallery(this.filePicker, this.labelsConfig, {super.key});

  @override
  _PdfGeneratorGalleryState createState() => _PdfGeneratorGalleryState();
}

class _PdfGeneratorGalleryState extends State<PdfGeneratorGallery> {
  List<File> files = [];

  addImage() async {
    var file = await widget.filePicker();
    if (file != null) {
      setState(() {
        files.add(file);
      });
    }
  }

  onDone() async {
    final pdf = pw.Document();
    for (var file in files) {
      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(
            pw.MemoryImage(
              file.readAsBytesSync(),
            ),
          ),
        ); // Center
      }));
    }
    Directory tempDir = await getTemporaryDirectory();
    try {
      tempDir.createSync();
      final file =
      File("${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());
      Navigator.of(context).pop(file);
    } catch (e) {
      String message = "Unkown Error";
      if (e is FileSystemException) {
        message = e.osError?.message ?? 'File System Error';
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
    }
  }

  openViewer(File currentItem) {
    int index = files.map((e) => e.path).toList().indexOf(currentItem.path);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PhotoViewer(galleryItems: files, selectedItemIndex: index)));
  }

  _removeFile(index) {
    if (index <= files.length - 1) {
      setState(() {
        files.removeAt(index);
      });
    }
  }

  String get itemsTitle {
    late String finalTitle;
    const String countHolder = "{PAGES_COUNT}";
    var singleTitle = widget.labelsConfig[
    ScannerLabelsConfig.PDF_GALLERY_FILLED_TITLE_SINGLE] ??
        '$countHolder Page';
    var multiTitle = widget.labelsConfig[
    ScannerLabelsConfig.PDF_GALLERY_FILLED_TITLE_MULTIPLE] ??
        '$countHolder Pages';
    finalTitle = multiTitle;
    if (files.length == 1) {
      finalTitle = singleTitle;
    }
    if (!finalTitle.contains(countHolder) && files.length > 1) {
      finalTitle = "${files.length} $finalTitle";
    }
    return finalTitle.replaceAll(countHolder, "${files.length}");
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (files.isNotEmpty) Text(itemsTitle),
          if (files.isEmpty)
            Text(widget.labelsConfig[
            ScannerLabelsConfig.PDF_GALLERY_EMPTY_TITLE] ??
                "PDF Pages")
        ],
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          (files.isEmpty)
              ? Center(
            child: Text(widget.labelsConfig[
            ScannerLabelsConfig.PDF_GALLERY_EMPTY_MESSAGE] ??
                'No scanned files available yet!'),
          )
              : Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height -
                appBar.preferredSize.height,
            child: CustomScrollView(
              primary: false,
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.all(3.0),
                  sliver: SliverGrid.count(
                      childAspectRatio: 10.0 / 9.0,
                      mainAxisSpacing: 1, //horizontal space
                      crossAxisSpacing: 1, //vertical space
                      crossAxisCount: 3, //number of images for a row
                      children: files
                          .map((image) => Hero(
                        tag: image.path,
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () => openViewer(image),
                              child: Image.file(
                                image,
                                height: 150,
                                width: MediaQuery.of(context)
                                    .size
                                    .width /
                                    3,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                                right: 5,
                                top: 5,
                                child: GestureDetector(
                                  onTap: () => _removeFile(files
                                      .map((e) => e.path)
                                      .toList()
                                      .indexOf(image.path)),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1,
                                            color: Colors.grey),
                                        borderRadius:
                                        BorderRadius.circular(
                                            15)),
                                    child: const Icon(Icons.delete,
                                        size: 20,
                                        color: Colors.red),
                                  ),
                                ))
                          ],
                        ),
                      ))
                          .toList()),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10 + MediaQuery.of(context).padding.bottom,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.2),
                    spreadRadius: 1,
                    blurRadius: 10)
              ], borderRadius: BorderRadius.circular(25)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (files.isNotEmpty)
                    Expanded(
                        child: _mainControl(context,
                            color: Colors.blue,
                            icon: Icons.check,
                            title: widget.labelsConfig[ScannerLabelsConfig
                                .PDF_GALLERY_DONE_LABEL] ??
                                "Done",
                            textColor: Colors.white,
                            onTap: onDone,
                            radius: const BorderRadius.only(
                                topLeft: Radius.circular(25),
                                bottomLeft: Radius.circular(25)))),
                  Expanded(
                      child: _mainControl(context,
                          color:
                          files.isEmpty ? Colors.blue : Colors.cyanAccent,
                          icon: Icons.add_a_photo,
                          textColor:
                          files.isEmpty ? Colors.white : Colors.black,
                          title: widget.labelsConfig[ScannerLabelsConfig
                              .PDF_GALLERY_ADD_IMAGE_LABEL] ??
                              "Add Image",
                          onTap: addImage,
                          radius: files.isEmpty
                              ? BorderRadius.circular(25)
                              : const BorderRadius.only(
                              topRight: Radius.circular(25),
                              bottomRight: Radius.circular(25)))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainControl(BuildContext context,
      {required String title,
        required Function onTap,
        required Color color,
        IconData? icon,
        Color textColor = Colors.black,
        required BorderRadius radius}) =>
      GestureDetector(
        onTap: () => onTap(),
        child: Container(
            decoration: BoxDecoration(borderRadius: radius, color: color),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(icon, size: 20, color: textColor),
                  ),
                Text(title, style: TextStyle(color: textColor))
              ],
            )),
      );
}
