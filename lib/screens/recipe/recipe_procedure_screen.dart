import 'package:flutter/material.dart';

class RecipeProcedureScreen extends StatefulWidget {
final dynamic recipe;

const RecipeProcedureScreen({super.key, required this.recipe});

@override
State<RecipeProcedureScreen> createState() => _RecipeProcedureScreenState();
}

class _RecipeProcedureScreenState extends State<RecipeProcedureScreen> {

late List<bool> completedSteps;

@override
void initState() {
super.initState();


final steps = widget.recipe.instructions ?? [];

completedSteps = List.generate(steps.length, (index) => false);


}

@override
Widget build(BuildContext context) {

final steps = widget.recipe.instructions ?? [];

return Scaffold(
  appBar: AppBar(
    title: const Text("Procedure"),
  ),

  body: ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: steps.length,
    itemBuilder: (context, index) {

      final isDone = completedSteps[index];

      return Container(
        margin: const EdgeInsets.only(bottom: 14),

        decoration: BoxDecoration(
          color: isDone ? Colors.green.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// STEP TITLE
              Text(
                "Step ${index + 1}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 6),

              /// STEP TEXT
              Text(
                steps[index],
                style: const TextStyle(height: 1.5),
              ),

              const SizedBox(height: 12),

              /// BUTTON
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDone ? Colors.green : const Color(0xFF1EB980),
                  ),

                  onPressed: () {
                    setState(() {
                      completedSteps[index] = true;
                    });
                  },

                  child: Text(
                    isDone ? "Completed ✓" : "Mark Complete",
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
);

}
}
