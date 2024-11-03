import 'package:clinica/widget/menu_lateral.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';
import '../widget/cabecalho.dart';
import 'package:flutter/services.dart'; // Importa TextInputFormatter

class UsuarioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Cabecalho(title: 'Usuários'), // Cabeçalho reutilizável
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
                    "Usuários",
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
                      mostrarModalCadastroUsuario(context);
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
                stream: FirebaseFirestore.instance
                    .collection('usuarios')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar Usuarios'));
                  }

                  final usuarios = snapshot.data!.docs;

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
                        headingRowColor: MaterialStateProperty.all(
                          Color(0xFF8F9EA5),
                        ), // Cabeçalho com cor personalizada
                        columns: [
                          DataColumn(
                            label: Text(
                              'Nome',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ), // Negrito e cor do texto
                          DataColumn(
                            label: Text(
                              'Usuario',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ), // Negrito e cor do texto
                          DataColumn(
                            label: Text(
                              'Senha',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ), // Negrito e cor do texto
                          // Negrito e cor do texto
                          DataColumn(
                            label: Text(
                              'Opções',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ), // Negrito e cor do texto
                        ],
                        rows: usuarios.map(
                          (usuarios) {
                            final data =
                                usuarios.data() as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(Text(data['nome'] ?? '')),
                                DataCell(Text(data['usuario'] ?? '')),
                                DataCell(Text('*******')),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          // Ação para editar paciente
                                          editarUsuario(context, usuarios.id);
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
                                          // Ação para excluir
                                          excluirUsuario(context, usuarios.id);
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

void editarUsuario(BuildContext context, String usuarioId) {
  FirebaseFirestore.instance
      .collection('usuarios')
      .doc(usuarioId)
      .get()
      .then((doc) {
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      // Criar controladores para os campos de texto
      final TextEditingController nomeController =
          TextEditingController(text: data['nome']);
      final TextEditingController usuarioController =
          TextEditingController(text: data['usuario']);
      final TextEditingController senhaController = TextEditingController(
          text: data['senha']); // Não deve mostrar a senha

      // Exibir o diálogo de edição
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Editar Usuário',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27156B)), // Estilo do título
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 600, // Largura do diálogo
                height: 300, // Altura para evitar erro de tamanho
                child: Column(
                  children: [
                    _buildTextField(nomeController, 'Nome', Icons.person),
                    _buildTextField(
                        usuarioController, 'Usuário', Icons.person_add),
                    _buildTextFieldSenha(senhaController, 'Senha',
                        Icons.lock), // Exibir campo de senha
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
                      .collection('usuarios')
                      .doc(usuarioId)
                      .update({
                    'nome': nomeController.text,
                    'usuario': usuarioController.text,
                    'senha': senhaController
                        .text, // Considere usar hash para segurança
                  }).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Usuário atualizado com sucesso!')),
                    );
                    Navigator.of(context).pop(); // Fecha o diálogo
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao atualizar usuário.')),
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

Widget _buildTextFieldSenha(
    TextEditingController controller, String label, IconData icon) {
  return TextField(
    controller: controller,
    obscureText: true, // Para esconder a senha
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
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

void excluirUsuario(BuildContext context, String usuarioId) {
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
          'Você realmente deseja excluir este usuário?',
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
              // Realiza a exclusão do usuário
              FirebaseFirestore.instance
                  .collection('usuarios') // Mudança para a coleção 'usuarios'
                  .doc(usuarioId) // Identifica o usuário pelo ID
                  .delete()
                  .then((_) {
                // Exibe a mensagem de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Usuário excluído com sucesso!'),
                    backgroundColor: Colors.green, // Cor de fundo da mensagem
                  ),
                );
              }).catchError((error) {
                // Tratar erro ao excluir
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir usuário.'),
                    backgroundColor: Colors.red, // Cor de fundo do erro
                  ),
                );
              });
              Navigator.of(context).pop(); // Fecha o diálogo
            },
          ),
        ],
      );
    },
  );
}

void mostrarModalCadastroUsuario(BuildContext context) {
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
                'Cadastro de Usuário',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              FormularioCadastroUsuario(),
            ],
          ),
        ),
      );
    },
  );
}

class FormularioCadastroUsuario extends StatefulWidget {
  @override
  _FormularioCadastroUsuarioState createState() =>
      _FormularioCadastroUsuarioState();
}

class _FormularioCadastroUsuarioState extends State<FormularioCadastroUsuario> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  String selectedUserType = 'Atendente'; // Default to Atendente
  String? selectedMedicoId; // Para armazenar o ID do médico selecionado

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 1,
            crossAxisSpacing: 8,
            childAspectRatio: 5,
            children: [
              _buildTextField(nomeController, 'Nome', Icons.person),
              _buildTextField(usuarioController, 'Usuário', Icons.person_add),
              _buildTextFieldSenha(senhaController, 'Senha', Icons.lock),
              _buildUserTypeDropdown(),
              if (selectedUserType == 'Médico') _buildMedicoDropdown(),
            ],
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
                  backgroundColor: Color(0xFFC6C4CC),
                  foregroundColor: Color(0xFF27156B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Ação do botão Salvar
                    Map<String, dynamic> userData = {
                      'nome': nomeController.text,
                      'usuario': usuarioController.text,
                      'senha': senhaController.text,
                      'tipo': selectedUserType,
                    };

                    // Adiciona o ID do médico se o tipo for Médico
                    if (selectedUserType == 'Médico' &&
                        selectedMedicoId != null) {
                      userData['medicoId'] =
                          selectedMedicoId; // Apenas o ID do médico
                    }

                    await FirebaseFirestore.instance
                        .collection('usuarios')
                        .add(userData);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Usuário salvo com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
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
                  backgroundColor: Color(0xFF27156B),
                  foregroundColor: Colors.white,
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

  Widget _buildTextFieldSenha(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildUserTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedUserType,
      items: [
        DropdownMenuItem(value: 'Atendente', child: Text('Atendente')),
        DropdownMenuItem(value: 'Médico', child: Text('Médico')),
      ],
      onChanged: (value) {
        setState(() {
          selectedUserType = value!;
          selectedMedicoId =
              null; // Reseta o médico selecionado se o tipo mudar
        });
      },
      decoration: InputDecoration(
        labelText: 'Tipo de Usuário',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildMedicoDropdown() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('medicos')
          .get()
          .then((snapshot) {
        return snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Carregando
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('Nenhum médico cadastrado.'); // Sem médicos
        }

        return DropdownButtonFormField<String>(
          value: selectedMedicoId,
          items: snapshot.data!.map((medico) {
            return DropdownMenuItem<String>(
              value: medico['id'],
              child: Text(
                  '${medico['nome']} - CRM: ${medico['crm']} - Especialidade: ${medico['especialidade']}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedMedicoId =
                  value; // Armazena apenas o ID do médico selecionado
            });
          },
          decoration: InputDecoration(
            labelText: 'Selecione o Médico',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }
}
