import 'package:clinica/paginas/atendimento_page.dart';
import 'package:clinica/widget/menu_lateral.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widget/cabecalho.dart'; // Certifique-se de que o caminho está correto

class AgendaPage extends StatefulWidget {
  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Cabecalho(title: 'Agendamentos'), // Cabeçalho reutilizável
      drawer: MenuLateral(), // Menu lateral
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 150.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Agendamento",
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF27156B),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      mostrarModalCadastro(context);
                    },
                    child: Text(
                      'Novo +',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF27156B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('agendamentos')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar atendimentos'));
                  }

                  final agendamentos = snapshot.data!.docs;

                  return SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DataTable(
                        headingRowColor:
                            MaterialStateProperty.all(Color(0xFF8F9EA5)),
                        columns: [
                          DataColumn(
                              label: Text('Nº Agend.',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Paciente',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Data',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Hora',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Médico',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Status',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Opções',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                        ],
                        rows: agendamentos.map((agendamentos) {
                          final data =
                              agendamentos.data() as Map<String, dynamic>;
                          return DataRow(
                            cells: [
                              DataCell(Text(
                                  data['numeroAtendimento']?.toString() ?? '')),
                              DataCell(
                                (data['paciente'] != null)
                                    ? FutureBuilder<String>(
                                        future:
                                            obterNomePaciente(data['paciente']),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Text('Carregando...');
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Erro: ${snapshot.error}');
                                          } else {
                                            return Text(snapshot.data ??
                                                'Nome não encontrado');
                                          }
                                        },
                                      )
                                    : Text('ID do paciente não disponível'),
                              ),
                              DataCell(Text(data['data'] ?? '')),
                              DataCell(Text(data['hora'] ?? '')),
                              DataCell(
                                FutureBuilder<String>(
                                  future: obterNomeMedico(data[
                                      'medico']), // Acessando o ID do médico
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text('Carregando...');
                                    } else if (snapshot.hasError) {
                                      return Text('Erro: ${snapshot.error}');
                                    } else {
                                      return Text(snapshot.data ??
                                          'Nome não encontrado');
                                    }
                                  },
                                ),
                              ),
                              DataCell(
                                Text(
                                  data['status'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(data['status']),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        editarAgendamento(
                                            context, agendamentos.id);
                                      },
                                    ),
                                    Text('Editar',
                                        style: TextStyle(color: Colors.blue)),
                                    SizedBox(width: 16),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        excluirAtendimento(
                                            context, agendamentos.id);
                                      },
                                    ),
                                    Text('Excluir',
                                        style: TextStyle(color: Colors.red)),
                                    SizedBox(width: 16),
                                    // Botão Iniciar
                                    IconButton(
                                      icon: Icon(Icons.play_arrow,
                                          color: Colors.green),
                                      onPressed: () async {
                                        // Verifica se o status é "Agendado"
                                        if (data['status'] == 'Agendado') {
                                          // Criação do atendimento
                                          DocumentReference atendimentoRef =
                                              FirebaseFirestore.instance
                                                  .collection('atendimentos')
                                                  .doc();

                                          // Dados do atendimento a serem salvos
                                          Map<String, dynamic> atendimentoData =
                                              {
                                            'pacienteId': data[
                                                'paciente'], // Associa ao ID do agendamento ou paciente
                                            'agendamentoId': agendamentos
                                                .id, // Adiciona o ID do agendamento aqui
                                            'data_hora': Timestamp
                                                .now(), // Data e hora atual
                                            'diagnostico':
                                                '', // Deixe em branco, será preenchido depois
                                          };

                                          // Tenta salvar o atendimento no Firestore
                                          try {
                                            await atendimentoRef.set(
                                                atendimentoData); // Salva os dados no documento

                                            // Se bem-sucedido, navega para a página de Atendimento, passando o ID do atendimento recém-criado
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AtendimentoPage(
                                                  atendimentoId:
                                                      atendimentoRef.id,
                                                  agendamentoId: agendamentos
                                                      .id, // Passa o ID do agendamento corretamente
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            print(
                                                "Erro ao criar o atendimento: $e");
                                            // Aqui você pode exibir uma mensagem de erro ao usuário, se desejar
                                          }
                                        } else {
                                          // Exibe uma mensagem de erro caso o status não seja "Agendado"
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Não é possível iniciar o atendimento. Status deve ser "Agendado".')),
                                          );
                                        }
                                      },
                                    ),
                                    Text(
                                      'Iniciar',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Agendado':
        return Colors.green; // Verde para "Agendado"
      case 'Em Andamento':
        return Color(0xFF27156B); // Cor primária para "Em Andamento"
      case 'Finalizado':
        return Colors.purple; // Roxo para "Finalizado"
      default:
        return Colors.black; // Cor padrão (preta) se não houver status
    }
  }

  void excluirAtendimento(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Excluir Atendimento'),
          content: Text('Tem certeza que deseja excluir este atendimento?'),
          actions: [
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('agendamentos')
                    .doc(id)
                    .delete();
                Navigator.of(context).pop();
              },
              child: Text('Sim'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Não'),
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
                  'Cadastro de Atendimento',
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

  Future<String> obterNomeMedico(String medicoId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('medicos')
          .doc(medicoId)
          .get();

      if (doc.exists) {
        return doc['nome'] ?? 'Nome não encontrado';
      } else {
        return 'Médico não encontrado';
      }
    } catch (e) {
      print('Erro ao obter nome do médico: $e');
      return 'Erro ao buscar nome';
    }
  }

  Future<String> obterNomePaciente(String pacienteId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('pacientes')
          .doc(pacienteId)
          .get();

      if (doc.exists) {
        return doc['nome'] ?? 'Nome não encontrado';
      } else {
        return 'Paciente não encontrado';
      }
    } catch (e) {
      print('Erro ao obter nome do paciente: $e');
      return 'Erro ao buscar nome';
    }
  }

  void editarAgendamento(BuildContext context, String agendamentoId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('agendamentos')
        .doc(agendamentoId)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      final TextEditingController dataController =
          TextEditingController(text: data['data']);
      final TextEditingController horaController =
          TextEditingController(text: data['hora']);
      String? pacienteSelecionado = data['paciente'];
      String? medicoSelecionado = data['medico'];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Editar Agendamento'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Campo de Seleção de Paciente
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('pacientes')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }
                          List<DropdownMenuItem<String>> pacientesItems =
                              snapshot.data!.docs.map((doc) {
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(doc['nome']),
                            );
                          }).toList();
                          return DropdownButtonFormField<String>(
                            value: pacienteSelecionado,
                            decoration: InputDecoration(
                              labelText: 'Selecione o Paciente',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            items: pacientesItems,
                            onChanged: (newValue) {
                              setState(() {
                                pacienteSelecionado = newValue;
                              });
                            },
                          );
                        },
                      ),
                      SizedBox(height: 16),

                      // Campo de Seleção de Médico
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('medicos')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }
                          List<DropdownMenuItem<String>> medicosItems =
                              snapshot.data!.docs.map((doc) {
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(doc['nome']),
                            );
                          }).toList();
                          return DropdownButtonFormField<String>(
                            value: medicoSelecionado,
                            decoration: InputDecoration(
                              labelText: 'Selecione o Médico',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            items: medicosItems,
                            onChanged: (newValue) {
                              setState(() {
                                medicoSelecionado = newValue;
                              });
                            },
                          );
                        },
                      ),
                      SizedBox(height: 16),

                      // Seleção de Data
                      TextField(
                        controller: dataController,
                        decoration: InputDecoration(
                          labelText: 'Selecione a Data',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              dataController.text =
                                  DateFormat('dd/MM/yyyy').format(pickedDate);
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16),

                      // Seleção de Hora
                      TextField(
                        controller: horaController,
                        decoration: InputDecoration(
                          labelText: 'Selecione a Hora',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        readOnly: true,
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              horaController.text = pickedTime.format(context);
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Fecha o modal
                },
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('agendamentos')
                      .doc(agendamentoId)
                      .update({
                    'paciente': pacienteSelecionado,
                    'medico': medicoSelecionado,
                    'data': dataController.text,
                    'hora': horaController.text,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Agendamento atualizado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: Text('Salvar'),
              ),
            ],
          );
        },
      );
    }
  }

// Função para buscar os pacientes no Firestore
  Future<List<String>> getPacientes() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('pacientes').get();
    return querySnapshot.docs.map((doc) => doc['nome'] as String).toList();
  }

// Função para buscar os médicos no Firestore
  Future<List<String>> getMedicos() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('medicos').get();
    return querySnapshot.docs.map((doc) => doc['nome'] as String).toList();
  }
}

class FormularioCadastro extends StatefulWidget {
  @override
  _FormularioCadastroState createState() => _FormularioCadastroState();
}

class _FormularioCadastroState extends State<FormularioCadastro> {
  final TextEditingController dataController = TextEditingController();
  final TextEditingController horaController = TextEditingController();
  String? pacienteSelecionado;
  String? medicoSelecionado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Campo de Seleção de Paciente
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('pacientes').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              List<DropdownMenuItem<String>> pacientesItems =
                  snapshot.data!.docs.map((doc) {
                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(doc['nome']),
                );
              }).toList();
              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Selecione o Paciente',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                items: pacientesItems,
                onChanged: (newValue) {
                  setState(() {
                    pacienteSelecionado = newValue;
                  });
                },
              );
            },
          ),
          SizedBox(height: 16),

          // Campo de Seleção de Médico
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('medicos').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              List<DropdownMenuItem<String>> medicosItems =
                  snapshot.data!.docs.map((doc) {
                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(doc['nome']),
                );
              }).toList();
              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Selecione o Médico',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                items: medicosItems,
                onChanged: (newValue) {
                  setState(() {
                    medicoSelecionado = newValue;
                  });
                },
              );
            },
          ),
          SizedBox(height: 16),

          // Seleção de Data
          TextField(
            controller: dataController,
            decoration: InputDecoration(
              labelText: 'Selecione a Data',
              prefixIcon: Icon(Icons.calendar_today),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  dataController.text =
                      DateFormat('dd/MM/yyyy').format(pickedDate);
                });
              }
            },
          ),
          SizedBox(height: 16),

          // Seleção de Hora
          TextField(
            controller: horaController,
            decoration: InputDecoration(
              labelText: 'Selecione a Hora',
              prefixIcon: Icon(Icons.access_time),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            readOnly: true,
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                setState(() {
                  horaController.text = pickedTime.format(context);
                });
              }
            },
          ),
          SizedBox(height: 16),

          // Botões de Ação
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
                  await salvarAtendimento();
                  Navigator.pop(context); // Fecha o modal após salvar
                },
                child: Text('Agendar'),
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

  Future<void> salvarAtendimento() async {
    if (pacienteSelecionado != null && medicoSelecionado != null) {
      try {
        // Recuperar o número atual de atendimentos
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('agendamentos')
            .orderBy('numeroAtendimento', descending: true)
            .limit(1)
            .get();

        int numeroAtendimento = 1; // Valor padrão
        if (querySnapshot.docs.isNotEmpty) {
          // Obter o número do último atendimento
          numeroAtendimento = querySnapshot.docs.first['numeroAtendimento'] + 1;
        }

        // Salvar no Firebase com status "Agendado"
        await FirebaseFirestore.instance.collection('agendamentos').add({
          'paciente': pacienteSelecionado,
          'medico': medicoSelecionado,
          'data': dataController.text,
          'hora': horaController.text,
          'status': 'Agendado', // Status padrão
          'numeroAtendimento':
              numeroAtendimento, // Adiciona o número do atendimento
        });

        // Exibe SnackBar de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Atendimento agendado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Exibe SnackBar de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao agendar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione o paciente e o médico.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
