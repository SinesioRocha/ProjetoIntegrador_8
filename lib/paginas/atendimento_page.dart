import 'package:clinica/widget/cadastro_atestado.dart';
import 'package:clinica/widget/cadastro_receita.dart';
import 'package:clinica/widget/menu_lateral.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widget/cabecalho.dart'; // Certifique-se de que o caminho está correto

class AtendimentoPage extends StatefulWidget {
  final String atendimentoId;
  final String agendamentoId;

  AtendimentoPage({required this.atendimentoId, required this.agendamentoId});

  @override
  _AtendimentoPageState createState() => _AtendimentoPageState();
}

class _AtendimentoPageState extends State<AtendimentoPage> {
  Map<String, dynamic>? agendamentoData;
  TextEditingController _observacaoController =
      TextEditingController(); // Controlador para as observações

  @override
  void initState() {
    super.initState();
    _carregarDadosAgendamento(); // Descomentar para carregar os dados do agendamento
  }

  Future<void> _carregarDadosAgendamento() async {
    try {
      // Busca o atendimento no Firestore usando o ID do atendimento
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection(
              'atendimentos') // Alterado de 'agendamentos' para 'atendimentos'
          .doc(widget.atendimentoId) // Usando atendimentoId
          .get();

      if (snapshot.exists) {
        setState(() {
          agendamentoData = snapshot.data() ?? {};
        });
      } else {
        setState(() {
          agendamentoData = {};
        });
      }
    } catch (e) {
      print('Erro ao buscar os dados do atendimento: $e');
    }
  }

  Future<void> _finalizarAtendimento() async {
    if (_observacaoController.text.isNotEmpty) {
      try {
        // Atualiza a observação no atendimento
        await FirebaseFirestore.instance
            .collection('atendimentos')
            .doc(widget.atendimentoId) // ID do atendimento
            .update({
          'observacoes': _observacaoController.text,
        });

        // Atualiza o status no agendamento
        await FirebaseFirestore.instance
            .collection('agendamentos')
            .doc(widget.agendamentoId) // ID do agendamento
            .update({
          'status': 'Finalizado',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Atendimento finalizado com sucesso!')),
        );

        Navigator.pop(context);
      } catch (e) {
        print('Erro ao finalizar atendimento: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao finalizar atendimento!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Por favor, insira observações antes de finalizar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Cabecalho(title: 'Atendimento'),
      drawer: MenuLateral(),
      body: Padding(
        padding: const EdgeInsets.all(26.0),
        child: SingleChildScrollView(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: agendamentoData == null
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Atendimento',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        // Exibe o número do agendamento e o nome do paciente em duas colunas

                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('atendimentos')
                              .doc(widget.atendimentoId)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text(
                                  'Erro ao carregar atendimentos: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                !snapshot.data!.exists) {
                              return Text('Atendimento não encontrado');
                            } else {
                              var agendamentoData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              print(agendamentoData);
                              // Verifica se os campos existem
                              String? agendamentoId =
                                  agendamentoData['agendamentoId'];
                              String? pacienteId =
                                  agendamentoData['pacienteId'];

                              // Verifica se o agendamentoId e o pacienteId não são nulos
                              if (agendamentoId == null || pacienteId == null) {
                                return Text(
                                    'Agendamento ou paciente não encontrado no atendimento');
                              }

                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('agendamentos')
                                    .doc(agendamentoId)
                                    .get(),
                                builder: (context, agendamentoSnapshot) {
                                  if (agendamentoSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (agendamentoSnapshot.hasError) {
                                    return Text(
                                        'Erro ao carregar agendamento: ${agendamentoSnapshot.error}');
                                  } else if (!agendamentoSnapshot.hasData ||
                                      !agendamentoSnapshot.data!.exists) {
                                    return Text('Agendamento não encontrado');
                                  } else {
                                    var agendamento = agendamentoSnapshot.data!
                                        .data() as Map<String, dynamic>;

                                    // Verifica se os campos existem
                                    String? data = agendamento['data'];
                                    String? hora = agendamento['hora'];
                                    int? numeroAtendimento =
                                        agendamento['numeroAtendimento'];

                                    // Verifica se data e hora não são nulos
                                    if (data == null ||
                                        hora == null ||
                                        numeroAtendimento == null) {
                                      return Text(
                                          'Dados do agendamento incompletos');
                                    }

                                    return FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('pacientes')
                                          .doc(pacienteId)
                                          .get(),
                                      builder: (context, pacienteSnapshot) {
                                        if (pacienteSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (pacienteSnapshot.hasError) {
                                          return Text(
                                              'Erro ao carregar paciente: ${pacienteSnapshot.error}');
                                        } else if (!pacienteSnapshot.hasData ||
                                            !pacienteSnapshot.data!.exists) {
                                          return Text(
                                              'Paciente não encontrado');
                                        } else {
                                          var pacienteData =
                                              pacienteSnapshot.data!.data()
                                                  as Map<String, dynamic>;
                                          String? nomePaciente =
                                              pacienteData['nome'];

                                          // Verifica se o nome do paciente não é nulo
                                          if (nomePaciente == null) {
                                            return Text(
                                                'Nome do paciente não encontrado');
                                          }

                                          return Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    ' Paciente: $nomePaciente',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                  Text(
                                                    'Nº Agendamento: $numeroAtendimento',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Hora: $hora',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                  Text(
                                                    'Data: $data',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    );
                                  }
                                },
                              );
                            }
                          },
                        ),

                        SizedBox(height: 16),

                        // Campo de observações
                        TextField(
                          controller: _observacaoController,
                          decoration: InputDecoration(
                            labelText: 'Observações do Atendimento',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 15,
                        ),
                        SizedBox(height: 16),

                        // Botão para finalizar o atendimento
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _finalizarAtendimento,
                              child: Text('Finalizar Atendimento'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF27156B),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal:
                                        32), // Ajuste o padding para tornar o botão mais largo
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius
                                      .zero, // Defina o borderRadius para zero para criar bordas retas
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 150.0,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Exibe o modal com o widget ReceitasPage
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SizedBox(
                                      height: 600,
                                      child: CadastroReceita(
                                        agendamentoId: widget.atendimentoId,
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'Receitas',
                                style: TextStyle(
                                    color: Color(
                                        0xFF27156B)), // Cor do texto na cor primária
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // Fundo branco
                                side: BorderSide(
                                    color: Color(0xFF27156B),
                                    width: 2), // Borda na cor primária
                                padding: EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal:
                                        16), // Ajuste para deixar mais quadrado
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius
                                      .zero, // Borda retangular, sem arredondamento
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 150.0,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Exibe o modal com o widget ReceitasPage
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SizedBox(
                                      height: 600,
                                      child: CadastroAtestado(
                                        agendamentoId: widget.atendimentoId,
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'Atestados',
                                style: TextStyle(
                                    color: Color(
                                        0xFF27156B)), // Cor do texto na cor primária
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // Fundo branco
                                side: BorderSide(
                                    color: Color(0xFF27156B),
                                    width: 2), // Borda na cor primária
                                padding: EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal:
                                        16), // Ajuste para deixar mais quadrado
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius
                                      .zero, // Borda retangular, sem arredondamento
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
