import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/warm_ui.dart';
import '../../../clientes/domain/entities/cliente_entity.dart';
import '../../../clientes/presentation/providers/cliente_providers.dart';
import '../../domain/entities/pago_entity.dart';
import '../providers/pago_providers.dart';

class PagoFormScreen extends ConsumerStatefulWidget {
  final Pago? pagoExistente;
  final int? clienteId;

  const PagoFormScreen({super.key, this.pagoExistente, this.clienteId});

  @override
  ConsumerState<PagoFormScreen> createState() => _PagoFormScreenState();
}

class _PagoFormScreenState extends ConsumerState<PagoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _montoCtrl;
  late final TextEditingController _conceptoCtrl;
  String _metodo = 'Transferencia';
  String _tipo = 'ABONO';
  int? _clienteId;
  DateTime _fecha = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.pagoExistente;
    _montoCtrl = TextEditingController(text: p?.monto.toString() ?? '');
    _conceptoCtrl = TextEditingController(text: p?.concepto ?? '');
    _metodo = p?.metodo ?? 'Transferencia';
    _tipo = p?.tipo ?? 'ABONO';
    _clienteId = p?.clienteId ?? widget.clienteId;
    if (p != null) {
      _fecha = p.fecha;
    }
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _conceptoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _clienteId == null) return;
    setState(() => _isLoading = true);

    final nuevoPago = Pago(
      id: widget.pagoExistente?.id,
      clienteId: _clienteId!,
      monto: int.parse(_montoCtrl.text),
      fecha: _fecha,
      metodo: _metodo,
      tipo: _tipo,
      concepto: _conceptoCtrl.text.trim().isEmpty ? null : _conceptoCtrl.text.trim(),
    );

    try {
      if (widget.pagoExistente == null) {
        await ref.read(registrarPagoUseCaseProvider).call(nuevoPago);
      } else {
        await ref.read(editarPagoUseCaseProvider).call(nuevoPago);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientes = ref.watch(clientesStreamProvider).asData?.value ?? [];
    final debt = _clienteId != null ? ref.watch(deudaClienteProvider(_clienteId!)) : 0;
    
    final selectedCliente = _clienteId != null
        ? clientes.firstWhere((c) => c.id == _clienteId, orElse: () => Cliente(nombre: '', fechaRegistro: DateTime(2000)))
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.pagoExistente == null ? 'Registrar Pago' : 'Editar Pago')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5EFE6), Color(0xFFFFFDF9)],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<int?>(
                value: _clienteId,
                decoration: const InputDecoration(labelText: 'Cliente *', prefixIcon: Icon(Icons.person_outline)),
                items: clientes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
                onChanged: (widget.clienteId != null || widget.pagoExistente != null) ? null : (v) => setState(() => _clienteId = v),
                validator: (v) => v == null ? 'Selecciona un cliente' : null,
              ),
              const SizedBox(height: 16),
              if (selectedCliente != null) ...[
                WarmSurfaceCard(
                  child: Row(
                    children: [
                      WarmClienteAvatar(nombre: selectedCliente.nombre, radius: 24, tieneDeuda: debt > 0),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selectedCliente.nombre, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              debt < 0 ? 'Saldo a favor: +${formatCurrencyClp(debt.abs())}' : 'Deuda actual: ${formatCurrencyClp(debt)}', 
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: debt > 0 ? const Color(0xFFD67C52) : const Color(0xFF6E7E52),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _montoCtrl,
                decoration: const InputDecoration(labelText: 'Monto a recibir *', prefixIcon: Icon(Icons.monetization_on_outlined)),
                keyboardType: TextInputType.number,
                validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Monto inválido' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: _fecha, firstDate: DateTime(2020), lastDate: DateTime(2100));
                  if (picked != null) setState(() => _fecha = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Fecha del pago', prefixIcon: Icon(Icons.calendar_today_outlined)),
                  child: Text('${_fecha.day}/${_fecha.month}/${_fecha.year}'),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _metodo,
                decoration: const InputDecoration(labelText: 'Método de pago', prefixIcon: Icon(Icons.credit_card_outlined)),
                items: ['Transferencia', 'Efectivo', 'Tarjeta'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => _metodo = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo de registro', prefixIcon: Icon(Icons.label_outline)),
                items: const [
                  DropdownMenuItem(value: 'ABONO', child: Text('Abono a deuda')),
                  DropdownMenuItem(value: 'PAGO_TOTAL', child: Text('Pago total')),
                  DropdownMenuItem(value: 'AJUSTE', child: Text('Ajuste de saldo')),
                ],
                onChanged: (v) => setState(() => _tipo = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _conceptoCtrl,
                decoration: const InputDecoration(labelText: 'Nota / Concepto', prefixIcon: Icon(Icons.short_text_outlined)),
              ),
              const SizedBox(height: 32),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 54)),
                onPressed: _isLoading ? null : _guardar,
                child: _isLoading ? const CircularProgressIndicator() : Text(widget.pagoExistente == null ? 'Confirmar Registro' : 'Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
