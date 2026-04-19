import 'package:flutter/material.dart';
import 'homepage_screen.dart';

class CreateCirclePage extends StatefulWidget {
  const CreateCirclePage({super.key});

  @override
  State<CreateCirclePage> createState() => _CreateCirclePageState();
}

class _CreateCirclePageState extends State<CreateCirclePage> {
  final _circleNameController = TextEditingController(text: 'Eco Battle');
  String _selectedTheme = 'Sustainability';

  @override
  void dispose() {
    _circleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F0),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF84B785), Color(0xFFACCFA3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: const [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0x33FFFFFF),
                        child: Icon(Icons.group, size: 28, color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Create Your Circle',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Choose a default theme and create a private Circle with your friends.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Circle Details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2B2B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Circle Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F4B47),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F7F2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.edit, color: Color(0xFF556B5C)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextField(
                                  controller: _circleNameController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Eco Battle',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF24382F),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Theme',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F4B47),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F7F2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.eco, color: Color(0xFF556B5C)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedTheme,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Sustainability',
                                        child: Text('Sustainability'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Fitness',
                                        child: Text('Fitness'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Wellness',
                                        child: Text('Wellness'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedTheme = value;
                                        });
                                      }
                                    },
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF24382F),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7BAE7F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: const Text(
                              'Create Circle',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Assuming this is the Circles page
        selectedItemColor: const Color(0xFF2B4F37),
        unselectedItemColor: const Color(0xFF95A39A),
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomepageScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: 'Circles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rtl),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
