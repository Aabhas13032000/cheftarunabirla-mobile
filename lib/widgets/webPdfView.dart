import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

class WebPdfViewPage extends StatefulWidget {
  final String path;
  const WebPdfViewPage({Key? key, required this.path}) : super(key: key);

  @override
  _WebPdfViewPageState createState() => _WebPdfViewPageState();
}

class _WebPdfViewPageState extends State<WebPdfViewPage> {
  @override
  Widget build(BuildContext context) {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("Hello World"),
          );
        }));
    final bytes = pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text("Open"),
              onPressed: () {
                final url = html.Url.createObjectUrlFromBlob(blob);
                html.window.open(widget.path, "_blank");
                html.Url.revokeObjectUrl(widget.path);
              },
            ),
            RaisedButton(
              child: Text("Download"),
              onPressed: () {
                final url = html.Url.createObjectUrlFromBlob(blob);
                final anchor =
                    html.document.createElement('a') as html.AnchorElement
                      ..href = url
                      ..style.display = 'none'
                      ..download = 'some_name.pdf';
                html.document.body?.children.add(anchor);
                anchor.click();
                html.document.body?.children.remove(anchor);
                html.Url.revokeObjectUrl(url);
              },
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
