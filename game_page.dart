import 'dart:math';
import 'package:flutter/material.dart';
import 'package:miningsim/login_page.dart';
import 'database_helper.dart';

class GamePage extends StatelessWidget {
  final int userId;

  GamePage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image:
          AssetImage("assets/images/pixelBg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Text('Welcome to', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white)),

              new Image.asset(
                'assets/images/title.png',
                width: 500.0,
                height: 150.0,
                fit: BoxFit.cover,
              ),
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

    // Load user information
    final user = await db.getUserById(widget.userId);

    // Load progress information
    final progress = await db.getProgressByUserId(widget.userId);

    if (user != null) {
      setState(() {
        // Set user details
        username = user['username'];
        email = user['email'];
        password = user['password'];
      });
    }

    if (progress != null) {
      setState(() {
        // Set progress details
        gold = progress['gold'];
        inventory = Map<String, int>.fromEntries(
          (progress['inventory'] as String)
              .split(',')
              .where((item) => item.contains(':'))
              .map((item) {
            final parts = item.split(':');
            return MapEntry(parts[0], int.parse(parts[1]));
          }),
        );
        toolInventory = progress['tools'].isNotEmpty ? progress['tools'].split(',') : ['Wooden Pickaxe'];
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
                  controller: TextEditingController.fromValue(
                    TextEditingValue(text: email),
                  ),
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
        Random random = Random();
        // 10% chance to spawn obsidian
        bool randStone = random.nextInt(100) < 30;
        blockHp = randStone ? 250 : 100;
        bool randStone2 = random.nextInt(100) < 20;
        blockHp = randStone2 ? 300 : 100;
        bool randStone3 = random.nextInt(100) < 10;
        blockHp = randStone3 ? 400 : 100;
      }
    });
    _saveProgress();
  }

  String getStoneImage() {
    if (blockHp > 80) return 'assets/images/Stone.png';
    if (blockHp > 50) return 'assets/images/Stone_phase2.png';
    if (blockHp > 10) return 'assets/images/Stone_phase3.png';
    return 'assets/images/Stone_phase4.png';
  }



  void generateOre() {
    Random random = Random();
    int chance = random.nextInt(100);

    String ore = chance > 90
        ? 'Diamond'
        : chance > 70
        ? 'Gold'
        : 'Iron';

    inventory[ore] = (inventory[ore] ?? 0) + 1;
    minedOre = ore;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You mined: $ore!')),
    );
  }

  Future<void> _saveProgress() async {
    final rowsAffected = await DatabaseHelper.instance.updateProgress(widget.userId, {
      'gold': gold,
      'inventory': inventory.entries.map((e) => '${e.key}:${e.value}').join(','),
      'tools': toolInventory.join(','),
    });
    print('Progress saved: $rowsAffected rows affected.');
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
                String toolImage;
                int toolValue;
                switch (tool) {
                  case 'Golden Pickaxe':
                    toolImage = 'assets/images/goldenpick.png';
                    toolValue = 200;
                    break;
                  case 'Diamond Pickaxe':
                    toolImage = 'assets/images/diamondpick.png';
                    toolValue = 500;
                    break;
                  case 'Stone Pickaxe':
                    toolImage = 'assets/images/stonepick.png';
                    toolValue = 50;
                    break;
                  case 'Iron Pickaxe':
                    toolImage = 'assets/images/ironpick.png';
                    toolValue = 100;
                    break;
                  default:
                    toolImage = 'assets/images/woodenpickaxe.png';
                    toolValue = 0;
                }
                return ListTile(
                  leading: toolImage.isNotEmpty
                      ? Image.asset(toolImage, width: 40, height: 40)
                      : null,
                  title: Text(tool),
                  onTap: () {
                    selectPickaxe(tool); // Select the pickaxe
                    Navigator.pop(context); // Close the modal
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: $tool!')),
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.sell, color: Colors.red),
                    onPressed: () => _sellPickaxe(tool, toolValue),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }


  void _sellPickaxe(String tool, int toolValue) {
    setState(() {
      if (toolInventory.contains(tool)) {
        gold += toolValue;
        toolInventory.remove(tool);
        _saveProgress();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sold $tool for $toolValue gold!')),
        );
      }
    });
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
                String oreImage;
                int oreValue;
                switch (entry.key) {
                  case 'Diamond':
                    oreImage = 'assets/images/diamond_ore.png';
                    oreValue = 50;
                    break;
                  case 'Gold':
                    oreImage = 'assets/images/gold_ore.png';
                    oreValue = 20;
                    break;
                  case 'Iron':
                    oreImage = 'assets/images/iron_ore.png';
                    oreValue = 5;
                    break;
                  default:
                    oreImage = '';
                    oreValue = 0;
                }
                return ListTile(
                  leading: oreImage.isNotEmpty
                      ? Image.asset(oreImage, width: 40, height: 40)
                      : null,
                  title: Text('${entry.key} x${entry.value}'),
                  trailing: IconButton(
                    icon: Icon(Icons.sell, color: Colors.red),
                    onPressed: () => _sellOre(entry.key, oreValue),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  void _sellOre(String ore, int oreValue) {
    setState(() {
      if (inventory[ore] != null && inventory[ore]! > 0) {
        gold += oreValue;
        inventory[ore] = inventory[ore]! - 1;
        if (inventory[ore] == 0) inventory.remove(ore);
        _saveProgress();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sold $ore for $oreValue gold coins!')),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/goldcoin.png',
                  width: 30,
                  height: 30,
                ),
                SizedBox(width: 5),
                Text(
                  '$gold',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
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
              leading: Image.asset('assets/images/tools.png', width: 60, height: 60),
              title: Text("Tools", style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white,)),
              onTap: () {
                Navigator.pop(context);
                _showToolsModal(context);
              },
            ),
            ListTile(
              leading: Image.asset('assets/images/inventory.png', width: 60, height: 60),
              title: Text("Inventory", style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white,)),
              onTap: () {
                Navigator.pop(context);
                _showInventoryModal(context);
              },
            ),
            ListTile(
              leading: Image.asset('assets/images/settings.png', width: 60, height: 60),
              title: Text("Settings", style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white,)),
              onTap: () {
                Navigator.pop(context);
                openSettingsDialog();
              },
            ),
            ListTile(
              leading: Image.asset('assets/images/logout.png', width: 60, height: 60),
              title: Text('LOG OUT', style: TextStyle(
                fontWeight: FontWeight.w800,color: Colors.white,
              ),),
              onTap: (){
                Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage(),
                    ),
                    );

              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image:
          AssetImage("assets/images/pixelG.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Stone Durability: $blockHp', style: TextStyle(fontWeight: FontWeight.w700,fontSize: 18,color: Colors.white),),
              SizedBox(height: 20),
              GestureDetector(
                onTap: mineBlock,
                child: Image.asset(
                  getStoneImage(),
                  width: 500,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              Text('Current Pickaxe: $currentPickaxe', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18,color: Colors.white),),
              SizedBox(height: 20),
              Text('GAMBLE FOR PICKAXE', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),),
              GestureDetector(
                onTap: gambleForPickaxe,
                child: Image.asset(
                'assets/images/gambling.png',
                width: 200,
                height: 80,
                fit: BoxFit.contain,
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
