import 'package:flutter/material.dart';
import 'presentation/widgets/moov_balance_widget.dart';
import 'presentation/pages/moov_money_dashboard_page.dart';

/// Exemple d'intégration du widget Moov Money dans votre application
/// 
/// Ce fichier montre comment utiliser les composants Moov Money dans différents contextes

class ExampleIntegrationPage extends StatelessWidget {
  const ExampleIntegrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple Moov Money'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exemple 1: Widget simple dans une page',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // ✅ UTILISATION SIMPLE - Copier ce code dans n'importe quelle page
            MoovBalanceWidget(
              onRefresh: () {
                // Action après rafraîchissement
                print('Solde rafraîchi');
              },
              onTap: () {
                // Navigation vers détails
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoovMoneyDashboardPage(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Exemple 2: Widget compact sans détails',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // ✅ VERSION COMPACTE - Pour les espaces réduits
            MoovBalanceWidget(
              showDetails: false,  // Cache les détails
              autoRefresh: false,  // Désactive le rafraîchissement auto
              onTap: () {
                // Action personnalisée
                _showBalanceBottomSheet(context);
              },
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Exemple 3: Navigation directe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // ✅ BOUTON DE NAVIGATION - Pour accéder au dashboard complet
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoovMoneyDashboardPage(),
                  ),
                );
              },
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('Ouvrir Moov Money'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066CC), // Couleur Moov
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Exemple 4: Dans un Drawer/Menu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // ✅ ITEM DE MENU - Pour drawer ou liste d'options
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFF0066CC),
                ),
                title: const Text('Moov Money'),
                subtitle: const Text('Gérer votre solde'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoovMoneyDashboardPage(),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Exemple 5: Dans un BottomNavigationBar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // ✅ BOTTOM NAV ITEM - Code à intégrer dans votre BottomNavigationBar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '''
// Dans votre BottomNavigationBar:
BottomNavigationBarItem(
  icon: Icon(Icons.account_balance_wallet),
  label: 'Moov Money',
),

// Dans onTap du BottomNavigationBar:
case 2: // Index de l'item Moov Money
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MoovMoneyDashboardPage(),
    ),
  );
  break;
                ''',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBalanceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Solde Moov Money',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Widget complet avec tous les détails
              MoovBalanceWidget(
                showDetails: true,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoovMoneyDashboardPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// INSTRUCTIONS D'UTILISATION:
/// 
/// 1. IMPORTER LES FICHIERS NÉCESSAIRES:
///    ```dart
///    import 'features/moov_money/presentation/widgets/moov_balance_widget.dart';
///    import 'features/moov_money/presentation/pages/moov_money_dashboard_page.dart';
///    ```
/// 
/// 2. AJOUTER LE WIDGET SIMPLE:
///    ```dart
///    MoovBalanceWidget(
///      onRefresh: () {
///        // Votre logique de rafraîchissement
///      },
///      onTap: () {
///        // Navigation vers le dashboard
///        Navigator.push(
///          context,
///          MaterialPageRoute(
///            builder: (context) => const MoovMoneyDashboardPage(),
///          ),
///        );
///      },
///    )
///    ```
/// 
/// 3. OPTIONS DE CONFIGURATION:
///    - showDetails: true/false (afficher ou cacher les détails)
///    - autoRefresh: true/false (rafraîchissement automatique)
///    - onRefresh: callback après rafraîchissement
///    - onTap: callback au tap sur le widget
/// 
/// 4. NAVIGATION DIRECTE:
///    ```dart
///    Navigator.push(
///      context,
///      MaterialPageRoute(
///        builder: (context) => const MoovMoneyDashboardPage(),
///      ),
///    );
///    ```
