import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:voice_assistant/cases.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'openai.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  final OpenAIService openAIService = OpenAIService();
  String lastWords = '';
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 300;
  bool isRecording = false;
  double volume = 1.0;
  String language = 'en_US, uk_UA';

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    bool initialized = await speechToText.initialize();
    print('speech recog init: $initialized');
    setState(() {});
  }

  Future<void> startListening() async {
    isRecording = true;

    await speechToText.listen(onResult: onSpeechResult);

    setState(() {});
  }

  Future<void> stopListening() async {
    isRecording = false;
    await speechToText.stop();
    final response = await openAIService.isArtPromptAPI(lastWords);

    setState(() {
      if (response.startsWith('https')) {
        generatedImageUrl = response;
        generatedContent = null;
      } else {
        generatedContent = response;
        generatedImageUrl = null;
        systemSpeak(response);
      }
    });
  }

  void onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      if (isRecording) {
        lastWords = result.recognizedWords;
        print('last words updated: $lastWords');
      }
    });

    // Only send the last recognized speech result if it's not empty
    if (lastWords.isNotEmpty) {
      // Filter non-English words from recognized speech
      final englishWords = filterEnglishWords(lastWords);

      // Send the filtered English speech result to the API
      final response = await openAIService.isArtPromptAPI(englishWords);
      setState(() {
        if (response.startsWith('https')) {
          generatedImageUrl = response;
          generatedContent = null;
        } else {
          generatedContent = response;
          generatedImageUrl = null;
          systemSpeak(response);
        }
      });
    }
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
    flutterTts.setVolume(0.5);
    flutterTts.setLanguage("en_US");
  }

  String filterEnglishWords(String speech) {
    final englishDictionary = <String>{
      'hello',
      'greeting',
      'good',
      'welcome',
      'judge',
      'sir',
      'what',
      'is',
      'war',
      'draw',
      'cat',
      'tiger',
      'programming',
      'university',
      'time',
      'picture',
      'of',
      'mice'
    };

    final words = speech.toLowerCase().split(' ');
    final englishWords =
        words.where((word) => englishDictionary.contains(word));
    return englishWords.join(' ');
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          child: const Text(
            "SOVA",
            style: TextStyle(
              fontFamily: 'Chinzel',
              fontWeight: FontWeight.w900,
              fontSize: 35,
            ),
          ),
        ),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Sova avatar
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(156, 225, 255, 255),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage(
                          'assets/images/sova.png',
                        ))),
                  )
                ],
              ),
            ),

            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      generatedContent == null
                          ? 'Greetings ! What can i do for you ?'
                          : generatedContent!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: generatedContent == null ? 20 : 20,
                        fontFamily: 'Chinzel',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(generatedImageUrl!)),
              ),
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: FadeInLeft(
                  child: const Text(
                    'What i can ?.',
                    style: TextStyle(
                      fontFamily: 'Chinzel',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //cases
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInUp(
                    delay: Duration(milliseconds: start),
                    child: const CasesBox(
                      color: Color.fromARGB(255, 50, 152, 186),
                      headerText: 'Generate images',
                      descriptionText:
                          'With help of a DALL-E your request will be transformed into image or art. Whatever you prefer.',
                    ),
                  ),
                  SlideInUp(
                    delay: Duration(milliseconds: start + delay),
                    child: const CasesBox(
                      color: Color.fromARGB(255, 50, 186, 177),
                      headerText: 'Answer your questions',
                      descriptionText:
                          'Get answer for any question that bothers your mind.',
                    ),
                  ),
                  SlideInUp(
                    delay: const Duration(milliseconds: 500),
                    child: const CasesBox(
                      color: Color.fromARGB(255, 72, 132, 223),
                      headerText: 'Personal assistant',
                      descriptionText:
                          'I will gladly acompany you and help with knowledge that i have.',
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Container(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 620, left: 30),
          child: ZoomIn(
            delay: Duration(microseconds: start + 3 * delay),
            child: AvatarGlow(
              endRadius: 45,
              animate: speechToText.isListening,
              glowColor: Theme.of(context).primaryColor,
              duration: const Duration(milliseconds: 2000),
              repeatPauseDuration: const Duration(milliseconds: 100),
              repeat: true,
              child: FloatingActionButton(
                  backgroundColor: const Color.fromARGB(255, 50, 152, 186),
                  onPressed: () async {
                    print('FloatingActionButton pressed');
                    if (await speechToText.hasPermission &&
                        speechToText.isNotListening) {
                      await startListening();
                    } else if (speechToText.isListening) {
                      final speech =
                          await openAIService.isArtPromptAPI(lastWords);
                      print(speech);
                      if (speech.contains('https')) {
                        generatedImageUrl = speech;
                        generatedContent = null;
                        setState(() {});
                      } else {
                        generatedImageUrl = null;
                        generatedContent = speech;
                        setState(() {});
                        await systemSpeak(speech);
                      }
                      await stopListening();
                    } else {
                      initSpeechToText();
                    }
                  },
                  child:
                      Icon(speechToText.isListening ? Icons.stop : Icons.mic)),
            ),
          ),
        ),
      ),
    );
  }
}
