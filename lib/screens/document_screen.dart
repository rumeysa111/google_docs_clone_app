import 'dart:async';

import 'package:docs_clone_flutter/colors.dart';
import 'package:docs_clone_flutter/common/widgets/loader.dart';
import 'package:docs_clone_flutter/models/document_model.dart';
import 'package:docs_clone_flutter/models/error_model.dart';
import 'package:docs_clone_flutter/repository/auth_repository.dart';
import 'package:docs_clone_flutter/repository/document_repository.dart';
import 'package:docs_clone_flutter/repository/socket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController _controller =
  TextEditingController(text: "Untitled Document");
  quill.QuillController? quillController = quill.QuillController.basic();
  ErrorModel? errorModel;

  SocketRepository socketRepository = SocketRepository();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();
    socketRepository.changeListener((data) {
      quillController?.compose(
          Delta.fromJson(data['delta']),
          quillController?.selection ??
              const TextSelection.collapsed(offset: 0),
          quill.ChangeSource.remote);
    });

    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'room': widget.id,
        'delta': quillController!.document.toDelta(),
      });
    });
  }
  
  void fetchDocumentData() async {
    errorModel = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);
  if (errorModel == null || errorModel!.error != null) {
    print("Hata: ${errorModel?.error}");
    return;
  }

    if (errorModel!.data != null) {
      _controller.text = (errorModel!.data as DocumentModel).title;
      quillController = quill.QuillController(
        document: errorModel!.data.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
            Delta.fromJson(errorModel!.data.content)),
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {});
    }
    quillController!.document.changes.listen((event) {
      final change = event.change; // Yeni API'de değişiklik verilerini buradan alın.
      final source = event.source; // Değişikliğin kaynağını alın.

      if (source == quill.ChangeSource.local) {
        Map<String, dynamic> map = {
          'delta': change, // Değişiklik verilerini buraya yerleştirin.
          'room': widget.id,
        };
        socketRepository.typing(map);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void updateTitle(WidgetRef ref, String title) {
    ref.read(documentRepositoryProvider).updateTitle(
      token: ref.read(userProvider)!.token,
      id: widget.id,
      title: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (quillController == null) {
      return const Scaffold(
        body: Loader(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0, //appbarın gölgesini kaldırır
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(
                    text: 'http://localhost:3001/#/document/${widget.id}'))
                    .then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Link copied to clipboard')));
                });
              },
              icon: Icon(
                Icons.lock,
                size: 16,
                color: kWhiteColor,
              ),
              label: Text(
                'Share',
                style: TextStyle(color: kWhiteColor),
              ), // Added label parameter
              style: ElevatedButton.styleFrom(
                  backgroundColor: kBlueColor), // Updated style
            ),
          )
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Routemaster.of(context).replace('/');
                  },
                  child:
                  Image.asset('assets/images/docs-logo.png', height: 40)),
              const SizedBox(width: 10),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kBlueColor),
                    ),
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                  onSubmitted: (value) => updateTitle(ref, value),
                ),
              )
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: kGreyColor),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            quill.QuillSimpleToolbar(
              controller: quillController!,
              configurations: const quill.QuillSimpleToolbarConfigurations(),
            ),
            Expanded(
              child: SizedBox(
                width: 750,
                child: Card(
                  color: kWhiteColor,
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: quill.QuillEditor.basic(
                      controller: quillController!,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
