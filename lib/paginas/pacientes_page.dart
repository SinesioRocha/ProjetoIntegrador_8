import 'dart:math';

import 'package:clinica/paginas/prontuario_page.dart';
import 'package:clinica/widget/menu_lateral.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';
import '../widget/cabecalho.dart';
import 'package:flutter/services.dart'; // Importa TextInputFormatter

class PacientesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Cabecalho(title: 'Pacientes'), // Cabeçalho reutilizável
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
                    "Pacientes",
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
                stream: FirebaseFirestore.instance
                    .collection('pacientes')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar pacientes'));
                  }

                  final pacientes = snapshot.data!.docs;

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
                              label: Text('CPF',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white))), // Negrito e cor do texto
                          DataColumn(
                              label: Text('Nome',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white))), // Negrito e cor do texto
                          DataColumn(
                              label: Text('Telefone',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white))), // Negrito e cor do texto
                          DataColumn(
                              label: Text('Prontuário',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white))), // Negrito e cor do texto
                          DataColumn(
                              label: Text('Opções',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white))), // Negrito e cor do texto
                        ],
                        rows: pacientes.map(
                          (paciente) {
                            final data =
                                paciente.data() as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(Text(data['cpf'] ?? '')),
                                DataCell(Text(data['nome'] ?? '')),
                                DataCell(Text(data['telefone'] ?? '')),
                                DataCell(
                                  TextButton(
                                    onPressed: () {
                                      // Navegar para a tela de prontuário do paciente, passando o ID do paciente ou número do prontuário
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProntuarioPage(
                                            prontuarioId: data[
                                                'prontuarioId'], // ou o ID correspondente do paciente
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      data['numeroProntuario'] ?? '',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          // Ação para editar paciente
                                          editarPaciente(context, paciente.id);
                                        },
                                      ),
                                      Text(
                                        'Editar',
                                        style: TextStyle(color: Colors.blue),
                                      ), // Texto para o botão de editar
                                      SizedBox(
                                          width:
                                              16), // Espaço entre os ícones e textos
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          // Ação para excluir paciente
                                          excluirPaciente(context, paciente.id);
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

void editarPaciente(BuildContext context, String pacienteId) {
  FirebaseFirestore.instance
      .collection('pacientes')
      .doc(pacienteId)
      .get()
      .then((doc) {
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      // Criar controladores para os campos de texto
      final TextEditingController nomeController =
          TextEditingController(text: data['nome']);
      final TextEditingController cpfController =
          TextEditingController(text: data['cpf']);
      final TextEditingController rgController =
          TextEditingController(text: data['rg']);
      final TextEditingController telefoneController =
          TextEditingController(text: data['telefone']);
      final TextEditingController emailController =
          TextEditingController(text: data['email']);
      final TextEditingController enderecoController =
          TextEditingController(text: data['endereco']);
      final TextEditingController bairroController =
          TextEditingController(text: data['bairro']);
      final TextEditingController cidadeController =
          TextEditingController(text: data['cidade']);
      final TextEditingController estadoController =
          TextEditingController(text: data['estado']);
      final TextEditingController cepController =
          TextEditingController(text: data['cep']);
      final TextEditingController nomePaiController =
          TextEditingController(text: data['nomePai']);
      final TextEditingController nomeMaeController =
          TextEditingController(text: data['nomeMae']);
      final TextEditingController profissaoController =
          TextEditingController(text: data['profissao']);
      final TextEditingController cnesController =
          TextEditingController(text: data['cnes']);
      final TextEditingController convenioController =
          TextEditingController(text: data['convenio']);
      final TextEditingController dataNascimentoController =
          TextEditingController(text: data['dataNascimento']);

      // Exibir o diálogo de edição
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Editar Paciente',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27156B)), // Estilo do título
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 600, // Largura do dialogo
                height: 500, // Altura para evitar erro de tamanho
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  childAspectRatio: 5, // Ajuste do aspecto dos campos
                  children: [
                    _buildTextField(nomeController, 'Nome', Icons.person),
                    _buildTextField(
                        telefoneController, 'Telefone', Icons.phone),
                    _buildTextField(cpfController, 'CPF', Icons.assignment),
                    _buildTextField(rgController, 'RG', Icons.assignment),
                    _buildTextField(emailController, 'Email', Icons.email),
                    _buildTextField(enderecoController, 'Endereço', Icons.home),
                    _buildTextField(
                        bairroController, 'Bairro', Icons.location_on),
                    _buildTextField(
                        cidadeController, 'Cidade', Icons.location_city),
                    _buildTextField(estadoController, 'Estado', Icons.flag),
                    _buildTextField(
                        cepController, 'CEP', Icons.local_post_office),
                    _buildTextField(
                        nomePaiController, 'Nome do Pai', Icons.person),
                    _buildTextField(
                        nomeMaeController, 'Nome da Mãe', Icons.person),
                    _buildTextField(
                        profissaoController, 'Profissão', Icons.work),
                    _buildTextField(
                        cnesController, 'CNES', Icons.local_hospital),
                    _buildTextField(
                        convenioController, 'Convênio', Icons.business),
                    _buildTextField(dataNascimentoController,
                        'Data de Nascimento', Icons.calendar_today),
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
                      .collection('pacientes')
                      .doc(pacienteId)
                      .update({
                    'nome': nomeController.text,
                    'telefone': telefoneController.text,
                    'cpf': cpfController.text,
                    'rg': rgController.text,
                    'email': emailController.text,
                    'endereco': enderecoController.text,
                    'bairro': bairroController.text,
                    'cidade': cidadeController.text,
                    'estado': estadoController.text,
                    'cep': cepController.text,
                    'nomePai': nomePaiController.text,
                    'nomeMae': nomeMaeController.text,
                    'profissao': profissaoController.text,
                    'cnes': cnesController.text,
                    'convenio': convenioController.text,
                    'dataNascimento': dataNascimentoController.text,
                  }).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Paciente atualizado com sucesso!')),
                    );
                    Navigator.of(context).pop(); // Fecha o diálogo
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao atualizar paciente.')),
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

void excluirPaciente(BuildContext context, String pacienteId) {
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
          'Você realmente deseja excluir este paciente?',
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
              // Realiza a exclusão do paciente
              FirebaseFirestore.instance
                  .collection('pacientes')
                  .doc(pacienteId)
                  .delete()
                  .then((_) {
                // Exibe a mensagem de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Paciente excluído com sucesso!'),
                    backgroundColor: Colors.green, // Cor de fundo da mensagem
                  ),
                );
              }).catchError((error) {
                // Tratar erro ao excluir
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir paciente.'),
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
                'Cadastro Paciente', // Título
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              FormularioCadastro(),
            ],
          ),
        ),
      );
    },
  );
}

class FormularioCadastro extends StatelessWidget {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController rgController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController nomePaiController = TextEditingController();
  final TextEditingController nomeMaeController = TextEditingController();
  final TextEditingController profissaoController = TextEditingController();
  final TextEditingController cnesController = TextEditingController();
  final TextEditingController convenioController = TextEditingController();
  final TextEditingController dataNascimentoController =
      TextEditingController(); // Controller para data de nascimento

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
              childAspectRatio: 5, // Para ajustar a altura
              children: [
                _buildTextField(nomeController, 'Nome', Icons.person),
                _buildTextFieldFormatted(cpfController, 'CPF',
                    Icons.document_scanner, CpfInputFormatter()),
                _buildTextField(rgController, 'RG', Icons.perm_identity),
                _buildDropdownField('Sexo', ['Masculino', 'Feminino', 'Outro']),
                _buildTextFieldFormatted(telefoneController, 'Telefone',
                    Icons.phone, TelefoneInputFormatter()),
                _buildTextField(emailController, 'Email', Icons.email),
                _buildTextField(enderecoController, 'Endereço', Icons.home),
                _buildTextField(bairroController, 'Bairro', Icons.place),
                _buildTextField(
                    cidadeController, 'Cidade', Icons.location_city),
                _buildTextField(estadoController, 'Estado', Icons.map),
                _buildTextFieldFormatted(cepController, 'CEP',
                    Icons.location_on, CepInputFormatter()),
                _buildTextField(
                    nomePaiController, 'Nome Pai', Icons.family_restroom),
                _buildTextField(
                    nomeMaeController, 'Nome Mãe', Icons.family_restroom),
                _buildDropdownField(
                    'Escolaridade', ['Fundamental', 'Médio', 'Superior']),
                _buildTextField(profissaoController, 'Profissão', Icons.work),
                _buildTextField(cnesController, 'CNES', Icons.badge),
                _buildTextField(
                    convenioController, 'Convênio', Icons.medical_services),
                _buildTextFieldFormatted(
                    dataNascimentoController,
                    'Data de Nascimento',
                    Icons.calendar_today,
                    DataInputFormatter()),
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
                    // Gerar um número de prontuário automaticamente
                    String numeroProntuario =
                        (100000 + (Random().nextInt(900000))).toString();

                    // Salvar os dados do paciente no Firestore
                    DocumentReference pacienteRef = await FirebaseFirestore
                        .instance
                        .collection('pacientes')
                        .add({
                      'nome': nomeController.text,
                      'cpf': cpfController.text,
                      'rg': rgController.text,
                      'telefone': telefoneController.text,
                      'email': emailController.text,
                      'endereco': enderecoController.text,
                      'bairro': bairroController.text,
                      'cidade': cidadeController.text,
                      'estado': estadoController.text,
                      'cep': cepController.text,
                      'nomePai': nomePaiController.text,
                      'nomeMae': nomeMaeController.text,
                      'profissao': profissaoController.text,
                      'cnes': cnesController.text,
                      'convenio': convenioController.text,
                      'dataNascimento':
                          dataNascimentoController.text, // Data de nascimento
                    });

                    print("Paciente salvo com ID: ${pacienteRef.id}");

                    // Criar um prontuário vinculado ao paciente
                    DocumentReference prontuarioRef = await FirebaseFirestore
                        .instance
                        .collection('prontuarios')
                        .add({
                      'numeroProntuario': numeroProntuario,
                      'pacienteId': pacienteRef.id, // Referência ao paciente
                      'dataCriacao': FieldValue.serverTimestamp(),
                    });

                    // Atualizar o paciente com o ID do prontuário
                    await pacienteRef.update({
                      'numeroProntuario': numeroProntuario,
                      'prontuarioId': prontuarioRef.id,
                    });

                    // Exibe SnackBar de sucesso
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Paciente e prontuário salvos com sucesso!'),
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
                    print('Erro ao criar prontuário: $e');
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

  Widget _buildDropdownField(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {},
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(Icons.arrow_drop_down),
      ),
    );
  }
}
