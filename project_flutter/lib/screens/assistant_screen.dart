import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  final List<String> _suggestions = const [
    "Quelles tâches sont en retard ?",
    "Qui est le plus chargé ?",
    "Combien de projets au total ?",
    "Mes tâches",
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'bot',
      'text': "Bonjour ! Je suis votre assistant IA. Posez-moi une question sur les projets, "
          "les tâches ou la charge de travail des employés.",
    });
  }

  Future<void> _envoyer([String? texte]) async {
    final question = (texte ?? _controller.text).trim();
    if (question.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': question});
      _loading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final result = await ApiService.post('assistant', {'question': question});
      setState(() {
        _messages.add({'role': 'bot', 'text': result['reponse'] ?? "Je n'ai pas pu traiter votre demande."});
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'text': "Erreur de connexion à l'assistant."});
        _loading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0E0A16),

    
      // ================= BODY =================
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff130C22),
              Color(0xff0E0A16),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final msg = _messages[i];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? const LinearGradient(colors: [Color(0xff5B2EFF), Color(0xff9C6CFF)])
                            : null,
                        color: isUser ? null : Colors.white.withOpacity(.06),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isUser ? 18 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 18),
                        ),
                        border: isUser
                            ? null
                            : Border.all(color: Colors.white.withOpacity(.10), width: 1.1),
                      ),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.white.withOpacity(.85),
                          fontSize: 13.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_loading)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(.10)),
                      ),
                      child: const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff9C6CFF)),
                      ),
                    ),
                  ],
                ),
              ),

            // --------- Suggestions rapides ---------
            if (_messages.length <= 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestions.map((s) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _envoyer(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: const Color(0xff9C6CFF).withOpacity(.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xff9C6CFF).withOpacity(.35)),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(color: Color(0xff9C6CFF), fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // --------- Barre de saisie ---------
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.06),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(.10), width: 1.2),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5),
                        decoration: InputDecoration(
                          hintText: 'Posez votre question...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(.35), fontSize: 13.5),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        onSubmitted: (_) => _envoyer(),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xff5B2EFF), Color(0xff9C6CFF)]),
                      ),
                      child: IconButton(
                        onPressed: _loading ? null : () => _envoyer(),
                        icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}