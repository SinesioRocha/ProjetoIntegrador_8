import 'package:clinica/paginas/cadastros_page.dart';
import 'package:clinica/paginas/material_page.dart';
import 'package:clinica/paginas/medico_page.dart';
import 'package:clinica/paginas/pacientes_page.dart';
import 'package:clinica/paginas/usuario_page.dart';
import 'package:flutter/material.dart';

class MenuLateral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF27156B), // Cor primária
            ),
            child: Text(
              'CSC System',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Paciente'),
            onTap: () {
              // Ação ao clicar em "Paciente"
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PacientesPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Atendimento'),
            onTap: () {
              Navigator.pushNamed(context, '/agenda');
            },
          ),
          // Adicione outros itens aqui
          ListTile(
            leading: Icon(Icons.receipt),
            title: Text('Receitas'),
            onTap: () {
              Navigator.pushNamed(context, '/receitas');
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment_turned_in),
            title: Text('Atestados'),
            onTap: () {
              Navigator.pushNamed(context, '/atestados');
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('Cadastros'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CadastrosPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configuração'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
