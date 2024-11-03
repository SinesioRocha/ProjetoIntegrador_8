import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CadastroReceita extends StatefulWidget {
  final String agendamentoId; // Recebe o ID do atendimento

  // Construtor que recebe o ID
  const CadastroReceita({required this.agendamentoId});

  @override
  _CadastroReceitaState createState() => _CadastroReceitaState();
}

class _CadastroReceitaState extends State<CadastroReceita> {
  final TextEditingController dataController = TextEditingController();
  final TextEditingController periodoController = TextEditingController();
  final List<Map<String, dynamic>> medicamentos = [];

  List<String> medicamentosDisponiveis = [];
  String? medicamentoSelecionado;
  final TextEditingController dosagemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarMedicamentos();

    // Definindo a data e hora atuais
    DateTime agora = DateTime.now();
    dataController.text =
        "${agora.day}/${agora.month}/${agora.year} ${agora.hour}:${agora.minute}";
  }

  void carregarMedicamentos() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('materiais_medicamentos')
          .get();
      setState(() {
        medicamentosDisponiveis =
            snapshot.docs.map((doc) => doc['nome'] as String).toList();
      });
    } catch (e) {
      _mostrarMensagemErro('Erro ao carregar medicamentos.');
    }
  }

  void _mostrarMensagemErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  void adicionarMedicamento() {
    if (medicamentoSelecionado != null &&
        dosagemController.text.isNotEmpty &&
        periodoController.text.isNotEmpty) {
      setState(() {
        medicamentos.add({
          'medicamento': medicamentoSelecionado,
          'dosagem': dosagemController.text,
          'periodo': periodoController.text,
        });
        // Limpar os campos após adicionar o medicamento
        medicamentoSelecionado = null;
        dosagemController.clear();
        periodoController.clear();
      });
    } else {
      _mostrarMensagemErro(
          'Por favor, selecione um medicamento, preencha a dosagem e o período.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Cor de fundo branco
      appBar: AppBar(title: Text('Cadastro de Receita')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: dataController,
              decoration: InputDecoration(
                labelText: 'Data e Hora',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true, // A data é gerada automaticamente
            ),
            SizedBox(height: 16),

            // Dropdown para selecionar medicamento
            DropdownButtonFormField<String>(
              value: medicamentoSelecionado,
              onChanged: (newValue) {
                setState(() {
                  medicamentoSelecionado = newValue;
                });
              },
              items: medicamentosDisponiveis.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Selecione o Medicamento',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Campo de Período e Dosagem
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: periodoController,
                    decoration: InputDecoration(
                      labelText: 'Período',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: dosagemController,
                    decoration: InputDecoration(
                      labelText: 'Dosagem',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Botão para adicionar medicamento
            ElevatedButton(
              onPressed: adicionarMedicamento,
              child: Text('+ Adicionar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF27156B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Lista de medicamentos adicionados
            SizedBox(
              height: 200, // Aumenta o espaço da lista de medicamentos
              child: medicamentos.isNotEmpty
                  ? ListView.separated(
                      itemCount: medicamentos.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        var med = medicamentos[index];
                        return ListTile(
                          title: Text(med['medicamento']),
                          subtitle: Text(
                              'Dosagem: ${med['dosagem']} | Período: ${med['periodo']}'),
                        );
                      },
                    )
                  : Center(child: Text('Nenhum medicamento adicionado.')),
            ),
            SizedBox(height: 16),

            // Botão para salvar a receita
            ElevatedButton(
              onPressed: () async {
                try {
                  // Cria um novo documento na coleção "receitas"
                  DocumentReference receitaRef =
                      FirebaseFirestore.instance.collection('receitas').doc();

                  // Dados a serem salvos
                  Map<String, dynamic> receitaData = {
                    'data_hora': Timestamp.now(), // Data e hora atual
                    'atendimento_id': widget.agendamentoId, // ID do atendimento
                    'medicamentos': medicamentos.map((med) {
                      return {
                        'medicamento': med['medicamento'],
                        'dosagem': med['dosagem'],
                        'periodo': med['periodo'],
                      };
                    }).toList(),
                  };

                  // Salva os dados no Firestore
                  await receitaRef.set(receitaData);

                  // Atualiza o atendimento para referenciar a receita
                  await FirebaseFirestore.instance
                      .collection('atendimentos')
                      .doc(widget.agendamentoId)
                      .update({'receita_id': receitaRef.id});

                  // Exibe uma mensagem de sucesso
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Receita salva com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Limpa os campos após o salvamento
                  setState(() {
                    medicamentos.clear();
                    periodoController.clear();
                    dosagemController.clear();
                  });

                  // Volta para a tela anterior e indica que houve uma atualização
                  Navigator.pop(context, true);
                } catch (e) {
                  // Exibe uma mensagem de erro em caso de falha
                  _mostrarMensagemErro('Erro ao salvar receita: $e');
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
      ),
    );
  }
}
