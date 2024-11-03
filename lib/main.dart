import 'package:clinica/paginas/agenda_page.dart';
import 'package:clinica/paginas/atendimento_page.dart';
import 'package:clinica/paginas/cid_page.dart';
import 'package:clinica/paginas/material_page.dart';
import 'package:clinica/paginas/medico_page.dart';
import 'package:clinica/paginas/usuario_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importando o pacote Firebase
import 'colors.dart'; // Certifique-se de ter esse arquivo
import 'paginas/menu_page.dart'; // Importando o arquivo da tela de menu
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform); // Inicializa o Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor, // Usando a cor primária
        scaffoldBackgroundColor: Color(0xFFD9D9D9), // Cor de fundo da tela
      ),
      home: LoginScreen(),
      routes: {
        '/cadastro_medico': (context) => MedicoPage(),
        '/cadastro_usuarios': (context) => UsuarioPage(),
        '/cadastro_materiais': (context) => MedicamentoPage(),
        '/cadastro_cid': (context) => CidPage(),
        '/login': (context) => LoginScreen(),
        '/agenda': (context) => AgendaPage(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    String usuario = usuarioController.text.trim();
    String senha = senhaController.text.trim();

    try {
      // Busca o documento do usuário com o campo 'usuario' fornecido
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('usuario', isEqualTo: usuario)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Se não encontrou nenhum documento com o 'usuario' fornecido
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não encontrado.')),
        );
        return;
      }

      // Pega o documento encontrado
      DocumentSnapshot userDoc = querySnapshot.docs.first;

      // Verifica se a senha fornecida está correta
      if (userDoc['senha'] == senha) {
        // Autenticação personalizada bem-sucedida
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
      } else {
        // Senha incorreta
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Senha incorreta.')),
        );
      }
    } catch (e) {
      // Captura qualquer erro que ocorra durante o processo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/logo.png',
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: AppColors.backgroundColor,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.3,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usuarioController,
                      decoration: InputDecoration(
                        labelText: 'Usuário',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: senhaController,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: false,
                              onChanged: (bool? value) {
                                // Lógica para o checkbox
                              },
                            ),
                            Text('Lembre-me',
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // Lógica para "Esqueci a Senha"
                          },
                          child: Text(
                            'Esqueci a Senha',
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      child: Text('Entrar',
                          style: TextStyle(color: AppColors.buttonTextColor)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
