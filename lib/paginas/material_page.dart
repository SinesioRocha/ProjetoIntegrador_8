import 'package:clinica/widget/menu_lateral.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';
import '../widget/cabecalho.dart';
import 'package:flutter/services.dart'; // Importa TextInputFormatter

class MedicamentoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Cabecalho(
            title: 'Medicamento e Material'), // Cabeçalho reutilizável
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
                    "Medicamento e Material",
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
                    .collection('materiais_medicamentos')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Erro ao carregar Material e Medicamento'));
                  }

                  final materiaisMedicamentos = snapshot.data!.docs;

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
                            Color(0xFF8F9EA5)), // Cabeçalho personalizado
                        columns: [
                          DataColumn(
                              label: Text('Código de Barras',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white))), // Negrito e cor do texto
                          DataColumn(
                              label: Text('Nome',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Descrição',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Fabricante',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Unidade de Medida',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Opções',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                        ],
                        rows: materiaisMedicamentos.map((materialMedicamento) {
                          final data = materialMedicamento.data()
                              as Map<String, dynamic>;
                          return DataRow(cells: [
                            DataCell(Text(data['codigoDeBarras'] ?? '')),
                            DataCell(Text(data['nome'] ?? '')),
                            DataCell(Text(data['descricao'] ?? '')),
                            DataCell(Text(data['fabricante'] ?? '')),
                            DataCell(Text(data['unidadeDeMedida'] ?? '')),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    // Ação para editar material/medicamento
                                    editarMaterial(
                                        context, materialMedicamento.id);
                                  },
                                ),
                                Text('Editar',
                                    style: TextStyle(color: Colors.blue)),
                                SizedBox(
                                    width:
                                        16), // Espaço entre os ícones e textos
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    // Ação para excluir material/medicamento
                                    excluirMaterial(
                                        context, materialMedicamento.id);
                                  },
                                ),
                                Text('Excluir',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ],
          )),
        ));
  }
}

void editarMaterial(BuildContext context, String materialId) {
  FirebaseFirestore.instance
      .collection('materiais_medicamentos')
      .doc(materialId)
      .get()
      .then((doc) {
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      // Criar controladores para os campos de texto
      final TextEditingController codigoBarrasController =
          TextEditingController(text: data['codigoDeBarras']);
      final TextEditingController nomeController =
          TextEditingController(text: data['nome']);
      final TextEditingController descricaoController =
          TextEditingController(text: data['descricao']);
      final TextEditingController fabricanteController =
          TextEditingController(text: data['fabricante']);
      String? unidadeDeMedida = data['unidadeDeMedida'];

      // Exibir o diálogo de edição
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Editar Material/Medicamento',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF27156B),
              ),
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 600,
                height: 200,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  childAspectRatio: 5,
                  children: [
                    _buildTextField(codigoBarrasController, 'Código de Barras',
                        Icons.qr_code),
                    _buildTextField(nomeController, 'Nome', Icons.label),
                    _buildTextField(descricaoController, 'Descrição',
                        Icons.description), // Campo de descrição adicionado
                    _buildTextField(
                        fabricanteController, 'Fabricante', Icons.factory),
                    _buildDropdownField('Unidade de Medida', [
                      'Unidade-UN',
                      'Litros-LT',
                      'Quilograma-Kg',
                      'Miligrama-Mg'
                    ], (value) {
                      unidadeDeMedida = value;
                    }),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              // Campo Descrição ocupando a linha inteira
              TextField(
                controller: descricaoController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 6, // Permite várias linhas
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
                        // Atualiza os dados no Firestore
                        await FirebaseFirestore.instance
                            .collection('materiais_medicamentos')
                            .doc(materialId)
                            .update({
                          'codigoDeBarras': codigoBarrasController.text,
                          'nome': nomeController.text,
                          'descricao': descricaoController.text,
                          'fabricante': fabricanteController.text,
                          'unidadeDeMedida': unidadeDeMedida,
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Material/Medicamento atualizado com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao atualizar: $e'),
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
              )
            ],
          );
        },
      );
    }
  });
}

Widget _buildDropdownField(
    String label, List<String> items, Function(String?) onChanged) {
  return DropdownButtonFormField<String>(
    items: items.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      prefixIcon: Icon(Icons.arrow_drop_down),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );
}

void excluirMaterial(BuildContext context, String materialId) {
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
          'Você realmente deseja excluir este Material/Medicamento?',
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
              // Realiza a exclusão do material/medicamento
              FirebaseFirestore.instance
                  .collection('materiais_medicamentos')
                  .doc(materialId)
                  .delete()
                  .then((_) {
                // Exibe a mensagem de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Material/Medicamento excluído com sucesso!'),
                    backgroundColor: Colors.green, // Cor de fundo da mensagem
                  ),
                );
              }).catchError((error) {
                // Tratar erro ao excluir
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir Material/Medicamento.'),
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
                'Cadastro Material/Medicamento',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              FormularioCadastroMaterial(),
            ],
          ),
        ),
      );
    },
  );
}

class FormularioCadastroMaterial extends StatelessWidget {
  final TextEditingController codigoBarrasController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController fabricanteController = TextEditingController();

  String? unidadeDeMedida =
      'unidadeDeMedida'; // Valor padrão para a lista suspensa

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            childAspectRatio: 5, // Para ajustar a altura dos campos
            children: [
              _buildTextField(
                codigoBarrasController,
                'Código de Barras',
                Icons.qr_code,
              ),
              _buildTextField(nomeController, 'Nome', Icons.label),
              _buildTextField(
                fabricanteController,
                'Fabricante',
                Icons.factory,
              ),
              _buildDropdownField('Unidade Medida',
                  ['Unidade-UN', 'Litros-LT', 'Quilograma-Kg', 'Miligrama-Mg']),
            ],
          ),
          SizedBox(height: 16),
          // Campo Descrição ocupando a linha inteira
          TextField(
            controller: descricaoController,
            decoration: InputDecoration(
              labelText: 'Descrição',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: 10, // Permite várias linhas
          ),
          SizedBox(height: 16),
          // Botões Salvar e Cancelar
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
                    await FirebaseFirestore.instance
                        .collection('materiais_medicamentos')
                        .add({
                      'codigoDeBarras': codigoBarrasController.text,
                      'nome': nomeController.text,
                      'descricao': descricaoController.text,
                      'fabricante': fabricanteController.text,
                      'unidadeDeMedida': unidadeDeMedida,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Material/Medicamento salvo com sucesso!'),
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

  Widget _buildDropdownField(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        unidadeDeMedida = newValue;
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(Icons.arrow_drop_down),
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
