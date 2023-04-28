import 'package:flutter/material.dart';

enum DialogType { add, delete, edit }

class MarkerDialog extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final double lat;
  final double lon;
  final TextEditingController nameController;
  final Function? onConfirm;
  final DialogType type;
  final String name;


  static const Map<DialogType, String> _headerText = {
    DialogType.add: 'Marker 추가',
    DialogType.delete: 'Marker 삭제',
    DialogType.edit: 'Marker 수정',
  };


  static const Map<DialogType, String> _confirmText = {
    DialogType.add: '추가하기',
    DialogType.delete: '삭제하기',
    DialogType.edit: '수정하기',
  };


  const MarkerDialog({
    Key? key,
    required this.formKey,
    required this.lat,
    required this.lon,
    required this.nameController,
    required this.onConfirm,
    required this.type,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = FocusNode();
    nameController.text = name;
    focusNode.requestFocus();                   // 자동 포커스 요청
    return AlertDialog(
      title: Text(_headerText[type]!),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("위도: ${lat.toStringAsFixed(7)}"),
            Text("경도: ${lon.toStringAsFixed(7)}"),

            (type == DialogType.delete)?
            Text("$name 을[를] 삭제하시겠습니까?"):
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "이름",
              ),
              focusNode: focusNode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "이름을 입력해주세요.";
                }
                return null;
              },
            ),

          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('취소'),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(context).pop();
                      onConfirm!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(_confirmText[type]!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
