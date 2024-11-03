import 'package:flutter/material.dart';
import 'package:clinica/widget/menu_lateral.dart';
import '../widget/cabecalho.dart'; // Certifique-se de que o caminho está correto

class CadastrosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Cabecalho(title: 'Cadastros'), // Cabeçalho reutilizável
      drawer: MenuLateral(), // Chama o menu lateral
      body: Column(
        children: [
          // Container com cabeçalhos
          Expanded(
            child: GridView.count(
              crossAxisCount: 4, // Número de colunas
              crossAxisSpacing: 8.0, // Espaçamento entre as colunas
              mainAxisSpacing: 8.0, // Espaçamento entre as linhas
              childAspectRatio: 2, // Proporção do tamanho dos itens
              padding: EdgeInsets.all(16.0),
              children: [
                _buildAccordionItem(
                    context, 'Médico', Icons.person, '/cadastro_medico'),
                _buildAccordionItem(
                    context, 'CID', Icons.medical_services, '/cadastro_cid'),
                _buildAccordionItem(context, 'Usuários', Icons.person_add,
                    '/cadastro_usuarios'),
                _buildAccordionItem(context, 'Materiais', Icons.inventory,
                    '/cadastro_materiais'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccordionItem(
      BuildContext context, String title, IconData icon, String route) {
    return Card(
      color: Colors.white, // Cor do corpo do card
      elevation: 3, // Elevação para dar destaque ao card
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: Color(0xFF27156B), // Cor de fundo do cabeçalho
            padding: EdgeInsets.all(8.0), // Ajuste do padding
            child: Row(
              children: [
                Icon(icon, color: Colors.white), // Ícone na cor branca
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(color: Colors.white), // Texto na cor branca
                ),
              ],
            ),
          ),
          Divider(), // Divisor entre o cabeçalho e o corpo
          // Corpo do card, que inclui um texto que leva a outra tela
          Expanded(
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                      context, route); // Navega para a tela correspondente
                },
                child: Text(
                  'Cadastro $title',
                  style: TextStyle(
                    color: Color(0xFF27156B), // Cor do texto do botão
                    fontWeight: FontWeight.bold, // Negrito
                  ),
                  textAlign: TextAlign.center, // Centralizar o texto
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
