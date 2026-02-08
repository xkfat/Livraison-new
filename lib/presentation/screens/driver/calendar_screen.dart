import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/cubit/commande/commande_cubit.dart';
import '../../../logic/cubit/commande/commande_state.dart';
import '../../../data/models/commande_model.dart';
import 'delivery_details_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedMonth = DateTime.now();
    // Load commandes for selected date
    _loadCommandesForDate(_selectedDate);
  }

  void _loadCommandesForDate(DateTime date) {
    context.read<CommandeCubit>().loadCommandesByDate(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 16,
              20,
              16,
            ),
            color: const Color(0xFF2563EB),
            child: BlocBuilder<CommandeCubit, CommandeState>(
              builder: (context, state) {
                int totalUpcoming = 0;
                if (state is CommandeLoaded) {
                  totalUpcoming = state.commandes.length;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Calendrier',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.inventory_2,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$totalUpcoming à venir',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Planification des livraisons',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Calendar Card
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Month navigation
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _focusedMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month - 1,
                            );
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Color(0xFF1F2937),
                            size: 20,
                          ),
                        ),
                      ),
                      Text(
                        _getMonthName(_focusedMonth),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _focusedMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month + 1,
                            );
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF1F2937),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Weekday headers
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
                        .map((day) => SizedBox(
                              width: 36,
                              child: Text(
                                day,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // Calendar grid
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  child: _buildCalendarGrid(),
                ),
              ],
            ),
          ),

          // Bottom section with deliveries list
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: BlocBuilder<CommandeCubit, CommandeState>(
                builder: (context, state) {
                  if (state is CommandeLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2563EB),
                      ),
                    );
                  }

                  if (state is CommandeError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Color(0xFFEF4444),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  List<CommandeModel> deliveries = [];
                  if (state is CommandeLoaded) {
                    deliveries = state.commandes;
                  }

                  return Column(
                    children: [
                      // Selected date header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatSelectedDate(_selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                if (_isToday(_selectedDate))
                                  const Text(
                                    "Aujourd'hui",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: deliveries.isNotEmpty
                                    ? const Color(0xFF2563EB).withOpacity(0.1)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${deliveries.length} livraison(s)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: deliveries.isNotEmpty
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Deliveries list
                      Expanded(
                        child: deliveries.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_available,
                                      size: 48,
                                      color: Colors.grey.withOpacity(0.4),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Aucune livraison prévue',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sélectionnez une autre date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: const Color(0xFF6B7280).withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                itemCount: deliveries.length,
                                itemBuilder: (context, index) {
                                  return _buildDeliveryCard(deliveries[index]);
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    // Empty cells for days before the first day of month
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 36, height: 40));
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = _selectedDate.year == date.year &&
          _selectedDate.month == date.month &&
          _selectedDate.day == date.day;
      final isToday = _isToday(date);

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
            _loadCommandesForDate(date);
          },
          child: Container(
            width: 36,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : isToday
                      ? const Color(0xFF2563EB).withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF1F2937),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.start,
      children: dayWidgets,
    );
  }

  Widget _buildDeliveryCard(CommandeModel commande) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DeliveryDetailScreen(
                  commande: commande,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Time badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        commande.dateLivraison != null
                            ? '${commande.dateLivraison!.hour}'
                            : '--',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        commande.dateLivraison != null
                            ? ':${commande.dateLivraison!.minute.toString().padLeft(2, '0')}'
                            : ':--',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            commande.trackingId,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          if (commande.estFragile) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '⚠️ Fragile',
                                style: TextStyle(fontSize: 9),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        commande.clientName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        commande.adresseText,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Price and arrow
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${commande.montant.toStringAsFixed(2)} DH',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatSelectedDate(DateTime date) {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }
}