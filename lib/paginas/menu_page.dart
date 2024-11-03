import 'package:clinica/colors.dart';
import 'package:clinica/paginas/agenda_page.dart';
import 'package:clinica/paginas/atendimento_page.dart';
import 'package:clinica/paginas/cadastros_page.dart';
import 'package:clinica/paginas/pacientes_page.dart';
import 'package:clinica/widget/cadastro_atestado.dart';
import 'package:clinica/widget/cadastro_receita.dart';
import 'package:clinica/widget/menu_lateral.dart';
import 'package:flutter/material.dart';
import '../widget/cabecalho.dart'; // Certifique-se de que o caminho está correto

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Cabecalho(title: 'Menu Principal'), // Cabeçalho reutilizável
      drawer: MenuLateral(), // Chama o menu lateral
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(100.0),
          child: GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 30.0,
            mainAxisSpacing: 30.0,
            children: [
              _buildMenuCard(context, 'Paciente', 'assets/images/paciente.png',
                  PacientesPage()),
              _buildMenuCard(context, 'Agenda', 'assets/images/atendimento.png',
                  AgendaPage()),
              _buildMenuCard(context, 'Cadastros',
                  'assets/images/Relatorios.png', CadastrosPage()),
              _buildMenuCard(context, 'Configuração',
                  'assets/images/config.png', CadastrosPage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String imagePath,
      Widget destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.35, // Largura reduzida
        height: MediaQuery.of(context).size.height * 0.15, // Altura reduzida
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: AppColors.primaryColor,
                width: 2), // Borda com cor primária
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 40, // Tamanho menor da imagem
                height: 40,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12, // Texto menor
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
