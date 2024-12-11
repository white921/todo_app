import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; //アイコンを持ってくるため
import 'package:intl/intl.dart'; //Dateなどに関係するもの
import 'package:shared_preferences/shared_preferences.dart';
import 'add_task_page.dart';
import 'dart:convert'; // JSONエンコード/デコードのためにインポート

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  //StatefulになってるのはUIに変数を持っているから
  //setState()が使えるのはStatefulだから。
  @override
  HomeScreenState createState() =>
      HomeScreenState(); //createState メソッド は、StatefulWidget を実際に描画・更新するために、State クラスのインスタンスを作成するメソッド
}

class Task {
  //フィールド
  String name;
  DateTime dueDate;
  bool isCompleted;

  //コンストラクタ(初期値設定)
  Task({
    required this.name, //requiredは必須の変数
    required this.dueDate,
    this.isCompleted = false, //最初は絶対false
  });

  //JSON形式に変換
  Map<String, dynamic> toJson() => {
        'name': name,
        'dueDate': dueDate.toIso8601String(),
        'isCompleted': isCompleted,
      };
  // JSONからTaskを作成
  factory Task.fromJson(Map<String, dynamic> json) {
    if (json['dueDate'] == null) {
      throw ArgumentError('dueDate is required.');
    }
    return Task(
      name: json['name'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

//HomeScreenウィジェットの状態を管理するためのStateクラス
class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  //with SingleTickerProviderStateMixinはvsync（垂直同期）を使えるようにする
  List<Task> tasks = []; //未完了タスクのリスト
  List<Task> completedTasks = []; //完了タスクのリスト
  final GlobalKey<AnimatedListState> incompleteListKey =
      GlobalKey<AnimatedListState>(); //未完了タスクのリストキー(アニメーションのため)
  final GlobalKey<AnimatedListState> completedListKey = GlobalKey<AnimatedListState>(); //完了タスクのリストキー(アニメーションのため)
  late TabController _tabController; //タブの切り替えを管理するためのコントローラ

  //ウィジェットの初期化処理
  @override
  void initState() {
    super.initState(); //親クラスのinitStateを呼び出す
    _loadTasks(); // 初期化時にタスクを読み込む
    _tabController = TabController(length: 2, vsync: this); //2つのタブを管理する
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //タスクを追加するメソッド、MapはKeyとValueがペアになったデータコレクション、dynamic型は動的な型
  void addTask(Task task) {
    tasks.add(task); //tasksリストにtaskを追加
    if (tasks.isNotEmpty) {
      incompleteListKey.currentState?.insertItem(tasks.length - 1); //incompleteListKey.currentStateがnullじゃなかったらinsertItemが呼ばれる
    }
    _saveTasks();
  }

  // タスクを保存する関数
  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // tasksをJSON形式の文字列に変換して保存
    String tasksJson = json.encode(tasks.map((task) => task.toJson()).toList());
    String completedTasksJson =
        jsonEncode(completedTasks.map((task) => task.toJson()).toList());
    await prefs.setString("tasks", tasksJson); // 未完了タスクの保存
    await prefs.setString("completedTasks", completedTasksJson); // 完了タスクの保存
    //List<Task>をそのまま保存することはできないからJson形式の文字列に変換して保存した
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // JSON形式の文字列として保存されたタスクを取得
    String? tasksJson = prefs.getString("tasks");
    String? completedTasksJson = prefs.getString("completedTasks");

    //JSON形式の文字列をデコード
    tasks = (jsonDecode(tasksJson!) as List)
        .map((data) => Task.fromJson(data))
        .toList();
      completedTasks = (jsonDecode(completedTasksJson!) as List)
        .map((data) => Task.fromJson(data))
        .toList();
  
    setState(() {});
  }

  //完了ボタンを押したときの挙動を示すメソッド
  void markTaskAsCompleted(int index, bool isCompleted) {
    if (!isCompleted) {
      if (index < 0 || index >= tasks.length) return;
      final task = tasks[index];
      tasks.removeAt(index);

      incompleteListKey.currentState?.removeItem(
        //?はnullを許容する演算子
        //まだこの段階ではisCompletedがTrueになってない
        index,
        (context, animation) => buildItem(task, animation, false),
        duration: const Duration(milliseconds: 300),
      );

      setState(() {
        task.isCompleted = true;
        completedTasks.add(task);
        if (completedTasks.isNotEmpty) {
          completedListKey.currentState?.insertItem(completedTasks.length - 1);
        }
        _saveTasks(); // 状態変更後に保存
      });
    } else {
      if (index < 0 || index >= completedTasks.length) return;
      final task = completedTasks[index];
      completedTasks.removeAt(index);

      completedListKey.currentState?.removeItem(
        index,
        (context, animation) => buildItem(task, animation, true),
        duration: const Duration(milliseconds: 300),
      );

      setState(() {
        task.isCompleted = false;
        tasks.add(task);
        if (tasks.isNotEmpty) {
          incompleteListKey.currentState?.insertItem(tasks.length - 1);
        }
        _saveTasks();
      });
    }
  }

  //削除ボタンが押されたらindexのタスクを削除
  void removeTask(int index, bool isCompleted) {
    if (isCompleted) {
      if (index < 0 || index >= completedTasks.length) return;
      final removedTask = completedTasks[index];
      completedListKey.currentState?.removeItem(
        index,
        (context, animation) => buildItem(removedTask, animation, true),
        duration: const Duration(milliseconds: 300),
      );
      setState(() {
        completedTasks.removeAt(index); // タスクリストから削除
        _saveTasks(); // 削除後に保存
      });
    } else {
      if (index < 0 || index >= tasks.length) return;
      final removedTask = tasks[index];
      incompleteListKey.currentState?.removeItem(
        index,
        (context, animation) => buildItem(removedTask, animation, false),
        duration: const Duration(milliseconds: 300),
      );
      setState(() {
        tasks.removeAt(index);
        _saveTasks();
      });
    }
  }

  //タスク削除時のアニメーション
  Widget buildItem(Task task, Animation<double> animation, bool isCompleted) {
    return FadeTransition(
      //アニメーションに応じて透明度を変化
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation, //アニメーションに応じて大きさも変化
        child:
            buildTaskContent(task, animation, isCompleted), //SizeTransitionの対象
      ),
    );
  }

  //タスクごとのカードの中身を作成
  Widget buildTaskContent(
      Task task, Animation<double> animation, bool isCompleted) {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(task
        .dueDate); //format メソッドが指定した日時オブジェクト (task['dueDate']) を上記のフォーマットに基づいて文字列に変換

    //タスクカードを表示させるときのアニメーション
    return Card(
      //アニメーションの対象がchildに指定されている
      color:
          isCompleted ? Colors.grey[800] : Colors.black, //タスク完了時はグレー、未完了時は黒背景
      margin: const EdgeInsets.symmetric(vertical: 12), //カード間の上下距離
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), //カードの角を丸めた
      ),
      elevation: 4, //カードの影
      child: Container(
        //カード内部の配置
        padding: const EdgeInsets.all(24), //カード内側にも余白
        child: Row(
          //タスクのチェックアイコン、テキスト、編集ボタン、削除ボタン
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  if (!isCompleted) {
                    markTaskAsCompleted(tasks.indexOf(task), false);
                  } else {
                    markTaskAsCompleted(completedTasks.indexOf(task), true);
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
                    task.name,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "締切:$formattedDate",
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
                    final Task? updatedTask = await Navigator.push<Task>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTaskPage(
                          initialTask: task.name,
                          initialDueDate: task.dueDate,
                        ),
                      ),
                    );

                    if (updatedTask != null) {
                      setState(() {
                        task.name = updatedTask.name;
                        task.dueDate = updatedTask.dueDate;
                        _saveTasks(); // 編集後に保存
                      });
                    }
                  },
                  icon: const Icon(Icons.edit, color: Colors.blue),
                ),
                IconButton(
                  onPressed: () {
                    print("Delete button clicked for task: ${task.name}");
                    if (isCompleted) {
                      removeTask(completedTasks.indexOf(task), isCompleted);
                    } else {
                      removeTask(tasks.indexOf(task), isCompleted);
                    }
                  },
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
                    colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
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
    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
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
          bottom: TabBar(
            controller: _tabController, // カスタムコントローラ
            tabs: [
              Tab(text: "未完了のタスク"),
              Tab(text: "完了済みタスク"),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
          ),
        ),
        body: TabBarView(
          controller: _tabController, // カスタムコントローラ
          children: [
            AnimatedList(
              key: incompleteListKey,
              padding: const EdgeInsets.all(8),
              initialItemCount: tasks.length,
              itemBuilder: (context, index, animation) {
                return buildItem(tasks[index], animation, false);
              },
            ),
            AnimatedList(
              key: completedListKey,
              padding: const EdgeInsets.all(8),
              initialItemCount: completedTasks.length,
              itemBuilder: (context, index, animation) {
                return buildItem(completedTasks[index], animation, true);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final Task? newTask = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTaskPage()),
            );
            if (newTask != null) {
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
