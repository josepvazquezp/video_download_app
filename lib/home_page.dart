import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_downlad/providers/my_download_provider.dart';
import 'package:video_downlad/providers/my_video_provider.dart';
import 'package:video_downlad/video_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select an option'),
      ),
      body: Consumer<MyDownloadProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Expanded(child: Center(child: _showLoading(provider))),
              MaterialButton(
                child: Text("Descargar"),
                onPressed: () {
                  // 8: descargar video
                  provider.descargarVideo();
                },
              ),
              MaterialButton(
                child: Text("Ver video"),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (context) => MyVideoProvider()
                          ..initializeVideoPlayer(provider.videoPath!),
                        child: VideoPage(),
                      ),
                    ),
                  );
                },
              ),
              MaterialButton(
                  child: Text("Borrar video"),
                  onPressed: () {
                    // TODO: removeer video de almacenamiento y BD
                  }),
              _showText(provider),
            ],
          );
        },
      ),
    );
  }

  // estados del widget descargando...
  Widget _showLoading(MyDownloadProvider provider) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    } else {
      return Container();
    }
  }

  // estados del texto que muestra el path
  Widget _showText(MyDownloadProvider provider) {
    if (provider.videoPath != null) {
      return Text("Archivo guardado en: ${provider.videoPath!}");
    } else {
      if (!provider.isPermissionGranted) {
        return Text("Se requieren permisos de almacenamiento.");
      } else if (provider.isSavedSuccess != null &&
          provider.isSavedSuccess == false) {
        return Text("Error al descargar el archivo");
      } else {
        return Text("Haga clic en descargar");
      }
    }
  }
}
