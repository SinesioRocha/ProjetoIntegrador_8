import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CadastroAtestado extends StatefulWidget {
  final String agendamentoId;

  const CadastroAtestado({required this.agendamentoId});

  @override
  _CadastroAtestadoState createState() => _CadastroAtestadoState();
}

class _CadastroAtestadoState extends State<CadastroAtestado> {
  final TextEditingController dataController = TextEditingController();
  final TextEditingController periodoController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();
  List<Map<String, dynamic>> listaCids = [];
  String? cidSelecionado;

  @override
  void initState() {
    super.initState();
    buscarCids(); // Chama o método para buscar os CIDs
    DateTime agora = DateTime.now();
    dataController.text =
        "${agora.day}/${agora.month}/${agora.year} ${agora.hour}:${agora.minute}";
  }

  Future<void> buscarCids() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('cids').get();

      setState(() {
        listaCids = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'codigo': doc['codigo'], // campo do código CID na coleção
            'nome': doc['descricao'], // campo do nome CID na coleção
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar CIDs: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Cadastro de Atestado')),
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
              readOnly: true,
            ),
            SizedBox(height: 16),

            // Campo de Seleção de CID
            DropdownButtonFormField<String>(
              value: cidSelecionado,
              items: listaCids.map((cid) {
                return DropdownMenuItem<String>(
                  value: cid['id'],
                  child: Text("${cid['codigo']} - ${cid['nome']}"),
                );
              }).toList(),
              onChanged: (String? novoValor) {
                setState(() {
                  cidSelecionado = novoValor;
                });
              },
              decoration: InputDecoration(
                labelText: 'CID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
            ),
            SizedBox(height: 16),

            // Campo de Observação e Período de Afastamento
            TextField(
              controller: periodoController,
              decoration: InputDecoration(
                labelText: 'Período de Afastamento',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: observacaoController,
              decoration: InputDecoration(
                labelText: 'Observação',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            SizedBox(height: 16),

            // Botão para salvar o atestado
            ElevatedButton(
              onPressed: () async {
                if (cidSelecionado == null ||
                    periodoController.text.isEmpty ||
                    observacaoController.text.isEmpty) {
                  _mostrarMensagemErro(
                      'Por favor, preencha todos os campos antes de salvar.');
                  return;
                }

                try {
                  DocumentReference atestadoRef =
                      FirebaseFirestore.instance.collection('atestados').doc();

                  Map<String, dynamic> atestadoData = {
                    'data_hora': Timestamp.now(),
                    'atendimento_id': widget.agendamentoId,
                    'cid_id': cidSelecionado, // Adiciona o CID selecionado
                    'periodo': periodoController.text,
                    'observacao': observacaoController.text,
                  };

                  await atestadoRef.set(atestadoData);

                  await FirebaseFirestore.instance
                      .collection('atendimentos')
                      .doc(widget.agendamentoId)
                      .update({'atestado_id': atestadoRef.id});

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Atestado salvo com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {
                    periodoController.clear();
                    observacaoController.clear();
                    cidSelecionado = null;
                  });

                  Navigator.pop(context, true);
                } catch (e) {
                  _mostrarMensagemErro('Erro ao salvar atestado: $e');
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
