import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  PageController _pageController = PageController();
  int _currentPage = 0;
  String? _songInfo;
  String? _songImageUrl;
  late AnimationController _animationController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isRecording = false; // Nuevo estado para saber si está grabando

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation =
        Tween<double>(begin: 1.0, end: 0.7).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos un Stack para superponer el contenido sobre el fondo de degradado
      body: Stack(
        children: [
          // Este container servirá como fondo de degradado para todo el Scaffold
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF000000), Color(0xFF090C1F)], // Colores del degradado
              ),
            ),
          ),
          // Usamos Positioned.fill para asegurar que el contenido cubre todo el espacio excepto el de la bottomNavigationBar
          Positioned.fill(
            bottom: 50, // Aproximadamente el alto de la bottomNavigationBar
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildMainPage(),
                _buildLibraryPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      extendBody: true,  // Esto asegura que el body se extienda detrás de la bottomNavigationBar
    );
  }

  Widget _buildMainPage() {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (!_isRecording) {
            _animationController.forward();
            searchSong();
          }
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.blue[400],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue[300]!.withOpacity(0.6),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.music_note,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

     Widget _buildLibraryPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50), // Espacio en la parte superior
          Text(
            "Biblioteca",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  color: Colors.blue[400]!.withOpacity(0.3),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          if (_songImageUrl != null)
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(_songImageUrl!),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue[400]!.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 20),
          Center(
            child: Text(
              _songInfo ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 4),
                    blurRadius: 4,
                    color: Colors.blue[400]!.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.search, size: 30),
            color: _currentPage == 0 ? Colors.blue[400] : Colors.grey[600],
            onPressed: () {
              _pageController.jumpToPage(0);
            },
          ),
          SizedBox(width: 30),
          IconButton(
            icon: Icon(Icons.library_music, size: 30),
            color: _currentPage == 1 ? Colors.blue[400] : Colors.grey[600],
            onPressed: () {
              _pageController.jumpToPage(1);
            },
          ),
        ],
      ),
    );
  }

  Future<bool> requestMicrophonePermission() async {
    PermissionStatus permission = await Permission.microphone.request();
    return permission.isGranted;
  }

  Future<void> searchSong() async {
    bool hasPermission = await requestMicrophonePermission();
    if (!hasPermission) {
      print('Permiso del micrófono no otorgado');
      return;
    }

    FlutterSoundRecorder _recorder = FlutterSoundRecorder();
    String? path;

    try {
      // 1. Grabar audio
      _recorder = FlutterSoundRecorder();
      await _recorder.openRecorder();
      final tempDir = await getTemporaryDirectory();
      path = '${tempDir.path}/temp.pcm';
      var codec = Codec.pcm16;
      // Verificar y crear el archivo si no existe
      final File audioFile = File(path);
      if (!audioFile.existsSync()) {
        await audioFile.create();
      }

      await _recorder.startRecorder(
        toFile: path,
        codec: codec,
        sampleRate: 44100,
        numChannels: 1,
      );
      await Future.delayed(Duration(seconds: 8)); // graba por 8 segundos
      await _recorder.stopRecorder();
      await _recorder.closeRecorder();
    } catch (e) {
      print("Error durante la grabación: $e");
      return;
    }

    if (path == null) {
      print("Error: Path de grabación es null");
      return;
    }

    try {
      // 2. Convertir el audio grabado a base64
      File audioFile = File(path);
      List<int> audioBytes = audioFile.readAsBytesSync();
      String base64Audio = base64Encode(audioBytes);

      // 3. Enviar a Shazam
      var url = Uri.parse('https://shazam.p.rapidapi.com/songs/detect');
      var response = await http.post(
        url,
        headers: {
          'content-type': 'text/plain',
          'X-RapidAPI-Key':
              '25d385af53mshf10a8ccb2262289p159852jsn614ebb5db896', // Asegúrate de usar tu propia clave API
          'X-RapidAPI-Host': 'shazam.p.rapidapi.com',
        },
        body: base64Audio,
      );

      // 4. Procesar la respuesta
      if (response.statusCode == 200) {
        // Decodificando la respuesta JSON
        var responseData = jsonDecode(response.body);

        // Verificamos si "matches" es una lista y no está vacía
        if (responseData['matches'] is List &&
            responseData['matches'].isNotEmpty) {
          String songId = responseData['matches'][0]['id'].toString();

          // Ahora hacemos la solicitud GET con el songId
          final url = Uri.parse(
              'https://shazam.p.rapidapi.com/songs/get-details?key=$songId&locale=en-US');
          //https://shazam.p.rapidapi.com/songs/get-details?key=40333609&locale=en-US
          final songDetailsResponse = await http.get(
            url,
            headers: {
              'X-RapidAPI-Key':
                  '25d385af53mshf10a8ccb2262289p159852jsn614ebb5db896',
              'X-RapidAPI-Host': 'shazam.p.rapidapi.com',
            },
          );
            if (songDetailsResponse.statusCode == 200) {
            final songDetailsData = jsonDecode(songDetailsResponse.body);
            final songTitle =
                songDetailsData['title']; // El título de la canción
            final artistName =
                songDetailsData['subtitle']; // El nombre del artista
            final songImage = songDetailsData['images']
                ['coverart']; // La imagen de la canción

            // Actualizando la UI
            setState(() {
              _songInfo = '$songTitle by $artistName';
              _songImageUrl = songImage;
            });

            // Guardando la información en Firebase
            saveSong(songTitle, artistName, songImage);
            
          } else {
            print(
                'Failed to load song details. Status code: ${songDetailsResponse.statusCode}');
          }
        } else {
          print('No matches found');
        }
      } else {
        print('Failed to load song info. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error al procesar o enviar la solicitud: $e");
    }
    if ((await Vibration.hasVibrator()) ?? false) {
      Vibration.vibrate();
    }
    _animationController.reverse();
  }

  Future<void> saveSong(String title, String artist, String imageURL) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('songs')
            .add({
          'title': title,
          'artist': artist,
          'imageURL': imageURL, // Agrega esto
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error al guardar la canción en Firebase: $e");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class Song {
  final String title;
  final String artist;
  final String imageURL;

  Song({
    required this.title,
    required this.artist,
    required this.imageURL,
  });
}
