// main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
// ADDED: Imports for PDF creation and printing.
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// --- Configuration ---
const String supabaseUrl = '';
const String supabaseAnonKey = '';

// --- Data Models ---
class Shelf {
  final int id;
  final String name;
  final String? description;
  Shelf({required this.id, required this.name, this.description});
  factory Shelf.fromMap(Map<String, dynamic> map) => Shelf(
    id: map['id'],
    name: map['name'],
    description: map['location_description'],
  );
}

class Item {
  final int id;
  final String name;
  final String? details;
  final double price;
  final int quantity;
  final int? shelfId;
  Item({
    required this.id,
    required this.name,
    this.details,
    required this.price,
    required this.quantity,
    this.shelfId,
  });
  factory Item.fromMap(Map<String, dynamic> map) => Item(
    id: map['id'],
    name: map['name'],
    details: map['details'],
    price: (map['price'] as num).toDouble(),
    quantity: map['quantity'],
    shelfId: map['shelf_id'],
  );
}

// A helper class to hold the initial data load.
class InitialData {
  final List<Shelf> shelves;
  final List<Item> items;
  InitialData({required this.shelves, required this.items});
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const InventoryWebApp());
}

final supabase = Supabase.instance.client;

// --- App Theme and Styling ---
class AppColors {
  static const Color background = Color(0xFFF8F9FA);
  static const Color primary = Color(0xFF4A90E2);
  static const Color heading = Color(0xFF343A40);
  static const Color body = Color(0xFF495057);
  static const Color card = Colors.white;
  static const Color error = Color(0xFFE63946);
  static const Color subtleIcon = Color(0xFFADB5BD);
  static const Color subtleBorder = Color(0xFFDEE2E6);
  static const Color selected = Color(0xFFE9F2FC);
}

class InventoryWebApp extends StatelessWidget {
  const InventoryWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        dialogTheme: DialogTheme(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

// --- Main Layout (Master-Detail) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedShelfId;
  String _selectedShelfName = 'All Items';

  late final Future<InitialData> _initialDataFuture;

  @override
  void initState() {
    super.initState();
    _initialDataFuture = _fetchInitialData();
  }

  Future<InitialData> _fetchInitialData() async {
    debugPrint("Fetching initial data...");
    try {
      final shelvesFuture = supabase.from('shelves').select();
      final itemsFuture = supabase.from('items').select();

      final results = await Future.wait([shelvesFuture, itemsFuture]);

      final shelfData = results[0] as List?;
      final itemData = results[1] as List?;

      final shelves =
          (shelfData ?? []).map((map) => Shelf.fromMap(map)).toList();
      shelves.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      final items = (itemData ?? []).map((map) => Item.fromMap(map)).toList();

      debugPrint(
        "Successfully fetched ${shelves.length} shelves and ${items.length} items.",
      );
      return InitialData(shelves: shelves, items: items);
    } catch (e) {
      debugPrint("--- FATAL ERROR fetching initial data ---");
      debugPrint(e.toString());
      throw Exception(
        "Could not connect to the database. Please check your connection and Supabase credentials.",
      );
    }
  }

  void _onShelfSelected(int? shelfId, String shelfName) {
    setState(() {
      _selectedShelfId = shelfId;
      _selectedShelfName = shelfName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1600),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Inventory Portal',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<InitialData>(
                  future: _initialDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Fatal Error: ${snapshot.error}",
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 18,
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: Text("No data found."));
                    }

                    final allShelves = snapshot.data!.shelves;
                    final allItems = snapshot.data!.items;

                    return MainContent(
                      allShelves: allShelves,
                      allItems: allItems,
                      selectedShelfId: _selectedShelfId,
                      selectedShelfName: _selectedShelfName,
                      onShelfSelected: _onShelfSelected,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Main Content Widget (Handles Live Updates) ---
class MainContent extends StatefulWidget {
  final List<Shelf> allShelves;
  final List<Item> allItems;
  final int? selectedShelfId;
  final String selectedShelfName;
  final void Function(int?, String) onShelfSelected;

  const MainContent({
    super.key,
    required this.allShelves,
    required this.allItems,
    required this.selectedShelfId,
    required this.selectedShelfName,
    required this.onShelfSelected,
  });

  @override
  _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  late List<Shelf> _currentShelves;
  late List<Item> _currentItems;
  StreamSubscription? _shelfSubscription;
  StreamSubscription? _itemSubscription;

  @override
  void initState() {
    super.initState();
    _currentShelves = widget.allShelves;
    _currentItems = widget.allItems;
    _setupListeners();
  }

  void _setupListeners() {
    debugPrint("Setting up real-time listeners...");
    // Shelf listener
    _shelfSubscription = supabase
        .from('shelves')
        .stream(primaryKey: ['id'])
        .listen((data) {
          debugPrint("Shelf data updated via stream.");
          final shelves =
              (data ?? []).map((map) => Shelf.fromMap(map)).toList();
          shelves.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
          setState(() {
            _currentShelves = shelves;
          });
        });
    // Item listener
    _itemSubscription = supabase
        .from('items')
        .stream(primaryKey: ['id'])
        .listen((data) {
          debugPrint("Item data updated via stream.");
          final items = (data ?? []).map((map) => Item.fromMap(map)).toList();
          setState(() {
            _currentItems = items;
          });
        });
  }

  @override
  void dispose() {
    _shelfSubscription?.cancel();
    _itemSubscription?.cancel();
    debugPrint("Real-time listeners cancelled.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems =
        widget.selectedShelfId == null
            ? _currentItems
            : _currentItems
                .where((item) => item.shelfId == widget.selectedShelfId)
                .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 300,
          child: ShelfNavigationColumn(
            allShelves: _currentShelves,
            selectedShelfId: widget.selectedShelfId,
            onShelfSelected: widget.onShelfSelected,
          ),
        ),
        const VerticalDivider(width: 25, thickness: 1),
        Expanded(
          child: ItemDisplayColumn(
            key: ValueKey(widget.selectedShelfId),
            allShelves: _currentShelves,
            filteredItems: filteredItems,
            selectedShelfId: widget.selectedShelfId,
            selectedShelfName: widget.selectedShelfName,
          ),
        ),
      ],
    );
  }
}

// --- Left Column: Shelf Navigation ---
class ShelfNavigationColumn extends StatelessWidget {
  final List<Shelf> allShelves;
  final int? selectedShelfId;
  final Function(int?, String) onShelfSelected;

  const ShelfNavigationColumn({
    super.key,
    required this.allShelves,
    required this.selectedShelfId,
    required this.onShelfSelected,
  });

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  Future<void> _showShelfDialog(BuildContext context, {Shelf? shelf}) async {
    final nameController = TextEditingController(text: shelf?.name);
    final descController = TextEditingController(text: shelf?.description);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(shelf == null ? 'Add New Shelf' : 'Edit Shelf'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Shelf Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                debugPrint("Attempting to save shelf: $name");
                try {
                  if (shelf == null) {
                    await supabase.from('shelves').insert([
                      {
                        'name': name,
                        'location_description': descController.text.trim(),
                      },
                    ]);
                    debugPrint("Successfully inserted new shelf.");
                  } else {
                    await supabase
                        .from('shelves')
                        .update({
                          'name': name,
                          'location_description': descController.text.trim(),
                        })
                        .match({'id': shelf.id});
                    debugPrint("Successfully updated shelf ID: ${shelf.id}.");
                  }
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                } catch (e) {
                  debugPrint("--- ERROR SAVING SHELF ---: ${e.toString()}");
                  _showErrorSnackBar(
                    dialogContext,
                    'Failed to save shelf: ${e.toString()}',
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Shelves',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.heading,
              ),
            ),
            IconButton(
              onPressed: () => _showShelfDialog(context),
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add New Shelf',
              color: AppColors.primary,
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                title: const Text(
                  'All Items',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                selected: selectedShelfId == null,
                selectedTileColor: AppColors.selected,
                onTap: () => onShelfSelected(null, 'All Items'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              ...allShelves.map(
                (shelf) => ListTile(
                  title: Text(shelf.name),
                  selected: selectedShelfId == shelf.id,
                  selectedTileColor: AppColors.selected,
                  onTap: () => onShelfSelected(shelf.id, shelf.name),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.subtleIcon,
                    ),
                    onPressed: () => _showShelfDialog(context, shelf: shelf),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Right Column: Item Display and Management ---
class ItemDisplayColumn extends StatelessWidget {
  final List<Shelf> allShelves;
  final List<Item> filteredItems;
  final int? selectedShelfId;
  final String selectedShelfName;

  const ItemDisplayColumn({
    super.key,
    required this.allShelves,
    required this.filteredItems,
    required this.selectedShelfId,
    required this.selectedShelfName,
  });

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  Future<void> _showItemDialog(BuildContext context, {Item? item}) async {
    final nameController = TextEditingController(text: item?.name);
    final detailsController = TextEditingController(text: item?.details);
    final priceController = TextEditingController(text: item?.price.toString());
    final quantityController = TextEditingController(
      text: item?.quantity.toString(),
    );

    int? selectedShelfIdForDialog = selectedShelfId ?? item?.shelfId;

    await showDialog(
      context: context,
      builder:
          (dialogContext) => ItemDialog(
            item: item,
            allShelves: allShelves,
            initialShelfId: selectedShelfIdForDialog,
            nameController: nameController,
            detailsController: detailsController,
            priceController: priceController,
            quantityController: quantityController,
            onError: (error) => _showErrorSnackBar(dialogContext, error),
          ),
    );
  }

  void _showQrCodeDialog(BuildContext context, Item item) {
    // FIX: Find the shelf name from the complete list.
    final shelfName =
        allShelves
            .firstWhere(
              (shelf) => shelf.id == item.shelfId,
              orElse: () => Shelf(id: -1, name: 'N/A'),
            )
            .name;

    final qrData =
        'ItemID: ${item.id}\nName: ${item.name}\nPrice: ${item.price.toStringAsFixed(2)}\nShelf: $shelfName';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item.name),
          content: SizedBox(
            width: 250,
            height: 250,
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.print_outlined),
              label: const Text('Print Label'),
              onPressed: () {
                _printQrCodeLabel(item, qrData, shelfName);
              },
            ),
          ],
        );
      },
    );
  }

  // FIX: Accept the shelfName to print on the label.
  Future<void> _printQrCodeLabel(
    Item item,
    String qrData,
    String shelfName,
  ) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  item.name,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                pw.SizedBox(height: 5),
                // FIX: Display the shelf name on the label.
                pw.Text(
                  'Shelf: $shelfName',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: qrData,
                    width: 150,
                    height: 150,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    'Item ID: ${item.id}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedShelfName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.heading,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showItemDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const Divider(height: 25),
        Expanded(
          child:
              filteredItems.isEmpty
                  ? Center(
                    child: Text(
                      'No items on this shelf.',
                      style: const TextStyle(
                        color: AppColors.body,
                        fontSize: 16,
                      ),
                    ),
                  )
                  : ListView.separated(
                    itemCount: filteredItems.length,
                    separatorBuilder:
                        (context, index) => const Divider(
                          height: 1,
                          color: AppColors.subtleBorder,
                        ),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 8.0,
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Price: ${item.price}  |  Quantity: ${item.quantity}',
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.qr_code_scanner,
                                color: AppColors.subtleIcon,
                              ),
                              onPressed: () => _showQrCodeDialog(context, item),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.subtleIcon,
                              ),
                              onPressed:
                                  () => _showItemDialog(context, item: item),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () async {
                                try {
                                  await supabase.from('items').delete().match({
                                    'id': item.id,
                                  });
                                } catch (e) {
                                  _showErrorSnackBar(
                                    context,
                                    'Failed to delete item: ${e.toString()}',
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

// --- Item Creation/Editing Dialog ---
class ItemDialog extends StatefulWidget {
  final Item? item;
  final List<Shelf> allShelves;
  final int? initialShelfId;
  final TextEditingController nameController;
  final TextEditingController detailsController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final Function(String) onError;

  const ItemDialog({
    super.key,
    this.item,
    required this.allShelves,
    required this.initialShelfId,
    required this.nameController,
    required this.detailsController,
    required this.priceController,
    required this.quantityController,
    required this.onError,
  });

  @override
  State<ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<ItemDialog> {
  int? _selectedShelfId;

  @override
  void initState() {
    super.initState();
    _selectedShelfId = widget.initialShelfId;
  }

  Future<void> _saveItem() async {
    final name = widget.nameController.text.trim();
    final price = double.tryParse(widget.priceController.text.trim());
    final quantity = int.tryParse(widget.quantityController.text.trim());

    if (name.isEmpty || price == null || quantity == null) {
      widget.onError('Please fill all required fields correctly.');
      return;
    }

    final itemData = {
      'name': name,
      'details': widget.detailsController.text.trim(),
      'price': price,
      'quantity': quantity,
      'shelf_id': _selectedShelfId,
    };

    debugPrint("Attempting to save item: $itemData");
    try {
      if (widget.item == null) {
        await supabase.from('items').insert([itemData]);
        debugPrint("Successfully inserted new item.");
      } else {
        await supabase.from('items').update(itemData).match({
          'id': widget.item!.id,
        });
        debugPrint("Successfully updated item ID: ${widget.item!.id}");
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint("--- ERROR SAVING ITEM ---: ${e.toString()}");
      widget.onError('Failed to save item: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Add New Item' : 'Edit Item'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widget.nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.detailsController,
                decoration: const InputDecoration(labelText: 'Details'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedShelfId,
                decoration: const InputDecoration(labelText: 'Assign to Shelf'),
                items:
                    widget.allShelves
                        .map(
                          (shelf) => DropdownMenuItem<int>(
                            value: shelf.id,
                            child: Text(shelf.name),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _selectedShelfId = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveItem, child: const Text('Save')),
      ],
    );
  }
}
