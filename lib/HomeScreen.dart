import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; //アイコンを持ってくるため
import 'package:intl/intl.dart'; //Dateなどに関係するもの
import 'add_task_page.dart';

class HomeScreen extends StatefulWidget { //StatefulになってるのはUIに変数を持っているから
                                          //setState()が使えるのはStatefulだから。
  @override
  HomeScreenState createState() => HomeScreenState(); //createState メソッド は、StatefulWidget を実際に描画・更新するために、State クラスのインスタンスを作成するメソッド
}

class HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> tasks = []; //未完了タスクのリスト
  final List<Map<String, dynamic>> completedTasks = []; //完了タスクのリスト
  final GlobalKey<AnimatedListState> incompleteListKey = GlobalKey<AnimatedListState>(); //未完了タスクのリストキー(アニメーションのため)
  final GlobalKey<AnimatedListState> completedListKey = GlobalKey<AnimatedListState>(); //完了タスクのリストキー(アニメーションのため)


  //タスクを追加するメソッド、MapはKeyとValueがペアになったデータコレクション、dynamic型は動的な型
  void addTask(Map<String, dynamic> task) { 
    task['isCompleted'] = task['isCompleted'] ?? false; //task['isCompleted']がnullだったらtask['isCompleted']にfalseを代入するぞってやつ
    tasks.add(task); //tasksリストにtaskを追加
    if (tasks.isNotEmpty){
      incompleteListKey.currentState?.insertItem(tasks.length - 1); //incompleteListKey.currentStateがnullじゃなかったらinsertItemが呼ばれる
    }
  }


  //indexで指定されたタスクを完了済みにマークするメソッド
  void markTaskAsCompleted(int index, bool isCompleted) {
    if (index < 0 || index >= tasks.length) return;

    final task = tasks[index];

    incompleteListKey.currentState?.removeItem( //まだこの段階ではisCompletedがTrueになってない
      index,
      (context, animation) => buildItem(task, animation, isCompleted),
      duration: const Duration(milliseconds: 300),
    );

    setState(() {
      task['isCompleted'] = true;
      completedTasks.add(task);
      if (completedTasks.isNotEmpty) {
        completedListKey.currentState?.insertItem(completedTasks.length - 1);
      }
       
    });


    
  }


  //削除ボタンが押されたらindexのタスクを削除
  void removeTask(int index, bool isCompleted) { 
    if (isCompleted){
      if (index < 0 || index >= completedTasks.length) return;
      final removedTask = completedTasks[index];
      completedListKey.currentState?.removeItem(
        index,
        (context, animation) => buildItem(removedTask, animation, true),
        duration: const Duration(milliseconds: 300),
      );   
    }else{
      if (index < 0 || index >= tasks.length) return;
      final removedTask = tasks[index];
      incompleteListKey.currentState?.removeItem(
        index,
        (context, animation) => buildItem(removedTask, animation, false),
        duration: const Duration(milliseconds: 300),
      );
      setState(() {
        tasks.removeAt(index);
      });
    }
  }
  
  //タスク削除時のアニメーション
  Widget buildItem(Map<String, dynamic> task, Animation<double> animation, bool isCompleted) { //
    return FadeTransition( //アニメーションに応じて透明度を変化
      opacity: animation,
      child: SizeTransition( 
        sizeFactor: animation, //アニメーションに応じて大きさも変化
        child: buildTaskContent(task, animation, isCompleted), //SizeTransitionの対象
      ),
    );
  }

  //タスクの位置が移動するときのアニメーション
  Widget buildSlideItem(Map<String, dynamic> task, Animation<double> animation, {AxisDirection direction = AxisDirection.down, required bool isCompleted}) {
    Offset beginOffset; //
    switch (direction) {
      case AxisDirection.up:
        beginOffset = const Offset(0, 1);
        break;
      case AxisDirection.down:
        beginOffset = const Offset(0, -1);
        break;
      case AxisDirection.left:
        beginOffset = const Offset(1, 0);
        break;
      case AxisDirection.right:
        beginOffset = const Offset(-1, -0);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(animation),
      child: buildTaskContent(task, animation, isCompleted),
    );
  }

  //タスクごとのカードの中身を作成
  Widget buildTaskContent(Map<String, dynamic> task, Animation<double> animation, bool isCompleted) {
    final dueDate = task['dueDate'] != null //task['dueDate']がnullじゃなかったらそれをdueDateに代入
      ? DateFormat('yyyy-MM-dd HH:mm').format(task['dueDate']) //format メソッドが指定した日時オブジェクト (task['dueDate']) を上記のフォーマットに基づいて文字列に変換
      : "期限: なし";

    //タスクカードを表示させるときのアニメーション
    return Card( //アニメーションの対象がchildに指定されている
        color: isCompleted ? Colors.grey[800] : Colors.black, //タスク完了時はグレー、未完了時は黒背景
        margin: const EdgeInsets.symmetric(vertical: 12), //カード間の上下距離
        shape: RoundedRectangleBorder( 
          borderRadius: BorderRadius.circular(15), //カードの角を丸めた
        ),
        elevation: 4, //カードの影
        child: Container( //カード内部の配置
          padding: const EdgeInsets.all(24), //カード内側にも余白
          child: Row( //タスクのチェックアイコン、テキスト、編集ボタン、削除ボタン
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    if (!isCompleted) {
                      markTaskAsCompleted(tasks.indexOf(task), isCompleted);
                      tasks.removeAt(tasks.indexOf(task));
                    }
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? Colors.lightGreen : Colors.grey,
                      width: 2,
                    ),
                    color: isCompleted ? Colors.lightGreen : Colors.transparent,
                  ),
                  width: 32,
                  height: 32,
                  child: Icon(
                    Icons.check,
                    color: isCompleted ? Colors.white : Colors.grey,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task["task"],
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dueDate,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      final updatedTask = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTaskPage(
                            initialTask: task['task'],
                            initialDueDate: task['dueDate'],
                          ),
                        ),
                      );

                      if (updatedTask != null && updatedTask.isNotEmpty) {
                        setState(() {
                          task['task'] = updatedTask['task'];
                          task['dueDate'] = updatedTask['dueDate'];
                        });
                      }
                    },
                    icon: const Icon(Icons.edit, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () => removeTask(tasks.indexOf(task), isCompleted),
                    icon: SvgPicture.string(
                      '''
                      <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24">
                        <path d="M0 0h24v24H0z" fill="none"/>
                        <path d="M0 0h24v24H0V0z" fill="none"/>
                        <path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zm2.46-7.12l1.41-1.41L12 12.59l2.12-2.12 1.41 1.41L13.41 14l2.12 2.12-1.41 1.41L12 15.41l-2.12 2.12-1.41-1.41L10.59 14l-2.13-2.12zM15.5 4l-1-1h-5l-1 1H5v2h14V4z"/>
                      </svg>
                      ''',
                      width: 24,
                      height: 24,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ホーム画面"),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.black,
          bottom: const TabBar(
            tabs: [
              Tab(text: "未完了のタスク"),
              Tab(text: "完了済みタスク"),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            AnimatedList(
              key: incompleteListKey,
              padding: const EdgeInsets.all(8),
              initialItemCount: tasks.length,
              itemBuilder: (context, index, animation) {
                return buildSlideItem(tasks[index], animation, direction: AxisDirection.down, isCompleted: false);
              },
            ),
            AnimatedList(
              key: completedListKey,
              padding: const EdgeInsets.all(8),
              initialItemCount: completedTasks.length,
              itemBuilder: (context, index, animation) {
                return buildSlideItem(completedTasks[index], animation, direction: AxisDirection.up, isCompleted: true);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final Map<String, dynamic>? newTask = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTaskPage()),
            );
            if (newTask != null && newTask.isNotEmpty) {
              setState(() {
                addTask(newTask);
              });
            }
          },
          backgroundColor: Colors.black,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
