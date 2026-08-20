import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreerProjetClientScreen extends StatefulWidget {
      final String? nomInitial;
      final String? descriptionInitial;
      final int? clientIdInitial;
      final int? demandeId;

  const CreerProjetClientScreen({
    super.key,
    this.nomInitial,
    this.descriptionInitial,
    this.clientIdInitial,
    this.demandeId,
  });

  @override
  State<CreerProjetClientScreen> createState() =>
      _CreerProjetClientScreenState();
}

class _CreerProjetClientScreenState
    extends State<CreerProjetClientScreen> {
      
  final TextEditingController nomController = TextEditingController();

  String priorite = "normale";

  DateTime dateDebut = DateTime.now();
  DateTime dateFin = DateTime.now().add(const Duration(days: 30));

  bool loading = false;

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
              primary: Color(0xffEC4899),
              onPrimary: Colors.white,
              surface: Color(0xff17091C),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xff17091C),
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
    if (nomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff17091C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Text(
            "Veuillez saisir le nom du projet",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

  final response = await ApiService.createProjet({
  "nom": nomController.text,
  "date_debut": dateDebut.toString().substring(0, 10),
  "date_fin": dateFin.toString().substring(0, 10),
  "priorite": priorite,
});

print(response);
    setState(() {
      loading = false;
    });

    if (response["message"] != null &&
        response["message"].toString().contains("introuvable")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff17091C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(response["message"], style: const TextStyle(color: Colors.white)),
        ),
      );
      return;
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    nomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xff0D0710),

      // ================= APP BAR =================

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff2A0E2E),
                Color(0xffEC4899),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x55EC4899),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
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
                      color: Colors.white.withOpacity(.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "Créer un projet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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

      // ================= BODY =================

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff17091C),
              Color(0xff0D0710),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [

              Text(
                "Détails du projet",
                style: TextStyle(
                  color: Colors.white.withOpacity(.5),
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
                  color: const Color(0xff1B0F22),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withOpacity(.07),
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
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xffEC4899),
                        Color(0xffF43F5E),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xffEC4899).withOpacity(.5),
                        blurRadius: 26,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
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
                                  fontSize: 16.5,
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
        color: const Color(0xff0D0710),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        cursorColor: const Color(0xffEC4899),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(.30)),
          prefixIcon: Icon(icon, color: const Color(0xffEC4899), size: 20),
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
          color: const Color(0xff0D0710),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xffEC4899).withOpacity(.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xffEC4899),
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
                      color: Colors.white.withOpacity(.4),
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
              color: Colors.white.withOpacity(.3),
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
        color: const Color(0xff0D0710),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(

          value: priorite,

          dropdownColor: const Color(0xff1B0F22),

          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xffEC4899)),

          style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w600),

          decoration: InputDecoration(
            labelText: "Priorité",
            labelStyle: TextStyle(color: Colors.white.withOpacity(.4)),
            prefixIcon: const Icon(Icons.flag_outlined, color: Color(0xffEC4899), size: 20),
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

          onChanged: (value) {
            setState(() {
              priorite = value!;
            });
          },

        ),
      ),
    );
  }
}