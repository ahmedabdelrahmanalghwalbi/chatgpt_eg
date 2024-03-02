import 'package:chat_gpt_eg/constants/constants.dart';
import 'package:chat_gpt_eg/providers/authentication_provider.dart';
import 'package:chat_gpt_eg/providers/chat_provider.dart';
import 'package:chat_gpt_eg/utility/utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../providers/my_theme_provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    Key? key,
    required this.fromScreen,
    this.postData,
  }) : super(key: key);

  final FromScreen fromScreen;
  final dynamic postData;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  late TextEditingController textEditingController;
  SpeechToText speechToText = SpeechToText();
  late FocusNode focusNode;
  String chatGPTModel = 'gpt-3.5-turbo';
  bool showSendButton = false;
  String _lastWords = '';

  @override
  void initState() {
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    initializeSpeechToText();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void initializeSpeechToText() async {
    await speechToText.initialize();
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    context.read<ChatProvider>().setIsListening(listening: true);
    await speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void stopListening() async {
    context.read<ChatProvider>().setIsListening(listening: false);
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    debugPrint('words : $_lastWords');
    if (speechToText.isNotListening) {
      stopListening();

      context.read<ChatProvider>().sendMessage(
            uid: context.read<AuthenticationProvider>().userModel.uid,
            message: _lastWords,
            modelId: chatGPTModel,
            onSuccess: () {
              textEditingController.text = '';
              focusNode.unfocus();
              debugPrint('success');
            },
            onCompleted: () {
              debugPrint('completed');
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<MyThemeProvider>(context).themeType;
    Color color = isDarkTheme ? Colors.white : Colors.black;
    final userModel = context.read<AuthenticationProvider>().userModel;
    return Material(
      color: isDarkTheme ? Constants.chatGPTDarkCardColor : Colors.white70,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                focusNode: focusNode,
                controller: textEditingController,
                style: TextStyle(color: color),
                decoration: InputDecoration.collapsed(
                  hintText: widget.fromScreen == FromScreen.aIChatScreen
                      ? 'How can i help you?'
                      : 'Type something...',
                  hintStyle: TextStyle(color: color),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    widget.fromScreen == FromScreen.aIChatScreen
                        ?
                        // show send button
                        setState(() {
                            showSendButton = true;
                          })
                        : null;
                  } else {
                    widget.fromScreen == FromScreen.aIChatScreen
                        ?
                        // show mic
                        setState(() {
                            showSendButton = false;
                          })
                        : null;
                  }
                },
                onSubmitted: (value) {
                  if (widget.fromScreen == FromScreen.aIChatScreen) {
                    // first lets check if user has entered something
                    if (textEditingController.text.isEmpty) {
                      showSnackBar(
                          context: context, content: 'Please type a message');
                      return;
                    }

                    if (context.read<ChatProvider>().isTyping) {
                      showSnackBar(
                          context: context,
                          content: 'Please wait for a response');
                      return;
                    }

                    context.read<ChatProvider>().sendMessage(
                          uid: context
                              .read<AuthenticationProvider>()
                              .userModel
                              .uid,
                          message: textEditingController.text,
                          modelId: chatGPTModel,
                          onSuccess: () {
                            textEditingController.text = '';
                            focusNode.unfocus();
                            debugPrint('success');
                          },
                          onCompleted: () {
                            debugPrint('completed');
                          },
                        );
                  } else {
                    // send a comment
                    // first lets check if user has entered something
                    if (textEditingController.text.isEmpty) {
                      showSnackBar(
                          context: context, content: 'Please type a message');
                      return;
                    }

                    if (context.read<ChatProvider>().isTyping) {
                      showSnackBar(context: context, content: 'Please wait...');
                      return;
                    }

                    context.read<ChatProvider>().sendComment(
                        userModel: userModel,
                        message: textEditingController.text,
                        postData: widget.postData,
                        onSuccess: () {
                          textEditingController.text = '';
                          focusNode.unfocus();
                        });
                  }
                  textEditingController.clear();
                },
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              if (widget.fromScreen == FromScreen.aIChatScreen) {
                if (showSendButton) {
                  // first lets check if user has entered something
                  if (textEditingController.text.isEmpty) {
                    showSnackBar(
                        context: context, content: 'Please type a message');
                    return;
                  }
                  if (context.read<ChatProvider>().isTyping) {
                    showSnackBar(
                        context: context,
                        content: 'Please wait for a response');
                    return;
                  }
                  context.read<ChatProvider>().sendMessage(
                        uid: context
                            .read<AuthenticationProvider>()
                            .userModel
                            .uid,
                        message: textEditingController.text,
                        modelId: chatGPTModel,
                        onSuccess: () {
                          textEditingController.text = '';
                          focusNode.unfocus();
                          debugPrint('success');
                        },
                        onCompleted: () {
                          debugPrint('completed');
                        },
                      );
                } else {
                  _startListening();
                }
              } else {
                // send a comment
                // first lets check if user has entered something
                if (textEditingController.text.isEmpty) {
                  showSnackBar(
                      context: context, content: 'Please type a message');
                  return;
                }

                if (context.read<ChatProvider>().isTyping) {
                  showSnackBar(context: context, content: 'Please wait...');
                  return;
                }
                context.read<ChatProvider>().sendComment(
                    userModel: userModel,
                    message: textEditingController.text,
                    postData: widget.postData,
                    onSuccess: () {
                      textEditingController.text = '';
                      focusNode.unfocus();
                    });
              }
            },
            icon: Icon(
              showSendButton
                  ? Icons.send
                  : widget.fromScreen == FromScreen.aIChatScreen
                      ? Icons.mic
                      : Icons.send,
              color: color,
            ),
          )
        ],
      ),
    );
  }
}
