import 'package:clinica/colors.dart';
import 'package:clinica/widget/menu_lateral.dart';
import 'package:flutter/material.dart';
import '../widget/cabecalho.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:custom_accordion/custom_accordion.dart'; // Importar a biblioteca

class ProntuarioPage extends StatefulWidget {
  final String prontuarioId;

  ProntuarioPage({required this.prontuarioId});

  @override
  _ProntuarioPageState createState() => _ProntuarioPageState();
}

class _ProntuarioPageState extends State<ProntuarioPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Cabecalho(title: 'Prontuário do Paciente'),
      drawer: MenuLateral(),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('prontuarios')
            .doc(widget.prontuarioId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados do prontuário'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Prontuário não encontrado'));
          }

          final prontuarioData = snapshot.data!.data() as Map<String, dynamic>;
          String pacienteId = prontuarioData['pacienteId'];

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('pacientes')
                .doc(pacienteId)
                .get(),
            builder: (context, pacienteSnapshot) {
              if (pacienteSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (pacienteSnapshot.hasError) {
                return Center(
                    child: Text('Erro ao carregar dados do paciente'));
              }
              if (!pacienteSnapshot.hasData || !pacienteSnapshot.data!.exists) {
                return Center(child: Text('Paciente não encontrado'));
              }

              final pacienteData =
                  pacienteSnapshot.data!.data() as Map<String, dynamic>;

              return Center(
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informações do Paciente',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor, // Cor do título
                            ),
                          ),
                          SizedBox(height: 16),
                          Table(
                            columnWidths: {
                              0: FlexColumnWidth(1), // Primeira coluna
                              1: FlexColumnWidth(1), // Segunda coluna
                            },
                            children: [
                              TableRow(children: [
                                Text('Nome: ${pacienteData['nome'] ?? 'N/A'}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                    'Telefone: ${pacienteData['telefone'] ?? 'N/A'}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ]),
                              TableRow(children: [
                                Text(
                                    'Nº do Prontuário: ${pacienteData['numeroProntuario'] ?? 'N/A'}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                    'Endereço: ${pacienteData['endereco'] ?? 'N/A'}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ]),
                              TableRow(children: [
                                Text(
                                    'Data de Nascimento: ${pacienteData['dataNascimento'] is Timestamp ? DateFormat('dd/MM/yyyy').format((pacienteData['dataNascimento'] as Timestamp).toDate()) : 'N/A'}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(), // Célula vazia para manter o alinhamento
                              ]),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text('Atendimentos:',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors
                                      .primaryColor)), // Cor do subtítulo
                          SizedBox(height: 8),
                          FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('atendimentos')
                                .where('pacienteId', isEqualTo: pacienteId)
                                .get(),
                            builder: (context, atendimentosSnapshot) {
                              if (atendimentosSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              if (atendimentosSnapshot.hasError) {
                                return Center(
                                    child:
                                        Text('Erro ao carregar atendimentos'));
                              }
                              if (!atendimentosSnapshot.hasData ||
                                  atendimentosSnapshot.data!.docs.isEmpty) {
                                return Center(
                                    child:
                                        Text('Nenhum atendimento encontrado'));
                              }

                              List<Map<String, dynamic>> atendimentos =
                                  atendimentosSnapshot.data!.docs.map((doc) {
                                final atendimentoData =
                                    doc.data() as Map<String, dynamic>;
                                return atendimentoData;
                              }).toList();

                              return Column(
                                children: atendimentos
                                    .asMap()
                                    .entries
                                    .map<Widget>((entry) {
                                  int index = entry.key;
                                  Map<String, dynamic> atendimento =
                                      entry.value;

                                  DateTime dateTime =
                                      (atendimento['data_hora'] as Timestamp)
                                          .toDate();
                                  String formattedDate =
                                      DateFormat('dd/MM/yyyy HH:mm')
                                          .format(dateTime);

                                  return CustomAccordion(
                                    headerBackgroundColor:
                                        AppColors.primaryColor,
                                    title: 'Data: $formattedDate',
                                    titleStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    widgetItems:
                                        FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('receitas')
                                          .doc(atendimento['receita_id'])
                                          .get(),
                                      builder: (context, receitaSnapshot) {
                                        if (receitaSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        }
                                        if (receitaSnapshot.hasError ||
                                            !receitaSnapshot.hasData ||
                                            !receitaSnapshot.data!.exists) {
                                          return Text(
                                              'Nenhuma receita encontrada');
                                        }

                                        final receitaData =
                                            receitaSnapshot.data!.data()
                                                as Map<String, dynamic>;
                                        List medicamentos =
                                            receitaData['medicamentos'] ?? [];

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Observações:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                              '${atendimento['observacoes'] ?? 'N/A'}',
                                            ),
                                            SizedBox(height: 15),
                                            Text('Receita:',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors
                                                        .primaryColor)), // Cor do subtítulo
                                            SizedBox(height: 8),
                                            Text('Medicamentos:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            ...medicamentos
                                                .map<Widget>((medicamento) {
                                              return ListTile(
                                                title: Text(
                                                    'Medicamento: ${medicamento['medicamento'] ?? 'N/A'}'),
                                                subtitle: Text(
                                                    'Dosagem: ${medicamento['dosagem'] ?? 'N/A'}, Período: ${medicamento['periodo'] ?? 'N/A'}'),
                                              );
                                            }).toList(),
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
