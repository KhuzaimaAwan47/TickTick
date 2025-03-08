import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../auth/database_helper.dart';
import '../model/task_model.dart';
import '../model/user_model.dart';
import '../theme/theme_manager.dart';

class HomePage extends StatefulWidget {
  final int usrId;

  const HomePage({super.key, required this.usrId});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime currentDate = DateTime.now();
  List<Task> _tasks = [];
  Users? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _fetchUserDetails();

  }


  // Function to fetch user details
  void _fetchUserDetails() async {
    try {
      Users? user = await DatabaseHelper().getUserById(widget.usrId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error appropriately
      setState(() {
        _isLoading = false;
      });
      print("Error fetching user details: $e");
    }
  }


  // Fetch tasks from the database
  void _fetchTasks() async {
    final tasks = await DatabaseHelper().getTask(widget.usrId);
    setState(() {
      _tasks = tasks;
    });
  }

  // Calendar navigation
  void _nextMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    });
  }

  void _previousMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month - 1);
    });
  }

  // Show a dialog for adding a new task or editing an existing task.
  Future<void> _showTaskDialog({required DateTime selectedDate, Task? taskToEdit}) async {
    final TextEditingController titleController = TextEditingController(text: taskToEdit?.title ?? '');
    final TextEditingController descController = TextEditingController(text: taskToEdit?.description ?? '');
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
            title: Text(taskToEdit == null ? 'Add Task' : 'Edit Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show the selected date in the dialog.
                Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",style: TextStyle(fontSize: 18),),
                SizedBox(height: 10,),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[700] // Dark theme fill color
                          : Colors.pink.shade50, // Light theme fill color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none
                      ),
                      labelText: 'Title'),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white // Dark theme text color
                        : Colors.black, // Light theme text color
                  ),
                ),
                SizedBox(height: 10,),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[700] // Dark theme fill color
                          : Colors.pink.shade50, // Light theme fill color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none
                      ),
                      labelText: 'Description'),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white // Dark theme text color
                        : Colors.black, // Light theme text color
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',style: TextStyle(color: Colors.red),)
              ),
              TextButton(
                  onPressed: () async {
                    final String title = titleController.text.trim();
                    final String description = descController.text.trim();
                    if(title.isNotEmpty){
                      if(taskToEdit == null){
                        // Create new task with a unique id (using current time)
                        final newTask = Task(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          usrId: widget.usrId,
                          title: title,
                          date: DateFormat('yyyy-MM-dd').format(selectedDate),
                          description: description,
                        );
                        await DatabaseHelper().insertTask(newTask);
                      } else {
                        // Update existing task
                        final updatedTask = Task(
                          id: taskToEdit.id,
                          usrId: widget.usrId,
                          title: title,
                          date: DateFormat('yyyy-MM-dd').format(selectedDate),
                          description: description,
                        );
                        await DatabaseHelper().updateTask(updatedTask);
                      }
                      _fetchTasks();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(taskToEdit == null ? 'Save' : 'Update',style: TextStyle(color: Colors.green),)
              ),
            ],
          );
        }
    );
  }

  // Delete a task by id
  void _deleteTask(String taskId) async {
    // Show confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // If user confirms, delete the task
    if (confirm == true) {
      await DatabaseHelper().removeTask(taskId);
      _fetchTasks();
    }
  }


  // show task detail
  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
        title: Text(task.title,style: TextStyle(fontSize: 20,),textAlign: TextAlign.center,),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: ${task.date}"),
            SizedBox(height: 8),
            Text("Description:"),
            Text(task.description,style: TextStyle(color: Colors.grey),),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          )
        ],
      ),
    );
  }

  // Separate tasks based on date
  List<Task> get upcomingTasks {
    DateTime today = DateTime.now();
    return _tasks.where((task) {
      DateTime taskDate = DateTime.parse(task.date);
      // Consider tasks on today as upcoming as well.
      return !taskDate.isBefore(DateTime(today.year, today.month, today.day));
    }).toList();
  }

  List<Task> get previousTasks {
    DateTime today = DateTime.now();
    return _tasks.where((task) {
      DateTime taskDate = DateTime.parse(task.date);
      return taskDate.isBefore(DateTime(today.year, today.month, today.day));
    }).toList();
  }

  // Helper to check if a given date has any tasks
  bool _hasTaskForDate(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return _tasks.any((task) => task.date == formattedDate);
  }


  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final taskColor = currentTheme.brightness == Brightness.dark ? Colors.green.shade700 : Colors.greenAccent;
    final textColor = currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final cardColor = currentTheme.brightness == Brightness.dark ? Colors.grey[800] : Colors.pink.shade50;
    final todayColor = currentTheme.brightness == Brightness.dark ? Color(0xFF660066) : Colors.pink;
    final bannerColor = currentTheme.brightness == Brightness.dark ? Colors.grey[700] : Colors.pink.shade100;
    final backgroundColor = currentTheme.scaffoldBackgroundColor;
    final daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1).weekday;
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('TickTick'),
        actions: [
          PopupMenuButton<String>(
            color: currentTheme.brightness == Brightness.dark ? Colors.grey[850] : Colors.white,
            onSelected: (value) {
              if (value == 'item1') {
                Provider.of<ThemeManager>(context, listen: false).toggleTheme();
              } else if (value == 'item2') {
                Navigator.pop(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'item1',
                  child: Row(
                    children: [
                      Icon(Icons.brightness_6, color: textColor),
                      SizedBox(width: 10),
                      Text('Change Theme', style: TextStyle(color: textColor)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'item2',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: textColor),
                      SizedBox(width: 10),
                      Text('Sign out', style: TextStyle(color: textColor)),
                    ],
                  ),
                ),
              ];
            },
            offset: Offset(0, kToolbarHeight),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //Text("Hi ${_user!.fullName ?? "null"}",style: currentTheme.textTheme.headlineLarge,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Hi, ',style: currentTheme.textTheme.headlineLarge,),
                Text(
                  _user?.fullName ?? "null",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700, // Increased weight for better visibility
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          Color(0xFF00BFFF), // Bright azure
                          Color(0xFF00FFFF), // Cyan (midpoint)
                          Color(0xFFFFD700), // Gold (midpoint)
                          Color(0xFFFF4500), // Orange-red
                        ],
                        stops: [0.0, 0.3, 0.7, 1.0], // Smooth color distribution
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight, // Diagonal for dynamic look
                        tileMode: TileMode.clamp,
                      ).createShader(
                        Rect.fromLTWH(0, 0, 300, 50), // Adjust based on typical text width
                      )
                      ..strokeWidth = 1.5 // Optional text stroke
                      ..strokeJoin = StrokeJoin.round
                      ..style = PaintingStyle.fill,
                  )
                )
              ],
            ),

            // List of tasks: Upcoming and Previous events
            Expanded(
              child: ListView(
                children: [
                  // Upcoming Events header
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: bannerColor,
                    ),
                    width: double.infinity,
                    height: 30,
                    child: Center(
                      child: Text(
                        'Upcoming Events',
                        style: currentTheme.textTheme.bodyMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Upcoming tasks
                  ...upcomingTasks.map((task) => Card(
                    color: currentTheme.brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                    child: ListTile(
                      onTap: () => _showTaskDetails(task),
                      title: Text(task.title),
                      subtitle: Text(task.date),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: textColor),
                            onPressed: () {
                              // Launch edit dialog using the task's date.
                              DateTime taskDate = DateTime.parse(task.date);
                              _showTaskDialog(selectedDate: taskDate, taskToEdit: task);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteTask(task.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  )),
                  SizedBox(height: 20),
                  // Previous Events header
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: bannerColor,
                    ),
                    width: double.infinity,
                    height: 30,
                    child: Center(
                      child: Text(
                        'Previous Events',
                        style: currentTheme.textTheme.bodyMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Previous tasks
                  ...previousTasks.map((task) => Card(
                    color: currentTheme.brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                    child: ListTile(
                      onTap: () => _showTaskDetails(task),
                      title: Text(task.title),
                      subtitle: Text(task.date),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: textColor),
                            onPressed: () {
                              DateTime taskDate = DateTime.parse(task.date);
                              _showTaskDialog(selectedDate: taskDate, taskToEdit: task);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteTask(task.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
            // Calendar Header & Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Icon(Icons.arrow_back_outlined), onPressed: _previousMonth),
                Text(
                  '${DateFormat.MMMM().format(currentDate)} ${currentDate.year}',
                  style: currentTheme.textTheme.headlineLarge,
                ),
                IconButton(icon: Icon(Icons.arrow_forward), onPressed: _nextMonth),
              ],
            ),
            // Days of week header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((day) => Expanded(child: Center(child: Text(day, style: currentTheme.textTheme.headlineSmall?.copyWith(color: textColor)))))
                  .toList(),
            ),
            // Calendar Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                itemCount: daysInMonth + firstDayOfMonth - 1,
                itemBuilder: (context, index) {
                  if (index < firstDayOfMonth - 1) {
                    return SizedBox(); // Empty cells before the first day
                  }
                  final day = index - firstDayOfMonth + 2;
                  final date = DateTime(currentDate.year, currentDate.month, day);

                  // If a task exists for the date, change the cell color.
                  final bool hasTask = _hasTaskForDate(date);
                  final Color cellColor = (date.year == today.year && date.month == today.month && date.day == today.day)
                      ? todayColor
                      : hasTask
                      ? taskColor // show a different color if a task is scheduled
                      : cardColor!;

                  return GestureDetector(
                    onTap: () {
                      // Open dialog to add a task for the selected date.
                      _showTaskDialog(selectedDate: date);
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: (date.year == today.year && date.month == today.month && date.day == today.day)
                                ? Colors.white
                                : textColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}