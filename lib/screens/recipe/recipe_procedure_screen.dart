import 'package:flutter/material.dart';

class RecipeProcedureScreen extends StatefulWidget {
  final dynamic recipe;

  const RecipeProcedureScreen({super.key, required this.recipe});

  @override
  State<RecipeProcedureScreen> createState() => _RecipeProcedureScreenState();
}

class _RecipeProcedureScreenState extends State<RecipeProcedureScreen> {
  static const _green = Color(0xFF1EB980);
  static const _greenLight = Color(0xFFE8F8F2);

  late List<bool> completedSteps;
  late List steps;

  @override
  void initState() {
    super.initState();
    steps = widget.recipe.instructions ?? [];
    completedSteps = List.generate(steps.length, (_) => false);
  }

  int get completedCount => completedSteps.where((s) => s).length;

  @override
  Widget build(BuildContext context) {
    final progress =
        steps.isEmpty ? 0.0 : completedCount / steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Procedure",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade100),
        ),
      ),
      body: steps.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: _greenLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.menu_book_rounded,
                        size: 48, color: _green),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No steps found",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Progress bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Row(
                    children: [
                      Text(
                        "$completedCount of ${steps.length} steps done",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: const TextStyle(
                          fontSize: 13,
                          color: _green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      color: _green,
                      minHeight: 6,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      final isDone = completedSteps[index];
                      return _stepCard(index, steps[index], isDone);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _stepCard(int index, String step, bool isDone) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDone ? _greenLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? _green : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDone ? 0.02 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step number badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDone ? _green : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white)
                    : Text(
                        "${index + 1}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Step ${index + 1}",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDone
                          ? const Color(0xFF0F7A52)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: isDone
                          ? const Color(0xFF0F7A52).withOpacity(0.8)
                          : Colors.black87,
                      decoration:
                          isDone ? TextDecoration.lineThrough : null,
                      decorationColor:
                          const Color(0xFF0F7A52).withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: isDone
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 16,
                                  color: _green.withOpacity(0.8)),
                              const SizedBox(width: 4),
                              Text(
                                "Completed",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _green.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () {
                              setState(() => completedSteps[index] = true);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: _green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "Mark Done",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}