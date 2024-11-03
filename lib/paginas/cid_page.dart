import 'package:clinica/widget/menu_lateral.dart';
import 'package:flutter/material.dart';
import '../widget/cabecalho.dart'; // Certifique-se de que o caminho está correto
import 'package:clinica/widget/menu_lateral.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';
import '../widget/cabecalho.dart';
import 'package:flutter/services.dart'; // Importa TextInputFormatter

class CidPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Cabecalho(title: 'CID'), // Cabeçalho reutilizável
      drawer: MenuLateral(), // Chama o menu lateral
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 150.0),
        child: Center(
          // Centraliza o conteúdo
          child: Column(
            children: [
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Distribui espaço entre os widgets
                children: [
                  Text(
                    "CID",
                    textAlign: TextAlign.center, // Centraliza o texto
                    style: TextStyle(
                      fontSize: 38, // Tamanho da fonte
                      fontWeight: FontWeight.w900, // Negrito
                      color: Color(0xFF27156B), // Cor do texto
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Ação para abrir o modal de cadastro
                      mostrarModalCadastro(context);
                    },
                    child: Text(
                      'Novo +',
                      style: TextStyle(color: Colors.white), // Texto branco
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF27156B), // Cor de fundo personalizada
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Bordas arredondadas
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('cids').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar CIDS'));
                  }
                  final cids = snapshot.data!.docs;
                  return SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width *
                          0.8, // 80% da largura da tela
                      decoration: BoxDecoration(
                        color: Colors.white, // Fundo branco
                        borderRadius:
                            BorderRadius.circular(12), // Bordas arredondadas
                        boxShadow: [
                          // Sombra para a tabela
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // Sombra abaixo
                          ),
                        ],
                      ),
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Color(
                            0xFF8F9EA5)), // Cabeçalho com cor personalizada
                        columns: [
                          DataColumn(
                              label: Text('Codigo',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white))), // Negrito e cor do texto
                          DataColumn(
                              label: Text('Descrição',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white))), // Negrito e cor do texto

                          DataColumn(
                            label: Text(
                              'Opções',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ), // Negrito e cor do texto
                        ],
                        rows: cids.map(
                          (cids) {
                            final data = cids.data() as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(data['codigo'] ?? ''),
                                ),
                                DataCell(
                                  Text(data['descricao'] ?? ''),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          // Ação para editar paciente
                                          editarCID(context, cids.id);
                                        },
                                      ),
                                      Text('Editar',
                                          style: TextStyle(
                                              color: Colors
                                                  .blue)), // Texto para o botão de editar
                                      SizedBox(
                                          width:
                                              16), // Espaço entre os ícones e textos
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          // Ação para excluir paciente
                                          excluirCID(context, cids.id);
                                        },
                                      ),
                                      Text(
                                        'Excluir',
                                        style: TextStyle(color: Colors.red),
                                      ), // Texto para o botão de excluir
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void mostrarModalCadastro(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cadastro CID', // Título adaptado
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              FormularioCadastroCID(),
            ],
          ),
        ),
      );
    },
  );
}

class FormularioCadastroCID extends StatelessWidget {
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SingleChildScrollView(
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 1, // Para um layout mais simples
              childAspectRatio: 3, // Ajuste a proporção
              children: [
                _buildTextField(codigoController, 'Código', Icons.code),
                _buildTextField(
                    descricaoController, 'Descrição', Icons.description),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Fecha o modal
                },
                child: Text('Cancelar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC6C4CC), // Cor de fundo do botão
                  foregroundColor: Color(0xFF27156B), // Cor do texto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Ação do botão Salvar
                    await FirebaseFirestore.instance.collection('cids').add({
                      'codigo': codigoController.text,
                      'descricao': descricaoController.text,
                    });

                    // Exibe SnackBar de sucesso
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('CID salvo com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    // Exibe SnackBar de erro
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao salvar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    Navigator.pop(context); // Fecha o modal após salvar
                  }
                },
                child: Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF27156B), // Cor de fundo do botão
                  foregroundColor: Colors.white, // Cor do texto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

void editarCID(BuildContext context, String cidId) {
  FirebaseFirestore.instance.collection('cids').doc(cidId).get().then((doc) {
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      // Criar controladores para os campos de texto
      final TextEditingController codigoController =
          TextEditingController(text: data['codigo']);
      final TextEditingController descricaoController =
          TextEditingController(text: data['descricao']);

      // Exibir o diálogo de edição
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Editar CID',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27156B)), // Estilo do título
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400, // Largura do dialogo
                child: Column(
                  children: [
                    _buildTextField(codigoController, 'Código', Icons.code),
                    SizedBox(height: 16), // Espaçamento entre os campos
                    _buildTextField(
                        descricaoController, 'Descrição', Icons.description),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Fecha o modal
                },
                child: Text('Cancelar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC6C4CC), // Cor de fundo do botão
                  foregroundColor: Color(0xFF27156B), // Cor do texto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Atualiza os dados no Firestore
                  FirebaseFirestore.instance
                      .collection('cids')
                      .doc(cidId)
                      .update({
                    'codigo': codigoController.text,
                    'descricao': descricaoController.text,
                  }).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('CID atualizado com sucesso!')),
                    );
                    Navigator.of(context).pop(); // Fecha o diálogo
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao atualizar CID.')),
                    );
                  });
                },
                child: Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF27156B), // Cor de fundo do botão
                  foregroundColor: Colors.white, // Cor do texto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  });
}

Widget _buildTextField(
    TextEditingController controller, String label, IconData icon) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
    ),
  );
}

void excluirCID(BuildContext context, String cidId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Confirmar Exclusão',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Título em negrito
            fontSize: 20, // Tamanho do texto
            color: Color(0xFF27156B), // Cor do texto
          ),
        ),
        content: Text(
          'Você realmente deseja excluir este CID?',
          style: TextStyle(fontSize: 16), // Estilo do texto do conteúdo
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey, // Cor do texto de cancelar
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o diálogo
            },
          ),
          TextButton(
            child: Text(
              'Excluir',
              style: TextStyle(
                color: Colors.red, // Cor do texto de excluir
                fontWeight: FontWeight.bold, // Texto em negrito
              ),
            ),
            onPressed: () {
              // Realiza a exclusão do CID
              FirebaseFirestore.instance
                  .collection('cids')
                  .doc(cidId)
                  .delete()
                  .then((_) {
                // Exibe a mensagem de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('CID excluído com sucesso!'),
                    backgroundColor: Colors.green, // Cor de fundo da mensagem
                  ),
                );
                Navigator.of(context).pop(); // Fecha o diálogo
              }).catchError((error) {
                // Tratar erro ao excluir
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir CID.'),
                    backgroundColor: Colors.red, // Cor de fundo do erro
                  ),
                );
              });
            },
          ),
        ],
      );
    },
  );
}
