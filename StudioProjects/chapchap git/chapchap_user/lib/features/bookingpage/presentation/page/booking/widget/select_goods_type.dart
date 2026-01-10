// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/booking_bloc.dart';

class SelectGoodsType extends StatefulWidget {
  final BuildContext cont;
  const SelectGoodsType({super.key, required this.cont});

  @override
  State<SelectGoodsType> createState() => _SelectGoodsTypeState();
}

class _SelectGoodsTypeState extends State<SelectGoodsType> {
  int _quantity = 1;
  final TextEditingController _customTypeController = TextEditingController();

  // Types de colis prédéfinis avec emojis
  static const List<Map<String, dynamic>> _predefinedGoodsTypes = [
    {'id': 1, 'name': 'Documents', 'emoji': '📄'},
    {'id': 2, 'name': 'Vêtements', 'emoji': '👕'},
    {'id': 3, 'name': 'Électronique', 'emoji': '📱'},
    {'id': 4, 'name': 'Nourriture', 'emoji': '🍕'},
    {'id': 5, 'name': 'Médicaments', 'emoji': '💊'},
    {'id': 6, 'name': 'Colis', 'emoji': '📦'},
    {'id': 7, 'name': 'Autre', 'emoji': '✏️'},
  ];

  @override
  void initState() {
    super.initState();
    final qtyText = widget.cont.read<BookingBloc>().goodsQtyController.text;
    if (qtyText.isNotEmpty) {
      _quantity = int.tryParse(qtyText) ?? 1;
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
      widget.cont.read<BookingBloc>().goodsQtyController.text = _quantity.toString();
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        widget.cont.read<BookingBloc>().goodsQtyController.text = _quantity.toString();
      });
    }
  }

  @override
  void dispose() {
    _customTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).primaryColor;
    
    return BlocProvider.value(
      value: widget.cont.read<BookingBloc>(),
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          final isTypeSelected = context.read<BookingBloc>().selectedGoodsTypeId > 0;
          
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.close, color: Colors.grey.shade600),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('📦', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  MyText(
                    text: 'Type de colis',
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              centerTitle: false,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header instruction
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.list_alt, color: primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MyText(
                              text: 'Sélectionnez le type de colis à livrer',
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Grille de types de colis
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _predefinedGoodsTypes.length,
                      itemBuilder: (context, index) {
                        final type = _predefinedGoodsTypes[index];
                        final typeId = type['id'] as int;
                        final typeName = type['name'] as String;
                        final emoji = type['emoji'] as String;
                        final isSelected = context.read<BookingBloc>().selectedGoodsTypeId == typeId;
                        
                        return GestureDetector(
                          onTap: () {
                            context.read<BookingBloc>().selectedGoodsTypeId = typeId;
                            if (widget.cont.read<BookingBloc>().goodsQtyController.text.isEmpty) {
                              widget.cont.read<BookingBloc>().goodsQtyController.text = '1';
                              _quantity = 1;
                            }
                            context.read<BookingBloc>().add(UpdateEvent());
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? primaryColor.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? primaryColor
                                    : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ] : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: MyText(
                                    text: typeName,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected 
                                          ? primaryColor
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Section "Précisez le type de colis" - visible uniquement si "Autre" est sélectionné
                    if (context.read<BookingBloc>().selectedGoodsTypeId == 7) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('✏️', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                MyText(
                                  text: 'Précisez le type de colis',
                                  textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _customTypeController,
                              decoration: InputDecoration(
                                hintText: 'Ex: Matériel de bureau, Livres...',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Section Quantité - visible uniquement si un type est sélectionné
                    if (isTypeSelected) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primaryColor.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, color: primaryColor, size: 20),
                                const SizedBox(width: 8),
                                MyText(
                                  text: 'Quantité',
                                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Bouton -
                                GestureDetector(
                                  onTap: _decrementQuantity,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      color: _quantity > 1 ? Colors.grey.shade700 : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Affichage quantité
                                Container(
                                  width: 80,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: primaryColor.withOpacity(0.5)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _quantity.toString(),
                                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Bouton +
                                GestureDetector(
                                  onTap: _incrementQuantity,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    SizedBox(height: size.width * 0.1),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.1),
                    )
                  ],
                ),
                child: CustomButton(
                  width: size.width,
                  buttonColor: isTypeSelected
                      ? primaryColor
                      : Colors.grey.shade300,
                  buttonName: isTypeSelected
                      ? '✓ Confirmer'
                      : 'Sélectionnez un type',
                  onTap: () {
                    if (!isTypeSelected) {
                      showToast(message: 'Veuillez sélectionner un type de colis');
                      return;
                    }
                    // Validation pour "Autre" - le champ doit être rempli
                    if (context.read<BookingBloc>().selectedGoodsTypeId == 7 && 
                        _customTypeController.text.trim().isEmpty) {
                      showToast(message: 'Veuillez préciser le type de colis');
                      return;
                    }
                    widget.cont.read<BookingBloc>().goodsQtyController.text = _quantity.toString();
                    // Sauvegarder le type personnalisé si "Autre" est sélectionné
                    if (context.read<BookingBloc>().selectedGoodsTypeId == 7) {
                      widget.cont.read<BookingBloc>().customGoodsType = _customTypeController.text.trim();
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
