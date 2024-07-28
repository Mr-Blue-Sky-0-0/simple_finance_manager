import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox('config');
  await Hive.openBox('spent');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Welcome Mr Blue Sky"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConfigScreen(),
                    ));
              },
              icon: const Icon(
                Icons.settings,
              ))
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'You have 200 000 left to spend',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => const SpendBottomSheet(),
          );
        },
        tooltip: 'spend',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SpendBottomSheet extends StatefulWidget {
  const SpendBottomSheet({super.key});

  @override
  State<SpendBottomSheet> createState() => _SpendBottomSheetState();
}

class _SpendBottomSheetState extends State<SpendBottomSheet> {
  final spent = Hive.box('spent');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          const Column(
            children: [
              Text(
                "What did you spend",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "better not be some useless shit",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          DropdownMenu(
              width: 300,
              initialSelection: 0,
              dropdownMenuEntries: List<DropdownMenuEntry>.generate(
                Data.spendTypes.length,
                (index) => DropdownMenuEntry(
                    value: index, label: Data.spendTypes[index]),
              )),
          SizedBox(
            width: 300,
            child: TextField(
              autofocus: true,
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: const InputDecoration(label: Text("Amount Spent")),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {},
            ),
          ),
          ElevatedButton(onPressed: () {}, child: const Text("SUBMIT"))
        ]),
      ),
    );
  }
}

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final box = Hive.box('config');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("config"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          Data.spendTypes.length,
          (index) {
            int value = 0;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "${Data.spendTypes[index]} limit",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 4,
                        child: TextField(
                          onTapOutside: (event) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          decoration: InputDecoration(
                              label: Text(box.get(index).toString())),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (v) {
                            value = int.tryParse(v) ?? 0;
                          },
                        ),
                      ),
                      Expanded(
                          flex: 3,
                          child: TextButton(
                              onPressed: () async {
                                await box.put(index, value);
                                setState(() {});
                              },
                              child: const Text("Confirm")))
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class Data {
  static final spendTypes = [
    "hanging out with friends",
    "fuel",
    "lunch at work",
    "is for me 🙄",
    "other"
  ];
}
