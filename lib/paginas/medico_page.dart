import 'package:clinica/widget/menu_lateral.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';
import '../widget/cabecalho.dart';
import 'package:flutter/services.dart'; // Importa TextInputFormatter

class MedicoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Cabecalho(title: 'Medico'), // Cabeçalho reutilizável
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
                    "Médico",
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
                      mostrarModalCadastroMedico(context);
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
                    .collection('medicos')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar Medicos'));
                  }

                  final medicos = snapshot.data!.docs;

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
                              'CRM',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ), // Negrito e cor do texto
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
                              'Telefone',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ), // Negrito e cor do texto
                          DataColumn(
                            label: Text(
                              'Especialidade',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ), // Negrito e cor do texto
                          DataColumn(
                            label: Text(
                              'Opções',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ), // Negrito e cor do texto
                        ],
                        rows: medicos.map(
                          (medicos) {
                            final data = medicos.data() as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(Text(data['crm'] ?? '')),
                                DataCell(Text(data['nome'] ?? '')),
                                DataCell(Text(data['telefone'] ?? '')),
                                DataCell(Text(data['especialidade'] ?? '')),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          // Ação para editar paciente
                                          editarMedico(context, medicos.id);
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
                                          excluirMedico(context, medicos.id);
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

void mostrarModalCadastroMedico(BuildContext context) {
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
                'Cadastro Médico', // Título
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              FormularioCadastroMedico(),
            ],
          ),
        ),
      );
    },
  );
}

class FormularioCadastroMedico extends StatelessWidget {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController dataNascimentoController =
      TextEditingController();
  final TextEditingController crmController = TextEditingController();
  final TextEditingController especialidadeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

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
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              childAspectRatio: 5,
              children: [
                _buildTextField(nomeController, 'Nome', Icons.person),
                _buildTextFieldFormatted(
                    dataNascimentoController,
                    'Data de Nascimento',
                    Icons.calendar_today,
                    DataInputFormatter()),
                _buildTextField(crmController, 'CRM', Icons.badge),
                _buildTextField(especialidadeController, 'Especialidade',
                    Icons.medical_services),
                _buildTextFieldFormatted(telefoneController, 'Telefone',
                    Icons.phone, TelefoneInputFormatter()),
                _buildTextField(emailController, 'Email', Icons.email),
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
                    await FirebaseFirestore.instance.collection('medicos').add({
                      'nome': nomeController.text,
                      'dataNascimento': dataNascimentoController.text,
                      'crm': crmController.text,
                      'especialidade': especialidadeController.text,
                      'telefone': telefoneController.text,
                      'email': emailController.text,
                    });

                    // Exibe SnackBar de sucesso
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Médico salvo com sucesso!'),
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

  Widget _buildTextFieldFormatted(TextEditingController controller,
      String label, IconData icon, TextInputFormatter formatter) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        formatter,
      ],
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

void excluirMedico(BuildContext context, String medicoId) {
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
          'Você realmente deseja excluir este médico?',
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
              // Realiza a exclusão do médico
              FirebaseFirestore.instance
                  .collection('medicos') // Mudança para a coleção 'medicos'
                  .doc(medicoId) // Identifica o médico pelo ID
                  .delete()
                  .then((_) {
                // Exibe a mensagem de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Médico excluído com sucesso!'),
                    backgroundColor: Colors.green, // Cor de fundo da mensagem
                  ),
                );
              }).catchError((error) {
                // Tratar erro ao excluir
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir médico.'),
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

void editarMedico(BuildContext context, String medicoId) {
  FirebaseFirestore.instance
      .collection('medicos')
      .doc(medicoId)
      .get()
      .then((doc) {
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      // Criar controladores para os campos de texto
      final TextEditingController nomeController =
          TextEditingController(text: data['nome']);
      final TextEditingController crmController =
          TextEditingController(text: data['crm']);
      final TextEditingController especialidadeController =
          TextEditingController(text: data['especialidade']);
      final TextEditingController telefoneController =
          TextEditingController(text: data['telefone']);
      final TextEditingController emailController =
          TextEditingController(text: data['email']);
      final TextEditingController dataNascimentoController =
          TextEditingController(text: data['dataNascimento']);

      // Exibir o diálogo de edição
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Editar Médico',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27156B)), // Estilo do título
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 600, // Largura do diálogo
                height: 400, // Altura para evitar erro de tamanho
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  childAspectRatio: 5, // Ajuste do aspecto dos campos
                  children: [
                    _buildTextField(nomeController, 'Nome', Icons.person),
                    _buildTextField(crmController, 'CRM', Icons.badge),
                    _buildTextField(especialidadeController, 'Especialidade',
                        Icons.medical_services),
                    _buildTextFieldFormattedTelefone(
                        telefoneController,
                        'Telefone',
                        Icons
                            .phone), // Aqui você pode usar o formato diretamente
                    _buildTextField(emailController, 'Email', Icons.email),
                    _buildTextFieldFormattedData(
                        dataNascimentoController,
                        'Data de Nascimento',
                        Icons.calendar_today), // Mesma coisa aqui
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
                      .collection('medicos')
                      .doc(medicoId)
                      .update({
                    'nome': nomeController.text,
                    'crm': crmController.text,
                    'especialidade': especialidadeController.text,
                    'telefone': telefoneController.text,
                    'email': emailController.text,
                    'dataNascimento': dataNascimentoController.text,
                  }).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Médico atualizado com sucesso!')),
                    );
                    Navigator.of(context).pop(); // Fecha o diálogo
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao atualizar médico.')),
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

Widget _buildTextFieldFormattedTelefone(
    TextEditingController controller, String label, IconData icon) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      TelefoneInputFormatter(),
    ],
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

Widget _buildTextFieldFormattedData(
    TextEditingController controller, String label, IconData icon) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      DataInputFormatter(),
    ],
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
