import 'package:flutter/material.dart';
import '../models/employe.dart';
import '../services/api_service.dart';

class ModifierEmployeScreen extends StatefulWidget {
  final Employe employe;
  const ModifierEmployeScreen({super.key, required this.employe});

  @override
  State<ModifierEmployeScreen> createState() => _ModifierEmployeScreenState();
}

class _ModifierEmployeScreenState extends State<ModifierEmployeScreen> {
  late TextEditingController _competencesController;
  late int _niveau;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _competencesController = TextEditingController(text: widget.employe.competences);
    _niveau = widget.employe.niveau;
  }

  Future<void> _modifier() async {
    setState(() => _loading = true);

    await ApiService.put('employes/${widget.employe.id}', {
      'competences': _competencesController.text,
      'niveau': _niveau,
    });

    setState(() => _loading = false);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final initiale = widget.employe.nom.trim().isNotEmpty
        ? widget.employe.nom.trim()[0].toUpperCase()
        : "?";

    return Scaffold(

      backgroundColor: const Color(0xff071411),

      // ================= APP BAR =================

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: Container(
          color: const Color(0xff071411),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 102, 73, 111).withOpacity(.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color.fromARGB(255, 134, 88, 126).withOpacity(.3)),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: Color.fromARGB(255, 177, 152, 216),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "Modifier — ${widget.employe.nom}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: .2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ================= BODY =================

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 0, 0, 0),
              Color.fromARGB(255, 170, 147, 174),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            children: [

              // ================= EMPLOYEE HEADER =================

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color.fromARGB(255, 142, 121, 165), Color.fromARGB(255, 147, 237, 201)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff34D399).withOpacity(.35),
                            blurRadius: 24,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initiale,
                          style: const TextStyle(
                            color: Color(0xff071411),
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.employe.nom,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "COMPÉTENCES",
                style: TextStyle(
                  color: Colors.white.withOpacity(.35),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 14),

              // ================= CARD =================

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xff0F2A23),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color.fromARGB(255, 134, 92, 171), width: 1),
                ),
                child: TextField(
                  controller: _competencesController,
                  maxLines: null,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  cursorColor: const Color(0xff34D399),
                  decoration: InputDecoration(
                    labelText: 'Compétences',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(.4), fontSize: 13),
                    prefixIcon: const Icon(Icons.psychology_outlined, color: Color.fromARGB(255, 233, 237, 236), size: 19),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Text(
                "NIVEAU D'EXPERTISE",
                style: TextStyle(
                  color: Colors.white.withOpacity(.35),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 14),

              // ================= NIVEAU CARD =================

              Container(
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xff0F2A23),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xff1B4438), width: 1),
                ),
                child: Column(
                  children: [

                    Text(
                      "$_niveau / 5",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 226, 223, 231),
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Niveau d'expertise",
                      style: TextStyle(color: Colors.white.withOpacity(.4), fontSize: 12.5),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 34,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: index < _niveau
                                ? const Color.fromARGB(255, 237, 236, 241)
                                : Colors.white.withOpacity(.08),
                          ),
                        );
                      }),
                    ),

                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color.fromARGB(255, 220, 228, 225),
                        inactiveTrackColor: Colors.white.withOpacity(.08),
                        thumbColor: const Color.fromARGB(255, 233, 237, 235),
                        overlayColor: const Color(0xff34D399).withOpacity(.15),
                        valueIndicatorColor: const Color(0xff34D399),
                        valueIndicatorTextStyle: const TextStyle(color: Color(0xff071411), fontWeight: FontWeight.bold),
                      ),
                      child: Slider(
                        value: _niveau.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: '$_niveau',
                        onChanged: (val) => setState(() => _niveau = val.round()),
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: _loading ? null : _modifier,
                child: Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color.fromARGB(255, 238, 242, 241),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff34D399).withOpacity(.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xff071411),
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded, color: Color(0xff071411), size: 20),
                              SizedBox(width: 10),
                              Text(
                                "Enregistrer",
                                style: TextStyle(
                                  color: Color(0xff071411),
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}