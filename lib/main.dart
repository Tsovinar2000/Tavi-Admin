import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // инициализация Firebase
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firestore Admin Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true, // Активация Material 3
      ),
      home: const AdminHomeScreen(), 
    );
  }
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Градиент в AppBar
      appBar: AppBar(
        title: const Text('Админ: Список уроков'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      // Градиент фона
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0F7FA)], 
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('lessons').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Нет уроков'));
            }

            final docs = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final lessonDoc = docs[index];
                final lessonData = lessonDoc.data() as Map<String, dynamic>;
                final title = lessonData['title'] ?? 'Без названия';
                final part = lessonData['part'] ?? 0;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      '$title (Часть $part)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonEditorScreen(lessonId: lessonDoc.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Создание нового урока
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LessonEditorScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class LessonEditorScreen extends StatefulWidget {
  final String? lessonId;

  const LessonEditorScreen({Key? key, this.lessonId}) : super(key: key);

  @override
  State<LessonEditorScreen> createState() => _LessonEditorScreenState();
}

class _LessonEditorScreenState extends State<LessonEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Поля для заполнения
  final _titleController = TextEditingController();
  final _partController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _taskDescriptionController = TextEditingController();
  final _candiesImageUrlController = TextEditingController();
  final _bgImageUrlController = TextEditingController(); // Новый контроллер для фонового изображения
  final _numbersController = TextEditingController(); // "2,7,10,5" и т.д.
  final _rightAnswerController = TextEditingController(); // Контроллер для правильного ответа

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.lessonId != null) {
      _loadLessonData(widget.lessonId!);
    }
  }

  Future<void> _loadLessonData(String lessonId) async {
    setState(() {
      _isLoading = true;
    });
    final doc = await FirebaseFirestore.instance
        .collection('lessons')
        .doc(lessonId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _titleController.text = data['title'] ?? '';
      _partController.text = '${data['part'] ?? ''}';
      _videoUrlController.text = data['videoUrl'] ?? '';
      _taskDescriptionController.text = data['taskDescription'] ?? '';
      _candiesImageUrlController.text = data['candiesImageUrl'] ?? '';
      _bgImageUrlController.text = data['bgImageUrl'] ?? ''; // Загрузка фонового изображения
      _rightAnswerController.text = data['rightAnswer'] ?? ''; // Загрузка правильного ответа

      // Преобразуем массив в строку
      if (data['numbers'] != null && data['numbers'] is List) {
        _numbersController.text = (data['numbers'] as List).join(',');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final part = int.tryParse(_partController.text.trim()) ?? 0;
    final videoUrl = _videoUrlController.text.trim();
    final taskDescription = _taskDescriptionController.text.trim();
    final candiesImageUrl = _candiesImageUrlController.text.trim();
    final bgImageUrl = _bgImageUrlController.text.trim();
    final rightAnswer = _rightAnswerController.text.trim();

    // Преобразуем строку вида "2,7,10,5" в список чисел
    final numbersStr = _numbersController.text.trim();
    final numbersList = numbersStr
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map(int.parse)
        .toList();

    final data = {
      'title': title,
      'part': part,
      'videoUrl': videoUrl,
      'taskDescription': taskDescription,
      'candiesImageUrl': candiesImageUrl,
      'bgImageUrl': bgImageUrl, // Сохраняем URL фонового изображения
      'numbers': numbersList,
      'rightAnswer': rightAnswer, // Сохраняем правильный ответ
    };

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.lessonId == null) {
        // Создаём новый документ
        await FirebaseFirestore.instance.collection('lessons').add(data);
      } else {
        // Обновляем существующий документ
        await FirebaseFirestore.instance
            .collection('lessons')
            .doc(widget.lessonId)
            .update(data);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.lessonId != null;

    return Scaffold(
      // Аналогичный градиент в AppBar
      appBar: AppBar(
        title: Text(isEditing ? 'Редактирование урока' : 'Создание урока'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              // Градиент фона
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFFFFDE7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Поля ввода в Card для красоты
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _titleController,
                                label: 'Название урока',
                                validatorText: 'Введите название урока',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _partController,
                                label: 'Часть (число)',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _videoUrlController,
                                label: 'Ссылка на видео',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _taskDescriptionController,
                                label: 'Описание задания',
                                maxLines: 3,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _candiesImageUrlController,
                                label: 'URL картинки с конфетами',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _bgImageUrlController,
                                label: 'URL фонового изображения',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _numbersController,
                                label: 'Числа (через запятую)',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _rightAnswerController,
                                label: 'Правильный ответ',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveLesson,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        child: Text(isEditing ? 'Сохранить изменения' : 'Создать урок'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Метод для сокращения кода по созданию TextFormField с общим стилем
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? validatorText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validatorText == null
          ? null
          : (value) {
              if (value == null || value.isEmpty) {
                return validatorText;
              }
              return null;
            },
    );
  }
}
