import 'package:example/app/pages/cidade_estado_page.dart';
import 'package:flutter/material.dart';

class ExamplesPage extends StatefulWidget {
  const ExamplesPage({super.key});

  @override
  State<ExamplesPage> createState() => _ExamplesPageState();
}

class _ExamplesPageState extends State<ExamplesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemplos'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Cidade/Estado'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CidadeEstadoPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
