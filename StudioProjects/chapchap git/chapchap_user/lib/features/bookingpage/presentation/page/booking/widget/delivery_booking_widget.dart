// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_divider.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/booking_bloc.dart';
import 'bottom/select_payment_widget.dart';

class DeliveryBookingWidget extends StatelessWidget {
  final BuildContext cont;
  final dynamic eta;
  final BookingPageArguments arg;
  const DeliveryBookingWidget(
      {super.key, required this.cont, this.eta, required this.arg});

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

  String _getSelectedTypeName(int typeId) {
    final type = _predefinedGoodsTypes.firstWhere(
      (t) => t['id'] == typeId,
      orElse: () => {'name': 'Non sélectionné'},
    );
    return type['name'] as String;
  }

  String _getSelectedTypeEmoji(int typeId) {
    final type = _predefinedGoodsTypes.firstWhere(
      (t) => t['id'] == typeId,
      orElse: () => {'emoji': '📦'},
    );
    return type['emoji'] as String;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final primaryColor = Theme.of(context).primaryColor;
    
    return BlocProvider.value(
        value: cont.read<BookingBloc>(),
        child: BlocBuilder<BookingBloc, BookingState>(
          builder: (context, state) {
            final selectedGoodsTypeId = context.read<BookingBloc>().selectedGoodsTypeId;
            final goodsQty = context.read<BookingBloc>().goodsQtyController.text;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(-1, -2),
                      blurRadius: 10,
                      spreadRadius: 2,
                      color: Theme.of(context).splashColor)
                ],
              ),
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: size.width * 0.03),
                      const Center(child: CustomDivider()),
                      SizedBox(height: size.width * 0.04),
                      
                      // Titre simplifié
                      Row(
                        children: [
                          const Text('📦', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          MyText(
                            text: 'Livraison',
                            textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.width * 0.04),
                      
                      // Section Adresses simplifiée
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            // Adresse de départ
                            if (arg.pickupAddressList.isNotEmpty)
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.my_location, color: Colors.green, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: MyText(
                                      text: arg.pickupAddressList.first.address,
                                      textStyle: Theme.of(context).textTheme.bodyMedium,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            
                            if (arg.stopAddressList.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Container(
                                  width: 2,
                                  height: 20,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              
                              // Adresse de destination
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.location_on, color: Colors.red, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: MyText(
                                      text: arg.stopAddressList.first.address,
                                      textStyle: Theme.of(context).textTheme.bodyMedium,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      SizedBox(height: size.width * 0.03),
                      
                      // Véhicule et Prix sur la même ligne
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Image véhicule
                            CachedNetworkImage(
                              imageUrl: (context.read<BookingBloc>().isRentalRide)
                                  ? eta.icon
                                  : eta.vehicleIcon,
                              height: 50,
                              width: 50,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Loader(),
                              errorWidget: (context, url, error) => const Icon(Icons.local_shipping, size: 40),
                            ),
                            const SizedBox(width: 12),
                            
                            // Nom véhicule
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: eta.name,
                                    textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (context.read<BookingBloc>().nearByEtaVechileList.isNotEmpty)
                                    MyText(
                                      text: context.read<BookingBloc>().nearByEtaVechileList
                                          .firstWhere((e) => e.typeId == eta.typeId, orElse: () => context.read<BookingBloc>().nearByEtaVechileList.first)
                                          .duration,
                                      textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            
                            // Prix
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: MyText(
                                text: '${eta.currency} ${!context.read<BookingBloc>().isRentalRide ? eta.hasDiscount ? eta.discountTotal : eta.total.toStringAsFixed(0) : eta.hasDiscount ? eta.discountedTotel : eta.fareAmount}',
                                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: size.width * 0.03),
                      
                      // Type de colis simplifié
                      InkWell(
                        onTap: () {
                          context.read<BookingBloc>().add(GetGoodsTypeEvent());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedGoodsTypeId > 0 ? primaryColor : Colors.grey.shade300,
                              width: selectedGoodsTypeId > 0 ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: selectedGoodsTypeId > 0 ? primaryColor.withOpacity(0.05) : null,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Text(
                                selectedGoodsTypeId > 0 
                                    ? _getSelectedTypeEmoji(selectedGoodsTypeId)
                                    : '📦',
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text: 'Type de colis',
                                      textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    MyText(
                                      text: selectedGoodsTypeId > 0
                                          ? '${_getSelectedTypeName(selectedGoodsTypeId)}${goodsQty.isNotEmpty ? ' • Qté: $goodsQty' : ''}'
                                          : 'Sélectionner le type',
                                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: selectedGoodsTypeId > 0 ? Colors.black87 : primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                selectedGoodsTypeId > 0 ? Icons.check_circle : Icons.arrow_forward_ios,
                                color: selectedGoodsTypeId > 0 ? Colors.green : Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: size.width * 0.03),
                      
                      // Mode de paiement simplifié
                      InkWell(
                        onTap: () {
                          if (context.read<BookingBloc>().showPaymentChange) {
                            showModalBottomSheet(
                              context: context,
                              barrierColor: Theme.of(context).shadowColor,
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              builder: (_) {
                                return SelectPaymentMethodWidget(cont: context);
                              },
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  context.read<BookingBloc>().selectedPaymentType == 'cash'
                                      ? Icons.payments_outlined
                                      : Icons.credit_card_rounded,
                                  color: Colors.green,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text: 'Paiement',
                                      textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    MyText(
                                      text: context.read<BookingBloc>().selectedPaymentType == 'cash'
                                          ? 'Espèces'
                                          : 'Carte',
                                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (context.read<BookingBloc>().showPaymentChange)
                                Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: size.width * 0.05),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
