import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AjouterProjetScreen extends StatefulWidget {

   final String? nomInitial;
   final String? descriptionInitial;
   //final int? clientIdInitial;
   final String? clientNameInitial;
   final int? demandeId;

  const AjouterProjetScreen({
    super.key,
    this.nomInitial,
    this.descriptionInitial,
    this.clientNameInitial,
    this.demandeId,
  });

  @override
  State<AjouterProjetScreen> createState() =>
      _AjouterProjetScreenState();
}

class _AjouterProjetScreenState
    extends State<AjouterProjetScreen> {

  final nomController = TextEditingController();
  final clientController = TextEditingController();
  final descriptionController = TextEditingController();

  String priorite = "normale";

  DateTime dateDebut = DateTime.now();

  DateTime dateFin =
      DateTime.now().add(const Duration(days: 30));

  bool loading = false;

/*
    @override
  void initState() {
    super.initState();

    nomController.text = widget.nomInitial ?? '';
    descriptionController.text = widget.descriptionInitial ?? '';
  }
*/
@override
void initState() {
  super.initState();

  nomController.text = widget.nomInitial ?? '';
  descriptionController.text = widget.descriptionInitial ?? '';

  if (widget.clientNameInitial != null) {
    clientController.text = widget.clientNameInitial!;
  }
}

  Future choisirDate(bool debut) async {

    final date = await showDatePicker(

      context: context,

      initialDate: debut ? dateDebut : dateFin,

      firstDate: DateTime(2024),

      lastDate: DateTime(2035),

      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xff9C6CFF),
              onPrimary: Colors.white,
              surface: Color(0xff1C1230),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xff1C1230),
            ),
          ),
          child: child!,
        );
      },

    );

    if (date == null) return;

    setState(() {

      if (debut) {
        dateDebut = date;
      } else {
        dateFin = date;
      }

    });

  }

  Future enregistrer() async {

    if (nomController.text.isEmpty ||
        clientController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff1C1230),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Text(
            "Remplissez tous les champs",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    await ApiService.createProjet({

      "nom": nomController.text,

      "description": descriptionController.text,

      "client": clientController.text,

      // adapte selon ton utilisateur connecté
      "chef_projet_id": 1,

      "date_debut":
          dateDebut.toString().substring(0,10),

      "date_fin":
          dateFin.toString().substring(0,10),

      "priorite": priorite,

    });

    if (widget.demandeId != null) {
  await ApiService.put(
  'demandes-projets/${widget.demandeId}/traiter',
  {},
);
}

    setState(() {
      loading = false;
    });

    Navigator.pop(context,true);

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xff0E0A16),

      // ================= APP BAR =================

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff2A1454),
                Color(0xff5B2EFF),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x555B2EFF),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
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
                      color: Colors.white.withOpacity(.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "Ajouter Projet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ================= BACKGROUND =================

      body: Stack(
        children: [

          Container(
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
          ),

          Positioned(
            top: -140,
            right: -110,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(.35),
                    blurRadius: 160,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // ================= CONTENT =================

          SafeArea(
            child: SingleChildScrollView(

              padding: const EdgeInsets.all(22),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    "Détails du projet",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.55),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ================= CARD =================

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.05),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white.withOpacity(.10),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [

                        _buildField(
                          controller: nomController,
                          hint: "Nom du projet",
                          icon: Icons.folder_special_outlined,
                        ),

                        const SizedBox(height: 18),

    TextField(
      controller: descriptionController,
      maxLines: 5,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Description du projet (optionnel)",
        hintStyle: TextStyle(color: Colors.white.withOpacity(.35)),
        prefixIcon: const Icon(Icons.notes_outlined, color: Color(0xff9C6CFF), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    ),

                        const SizedBox(height: 18),

                        _buildField(
                          controller: clientController,
                          hint: "Client",
                          icon: Icons.badge_outlined,
                        ),

                        const SizedBox(height: 18),

                        _buildDateTile(
                          label: "Date début",
                          value: dateDebut.toString().substring(0, 10),
                          onTap: () => choisirDate(true),
                        ),

                        const SizedBox(height: 14),

                        _buildDateTile(
                          label: "Date fin",
                          value: dateFin.toString().substring(0, 10),
                          onTap: () => choisirDate(false),
                        ),

                        const SizedBox(height: 18),

                        _buildPrioriteDropdown(),

                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ================= SUBMIT BUTTON =================

                  GestureDetector(
                    onTap: loading ? null : enregistrer,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xff5B2EFF),
                            Color(0xff9C6CFF),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurpleAccent.withOpacity(.55),
                            blurRadius: 30,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    "Créer le projet",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                ],

              ),

            ),

          ),

        ],
      ),

    );

  }

  // ================= REUSABLE FIELD =================

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(.10),
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        cursorColor: const Color(0xff9C6CFF),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(.35)),
          prefixIcon: Icon(icon, color: const Color(0xff9C6CFF), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // ================= DATE TILE =================

  Widget _buildDateTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(.10),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xff9C6CFF).withOpacity(.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xff9C6CFF),
                size: 17,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.45),
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(.35),
            ),
          ],
        ),
      ),
    );
  }

  // ================= PRIORITE DROPDOWN =================

  Widget _buildPrioriteDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(.10),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField(

          value: priorite,

          dropdownColor: const Color(0xff1C1230),

          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xff9C6CFF)),

          style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w600),

          decoration: InputDecoration(
            labelText: "Priorité",
            labelStyle: TextStyle(color: Colors.white.withOpacity(.45)),
            prefixIcon: const Icon(Icons.flag_outlined, color: Color(0xff9C6CFF), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),

          items: const [

            DropdownMenuItem(

              value: "basse",

              child: Text("Basse"),

            ),

            DropdownMenuItem(

              value: "normale",

              child: Text("Normale"),

            ),

            DropdownMenuItem(

              value: "haute",

              child: Text("Haute"),

            ),

          ],

          onChanged: (v){

            setState(() {

              priorite = v!;

            });

          },

        ),
      ),
    );
  }

}