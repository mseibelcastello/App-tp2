import 'package:material_ui/material_ui.dart';

import 'scale.dart';

// Abre la pantalla de pago simulada. Devuelve true si el "pago" fue aprobado.
// No se cobra nada: es una simulación de cómo sería la compra.
Future<bool> showPayment(
  BuildContext context, {
  required String product,
  required String price,
}) async {
  final approved = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      fullscreenDialog: true, // sube desde abajo, como saliendo a otra app
      builder: (_) => PaymentScreen(product: product, price: price),
    ),
  );
  return approved == true;
}

enum _Step { choosing, processing, approved }

// Una "app de pago" falsa: tiene su propio color (azul) para que se sienta
// como salir del juego a otra aplicación.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.product, required this.price});

  final String product;
  final String price;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const _methods = [
    (Icons.credit_card_rounded, 'Tarjeta de crédito o débito'),
    (Icons.account_balance_wallet_rounded, 'Billetera virtual'),
    (Icons.account_balance_rounded, 'Transferencia bancaria'),
  ];

  _Step _step = _Step.choosing;
  int _method = 0;

  // "Procesa" el pago: espera un par de segundos y lo aprueba
  Future<void> _pay() async {
    setState(() => _step = _Step.processing);
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    setState(() => _step = _Step.approved);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.ui;

    // Theme propio: azul en vez del rosa del juego
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3949AB),
      brightness: Theme.of(context).brightness,
    );

    return Theme(
      data: Theme.of(context).copyWith(colorScheme: scheme),
      child: Builder(
        builder: (context) {
          // PopScope controla el botón "atrás": mientras procesa no se puede
          // salir, y si ya se aprobó, salir cuenta como pago hecho.
          return PopScope(
            canPop: _step == _Step.choosing,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop && _step == _Step.approved) Navigator.pop(context, true);
            },
            child: Scaffold(
            backgroundColor: scheme.surface,
            appBar: AppBar(
              backgroundColor: scheme.surface,
              // No se puede cancelar mientras procesa
              leading: _step == _Step.processing
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context, _step == _Step.approved),
                    ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_rounded, size: 20 * s, color: scheme.primary),
                  SizedBox(width: 8 * s),
                  Text('Pago seguro', style: TextStyle(fontSize: 22 * s, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            body: SafeArea(
              child: switch (_step) {
                _Step.choosing => _buildChoosing(context, scheme),
                _Step.processing => _buildProcessing(context, scheme),
                _Step.approved => _buildApproved(context, scheme),
              },
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChoosing(BuildContext context, ColorScheme scheme) {
    final s = context.ui;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 24 * s),
      children: [
        // Aviso de que es una simulación
        Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: scheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(16 * s),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: scheme.onTertiaryContainer),
              SizedBox(width: 10 * s),
              Expanded(
                child: Text(
                  'Simulación: no se cobra nada.',
                  style: TextStyle(fontSize: 16 * s, color: scheme.onTertiaryContainer),
                ),
              ),
            ],
          ),
        ),

        // Resumen del pedido
        SizedBox(height: 20 * s),
        Text('Tu compra', style: TextStyle(fontSize: 15 * s, color: scheme.onSurfaceVariant)),
        SizedBox(height: 6 * s),
        Container(
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20 * s),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(widget.product, style: TextStyle(fontSize: 19 * s, fontWeight: FontWeight.w800)),
              ),
              Text(widget.price, style: TextStyle(fontSize: 22 * s, fontWeight: FontWeight.w800)),
            ],
          ),
        ),

        // Medios de pago
        SizedBox(height: 22 * s),
        Text('Medio de pago', style: TextStyle(fontSize: 15 * s, color: scheme.onSurfaceVariant)),
        SizedBox(height: 6 * s),
        for (var i = 0; i < _methods.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: 8 * s),
            child: Material(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20 * s),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => setState(() => _method = i),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 14 * s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20 * s),
                    border: Border.all(
                      color: _method == i ? scheme.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(_methods[i].$1, size: 28 * s, color: scheme.primary),
                      SizedBox(width: 12 * s),
                      Expanded(child: Text(_methods[i].$2, style: TextStyle(fontSize: 17 * s))),
                      Icon(
                        _method == i ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: _method == i ? scheme.primary : scheme.outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        SizedBox(height: 18 * s),
        FilledButton(
          onPressed: _pay,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 18 * s),
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
          ),
          child: Text('Pagar ${widget.price}', style: TextStyle(fontSize: 21 * s)),
        ),
      ],
    );
  }

  Widget _buildProcessing(BuildContext context, ColorScheme scheme) {
    final s = context.ui;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64 * s,
            height: 64 * s,
            child: CircularProgressIndicator(strokeWidth: 6 * s, color: scheme.primary),
          ),
          SizedBox(height: 24 * s),
          Text('Procesando el pago...', style: TextStyle(fontSize: 22 * s, fontWeight: FontWeight.w800)),
          SizedBox(height: 6 * s),
          Text('No cierres esta pantalla', style: TextStyle(fontSize: 16 * s, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildApproved(BuildContext context, ColorScheme scheme) {
    final s = context.ui;
    return Padding(
      padding: EdgeInsets.all(24 * s),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, size: 96 * s, color: scheme.primary),
          SizedBox(height: 16 * s),
          Text('Pago aprobado', style: TextStyle(fontSize: 30 * s, fontWeight: FontWeight.w800)),
          SizedBox(height: 6 * s),
          Text(
            '${widget.product}\n${widget.price} (simulado)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17 * s, height: 1.4, color: scheme.onSurfaceVariant),
          ),
          SizedBox(height: 32 * s),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 18 * s)),
              child: Text('Volver al juego', style: TextStyle(fontSize: 21 * s)),
            ),
          ),
        ],
      ),
    );
  }
}
