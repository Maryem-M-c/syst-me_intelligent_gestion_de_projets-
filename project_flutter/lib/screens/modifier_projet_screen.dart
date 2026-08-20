import 'package:flutter/material.dart';
import '../models/projet.dart';
import '../services/api_service.dart';


class ModifierProjetScreen extends StatefulWidget {

  final Projet projet;

  const ModifierProjetScreen({
    super.key,
    required this.projet,
  });


  @override
  State<ModifierProjetScreen> createState()
      => _ModifierProjetScreenState();

}



class _ModifierProjetScreenState
    extends State<ModifierProjetScreen> {


final nomController = TextEditingController();
final clientController = TextEditingController();


String? statut;
String? priorite;

DateTime? dateDebut;
DateTime? dateFin;


bool loading = false;



@override
void initState(){

super.initState();


nomController.text = widget.projet.nom;
clientController.text = widget.projet.client;


statut = widget.projet.statut;
priorite = widget.projet.priorite;


dateDebut = DateTime.parse(widget.projet.dateDebut);
dateFin = DateTime.parse(widget.projet.dateFin);


}




Future<void> choisirDate(bool debut) async {


DateTime? date = await showDatePicker(

context: context,

initialDate: debut ? dateDebut! : dateFin!,

firstDate: DateTime(2020),

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



if(date != null){

setState(() {

if(debut){

dateDebut=date;

}else{

dateFin=date;

}

});

}

}





Future<void> modifier() async {


setState(() {
loading=true;
});



await ApiService.updateProjet(

widget.projet.id,

{


"nom": nomController.text,


"client": clientController.text,


"date_debut":
"${dateDebut!.year}-${dateDebut!.month.toString().padLeft(2,'0')}-${dateDebut!.day.toString().padLeft(2,'0')}",



"date_fin":
"${dateFin!.year}-${dateFin!.month.toString().padLeft(2,'0')}-${dateFin!.day.toString().padLeft(2,'0')}",



"statut": statut,


"priorite": priorite,


}

);



setState(() {
loading=false;
});


Navigator.pop(context);

}





@override
Widget build(BuildContext context){


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
                  color: Colors.white.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                "Modifier projet",
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
                color: Colors.deepPurpleAccent.withOpacity(.30),
                blurRadius: 160,
                spreadRadius: 30,
              ),
            ],
          ),
        ),
      ),

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
                      hint: "Nom projet",
                      icon: Icons.folder_special_outlined,
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
                      value: dateDebut!.toString().substring(0, 10),
                      icon: Icons.calendar_today_rounded,
                      onTap: () => choisirDate(true),
                    ),

                    const SizedBox(height: 14),

                    _buildDateTile(
                      label: "Date fin",
                      value: dateFin!.toString().substring(0, 10),
                      icon: Icons.calendar_month_rounded,
                      onTap: () => choisirDate(false),
                    ),

                    const SizedBox(height: 18),

                    _buildDropdown(
                      value: statut,
                      label: "Statut",
                      icon: Icons.push_pin_outlined,
                      items: const [
                        DropdownMenuItem(value: "en_attente", child: Text("En attente")),
                        DropdownMenuItem(value: "en_cours", child: Text("En cours")),
                        DropdownMenuItem(value: "termine", child: Text("Terminé")),
                        DropdownMenuItem(value: "en_retard", child: Text("En retard")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          statut = value;
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    _buildDropdown(
                      value: priorite,
                      label: "Priorité",
                      icon: Icons.flag_outlined,
                      items: const [
                        DropdownMenuItem(value: "basse", child: Text("Basse")),
                        DropdownMenuItem(value: "normale", child: Text("Normale")),
                        DropdownMenuItem(value: "haute", child: Text("Haute")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          priorite = value;
                        });
                      },
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================= SAVE BUTTON =================

              GestureDetector(
                onTap: loading ? null : modifier,
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
                                "Enregistrer",
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
  required IconData icon,
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
            child: Icon(
              icon,
              color: const Color(0xff9C6CFF),
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

// ================= DROPDOWN =================

Widget _buildDropdown({
  required String? value,
  required String label,
  required IconData icon,
  required List<DropdownMenuItem<String>> items,
  required void Function(String?) onChanged,
}) {
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
      child: DropdownButtonFormField<String>(

        value: value,

        dropdownColor: const Color(0xff1C1230),

        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xff9C6CFF)),

        style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w600),

        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(.45)),
          prefixIcon: Icon(icon, color: const Color(0xff9C6CFF), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),

        items: items,

        onChanged: onChanged,

      ),
    ),
  );
}

}