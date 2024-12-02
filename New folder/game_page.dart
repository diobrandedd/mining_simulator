import 'dart:math';
import 'package:flutter/material.dart';
import 'database_helper.dart';

class GamePage extends StatelessWidget {
  final int userId;

  GamePage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Text('Welcome to', style: TextStyle(fontSize: 30)),
            Text('MINING SIM', style: TextStyle(fontSize: 60)),
            SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => MiningGame(userId: userId),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/startB.png',
                width: 200,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiningGame extends StatefulWidget {
  final int userId;

  MiningGame({required this.userId});

  @override
  _MiningGameState createState() => _MiningGameState();
}

class _MiningGameState extends State<MiningGame> {
  late String username = '';
  late String email = '';
  late String password = '';

  int blockHp = 100;
  int gold = 0;
  Map<String, int> inventory = {};
  String minedOre = '';
  String currentPickaxe = 'Wooden Pickaxe';
  Map<String, int> pickaxeEfficiency = {
    'Wooden Pickaxe': 10,
    'Stone Pickaxe': 20,
    'Golden Pickaxe': 30,
    'Diamond Pickaxe': 50,
  };
  List<String> toolInventory = ['Wooden Pickaxe'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final db = DatabaseHelper.instance;
    final user = await db.getUserById(widget.userId);
    if (user != null) {
      setState(() {
        username = user['username'];
        email = user['email'];
        password = user['password'];
      });
    }
  }

  Future<void> _updateUserData(String newUsername, String newPassword) async {
    final db = DatabaseHelper.instance;
    await db.updateUser(widget.userId, {
      'username': newUsername,
      'password': newPassword,
    });
    await _loadUserData(); // Refresh local state
  }

  void openSettingsDialog() {
    TextEditingController usernameController = TextEditingController(text: username);
    TextEditingController passwordController = TextEditingController(text: password);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: "Username"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                TextField(
                  controller: TextEditingController(text: email),
                  decoration: InputDecoration(labelText: "Email (non-editable)"),
                  readOnly: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateUserData(
                  usernameController.text,
                  passwordController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void mineBlock() {
    setState(() {
      blockHp -= pickaxeEfficiency[currentPickaxe]!;
      if (blockHp <= 0) {
        generateOre();
        blockHp = 100;
      }
    });
  }

  void generateOre() {
    Random random = Random();
    int chance = random.nextInt(100);

    String ore = chance > 90
        ? 'Diamond'
        : chance > 70
        ? 'Gold'
        : 'Iron';

    int oreValue = ore == 'Diamond'
        ? 50
        : ore == 'Gold'
        ? 20
        : 5;

    inventory[ore] = (inventory[ore] ?? 0) + 1;
    gold += oreValue;
    minedOre = ore;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You mined: $ore!')),
    );
  }

  void gambleForPickaxe() {
    if (gold < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough gold!')),
      );
      return;
    }

    setState(() {
      gold -= 100;

      List<String> pickaxes = [
        'Stone Pickaxe',
        'Golden Pickaxe',
        'Diamond Pickaxe'
      ];

      String newPickaxe = pickaxes[Random().nextInt(pickaxes.length)];
      toolInventory.add(newPickaxe);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You got: $newPickaxe!')),
      );
    });
  }

  void selectPickaxe(String pickaxe) {
    setState(() {
      currentPickaxe = pickaxe;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected: $pickaxe!')),
      );
    });
  }

  void _showToolsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Tools",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),
            toolInventory.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("No tools available"),
            )
                : Column(
              children: toolInventory.map((tool) {
                return ListTile(
                  title: Text(tool),
                  onTap: () {
                    selectPickaxe(tool);
                    Navigator.pop(context); // Close modal
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  void _showInventoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Inventory",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),
            inventory.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Inventory is empty"),
            )
                : Column(
              children: inventory.entries.map((entry) {
                return ListTile(
                  title: Text('${entry.key} x${entry.value}'),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer(); // Open the drawer manually
              },
              child: Image.asset(
                'assets/images/drawer.png',
                width: 30,
                height: 30,
              ),
            );
          },
        ),
        title: Text('Mining Simulator'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text('Gold: $gold'),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.black12,
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blueGrey,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'P',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    username,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("Tools", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showToolsModal(context);
              },
            ),
            ListTile(
              title: Text("Inventory", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showInventoryModal(context);
              },
            ),
            ListTile(
              leading: Image.asset('assets/images/settings.png', width: 60, height: 60),
              title: Text("Settings", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                openSettingsDialog();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Block HP: $blockHp'),
            SizedBox(height: 20),
            GestureDetector(
              onTap: mineBlock,
              child: Image.asset(
                'assets/images/block.png',
                width: 150,
                height: 150,
              ),
            ),
            SizedBox(height: 20),
            Text('Current Pickaxe: $currentPickaxe'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: gambleForPickaxe,
              child: Text('Gamble for Pickaxe (100 Gold)'),
            ),
          ],
        ),
      ),
    );
  }
}
