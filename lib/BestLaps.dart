import 'package:flutter/material.dart';

class Bestlaps extends StatelessWidget {
  const Bestlaps({super.key});

  @override
  Widget build(BuildContext context) {
    String prev = '01:25:789';
    String first = '01:23:456';
    int lap = 3;

    const Color selectColor = Color.fromARGB(255, 255, 0, 0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          ' $lap. \n ${lap-1}. \n ${lap-2}. ',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            shadows: [
          // Η σκιά δημιουργεί το περίγραμμα
          Shadow(
            // Χρώμα περιγράμματος
            color: selectColor, 
            
            // Offset: Δημιουργεί την αίσθηση του περιγράμματος
            // (1.0, 1.0) Δημιουργεί σκιά κάτω δεξιά
            offset: Offset(1.0, 1.0), 
            
            // Blur: Μηδενικό για αιχμηρό περίγραμμα
            blurRadius: 0.0, 
          ),
          // Προσθέτουμε κι άλλες σκιές για να καλύψουμε όλες τις πλευρές:
          Shadow(
            color: selectColor, 
            offset: Offset(-1.0, 1.0), // Κάτω αριστερά
            blurRadius: 0.0,
          ),
          Shadow(
            color: selectColor, 
            offset: Offset(1.0, -1.0), // Πάνω δεξιά
            blurRadius: 0.0,
          ),
          Shadow(
            color: selectColor, 
            offset: Offset(-1.0, -1.0), // Πάνω αριστερά
            blurRadius: 0.0,
          ),
          // Μπορείτε να προσθέσετε και κεντρικές σκιές (π.χ., Offset(0, 1.5)) για να γίνει πιο παχύ το περίγραμμα.
        ],
          ),
        ),
        Text(
          '--:--:--- \n $prev \n $first',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}