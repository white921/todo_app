import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';


// タスク追加ページのウィジェット
class AddTaskPage extends StatefulWidget {
  final String? initialTask; 
  final DateTime? initialDueDate;

  AddTaskPage({this.initialTask, this.initialDueDate});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  TextEditingController _taskController = TextEditingController(); // テキスト入力を管理するコントローラ
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.initialTask);
    _dueDate = widget.initialDueDate;
  }

  // 期限選択（日時を含む）
  Future<void> _selectDueDate() async {

    //日付選択
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    
    if (pickedDate != null) {
      // 時間選択
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }
  

  // @override
  // void dispose() {
  //   _taskController.dispose(); // ウィジェット破棄時にコントローラを解放
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: const Color.fromARGB(255, 0, 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context); // 戻るボタンで前の画面に戻る
                },
                customBorder: const CircleBorder(), 
                
                child: Container(
                  padding: EdgeInsets.only(top: 50),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle
                  ),
                  child: SvgPicture.string(
                        '''<svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24"><path d="M0 0h24v24H0z" fill="none"/><path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/></svg>''',
                        width: 30,
                        height: 30,
                        color: const Color.fromARGB(255, 255, 254, 254),
                      ),
                    
                ),
        
              ),
   
              const SizedBox(width: 10),

              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 10, top: 50),
                child: Text(
                  widget.initialTask != null ? "タスク編集" : "タスク追加",  // タスクの状態でテキストを切り替え
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ), 
            ],
          ),
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(          // タスク名を入力するフィールド
                controller: _taskController, 
                decoration: const InputDecoration(
                  labelText: "タスク名を入力",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _dueDate == null 
                      ? "期限を選択してください"
                      : "期限: ${DateFormat('yyyy-MM-dd HH:mm').format(_dueDate!)}",
                  ),
                  IconButton(
                    onPressed: _selectDueDate, 
                    icon: const Icon(Icons.calendar_today) 
                  )
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final taskName = _taskController.text;
                  Navigator.pop(context, {'task': taskName, 'dueDate': _dueDate}); // 入力されたタスク名を返して前の画面に戻る
                },
                child: const Text("タスクを保存"), // 保存ボタンのテキスト
              ),
            ],
          ),
        ),
      ),
    );
  }
}