import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'shared/models/product.dart';
import 'shared/models/client.dart';
import 'shared/models/supplier.dart';
import 'shared/models/sales.dart';
import 'shared/models/sale_item.dart';
import 'shared/models/purchase.dart';
import 'shared/models/transaction.dart';
import 'shared/models/need.dart';
import 'shared/models/account.dart';
import 'shared/models/user.dart' as model;
import 'repositories/user_repository.dart';
import 'repositories/product_repository.dart';
import 'repositories/supplier_repository.dart';
import 'repositories/client_repository.dart';
import 'repositories/need_repository.dart';
import 'repositories/sales_repository.dart';
import 'repositories/sale_item_repository.dart';
import 'repositories/purchase_repository.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/account_repository.dart';
import 'core/auth/auth_service.dart';
import 'core/stock/product_service.dart';
import 'core/need/need_service.dart';
import 'core/supplier/supplier_service.dart';
import 'core/sales/sales_service.dart';
import 'core/purchase/purchase_service.dart';
import 'core/transaction/transaction_service.dart';
import 'core/database/database_seed_service.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('fr_FR', null);
  Intl.defaultLocale = 'fr_FR';

  bool isFirebaseInitialized = false;

  await Hive.initFlutter();

  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(ClientAdapter());
  Hive.registerAdapter(SupplierAdapter());
  Hive.registerAdapter(SalesAdapter());
  Hive.registerAdapter(SaleItemAdapter());
  Hive.registerAdapter(PurchaseAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(NeedAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(model.UserAdapter());

  final productBox = await Hive.openBox<Product>('products');
  final clientBox = await Hive.openBox<Client>('clients');
  final supplierBox = await Hive.openBox<Supplier>('suppliers');
  final salesBox = await Hive.openBox<Sales>('sales');
  final saleItemsBox = await Hive.openBox<SaleItem>('sale_items');
  final purchaseBox = await Hive.openBox<Purchase>('purchases');
  final transactionBox = await Hive.openBox<Transaction>('transactions');
  final needBox = await Hive.openBox<Need>('needs');
  final accountBox = await Hive.openBox<Account>('accounts');
  final userBox = await Hive.openBox<model.User>('users');

  final userRepository = UserRepository(userBox);
  final productRepository = ProductRepository(productBox);
  final supplierRepository = SupplierRepository(supplierBox);
  final clientRepository = ClientRepository(clientBox);
  final needRepository = NeedRepository(needBox);
  final salesRepository = SalesRepository(salesBox);
  final saleItemRepository = SaleItemRepository(saleItemsBox);
  final purchaseRepository = PurchaseRepository(purchaseBox);
  final transactionRepository = TransactionRepository(transactionBox);
  final accountRepository = AccountRepository(accountBox);
  
  final seedService = DatabaseSeedService(
    productRepository: productRepository,
    supplierRepository: supplierRepository,
    clientRepository: clientRepository,
    userRepository: userRepository,
  );
  await seedService.seedAll();

  final authService = AuthService(userRepository);
  final productService = ProductService(productRepository);
  final needService = NeedService(needRepository);
  final supplierService = SupplierService(supplierRepository);
  
  final salesService = SalesService(
    salesRepository: salesRepository,
    saleItemRepository: saleItemRepository,
    productRepository: productRepository,
    transactionRepository: transactionRepository,
    accountRepository: accountRepository,
  );
  
  final transactionService = TransactionService(
    transactionRepository,
    needRepository,
    accountRepository,
  );

  final purchaseService = PurchaseService(
    purchaseRepository: purchaseRepository,
    productRepository: productRepository,
    transactionRepository: transactionRepository,
    accountRepository: accountRepository,
  );

  runApp(GestockApp(
    authService: authService, 
    isFirebaseInitialized: isFirebaseInitialized,
    productService: productService,
    clientRepository: clientRepository,
    needService: needService,
    supplierService: supplierService,
    salesService: salesService,
    purchaseService: purchaseService,
    transactionService: transactionService,
  ));
}

class GestockApp extends StatelessWidget {
  final AuthService authService;
  final ProductService productService;
  final ClientRepository clientRepository;
  final NeedService needService;
  final SupplierService supplierService;
  final SalesService salesService;
  final PurchaseService purchaseService;
  final TransactionService transactionService;
  final bool isFirebaseInitialized;
  
  const GestockApp({
    super.key, 
    required this.authService, 
    required this.isFirebaseInitialized,
    required this.productService,
    required this.clientRepository,
    required this.needService,
    required this.supplierService,
    required this.salesService,
    required this.purchaseService,
    required this.transactionService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gestock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('fr', 'FR'),
      home: GestockSplashScreen(
        authService: authService, 
        isFirebaseEnabled: isFirebaseInitialized,
        productService: productService,
        clientRepository: clientRepository,
        needService: needService,
        supplierService: supplierService,
        salesService: salesService,
        purchaseService: purchaseService,
        transactionService: transactionService,
      ),
    );
  }
}

class GestockSplashScreen extends StatefulWidget {
  final AuthService authService;
  final ProductService productService;
  final ClientRepository clientRepository;
  final NeedService needService;
  final SupplierService supplierService;
  final SalesService salesService;
  final PurchaseService purchaseService;
  final TransactionService transactionService;
  final bool isFirebaseEnabled;
  const GestockSplashScreen({
    super.key, 
    required this.authService, 
    required this.isFirebaseEnabled,
    required this.productService,
    required this.clientRepository,
    required this.needService,
    required this.supplierService,
    required this.salesService,
    required this.purchaseService,
    required this.transactionService,
  });

  @override
  State<GestockSplashScreen> createState() => _GestockSplashScreenState();
}

class _GestockSplashScreenState extends State<GestockSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF0F172A),
              Color(0xFF020617),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: GridPainter())),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.cyanAccent,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'gestock',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 5,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'GESTION DE STOCK INTELLIGENTE',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(
                              authService: widget.authService,
                              productService: widget.productService,
                              clientRepository: widget.clientRepository,
                              needService: widget.needService,
                              supplierService: widget.supplierService,
                              salesService: widget.salesService,
                              purchaseService: widget.purchaseService,
                              transactionService: widget.transactionService,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.cyanAccent, width: 1.5),
                        ),
                      ),
                      child: const Text('COMMENCER'),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(
                              authService: widget.authService,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'CRÉER UN COMPTE',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  const GridPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;
    const double step = 45.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
