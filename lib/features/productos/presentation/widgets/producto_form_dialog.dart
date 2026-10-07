import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../../core/errors/failures.dart';
import '../../domain/entities/producto_entity.dart';
import '../providers/producto_providers.dart';

class ProductoFormDialog extends ConsumerStatefulWidget {
  final Producto? productoExistente;

  const ProductoFormDialog({super.key, this.productoExistente});

  @override
  ConsumerState<ProductoFormDialog> createState() => _ProductoFormDialogState();
}

class _ProductoFormDialogState extends ConsumerState<ProductoFormDialog> {
  static const _maxImageBytes = 5 * 1024 * 1024;
  static const _maxImageDimension = 1600.0;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _precioCompraCtrl;
  late final TextEditingController _precioVentaCtrl;
  late final TextEditingController _cantidadCtrl;
  
  String? _fotoPath;
  int? _categoriaId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.productoExistente;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _descripcionCtrl = TextEditingController(text: p?.descripcion ?? '');
    _precioCompraCtrl = TextEditingController(text: p?.precioCompra.toString() ?? '');
    _precioVentaCtrl = TextEditingController(text: p?.precioVenta.toString() ?? '');
    _cantidadCtrl = TextEditingController(text: p?.cantidadDisponible.toString() ?? '0');
    _fotoPath = p?.fotoPath;
    _categoriaId = p?.categoriaId;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCompraCtrl.dispose();
    _precioVentaCtrl.dispose();
    _cantidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxImageDimension,
      maxHeight: _maxImageDimension,
      imageQuality: 80,
    );
    
    if (image != null) {
      final imageFile = File(image.path);
      if (await imageFile.length() > _maxImageBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La foto debe pesar como máximo 5 MB.'),
            ),
          );
        }
        return;
      }
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${p.basename(image.path)}';
      final savedImage = await File(image.path).copy('${appDir.path}/$fileName');
      if (mounted) setState(() => _fotoPath = savedImage.path);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final producto = Producto(
      id: widget.productoExistente?.id,
      categoriaId: _categoriaId,
      viajeId: widget.productoExistente?.viajeId,
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
      precioCompra: int.parse(_precioCompraCtrl.text.trim()),
      comisionViaje: widget.productoExistente?.comisionViaje ?? 0,
      precioVenta: int.parse(_precioVentaCtrl.text.trim()),
      cantidadDisponible: int.parse(_cantidadCtrl.text.trim()),
      fotoPath: _fotoPath,
      activo: widget.productoExistente?.activo ?? true,
    );

    try {
      await ref.read(saveProductoUseCaseProvider).call(producto);
      if (mounted) Navigator.of(context).pop(producto);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(categoriasStreamProvider).asData?.value ?? const [];
    return AlertDialog(
      title: Text(widget.productoExistente == null ? 'Nuevo producto' : 'Editar producto'),
      scrollable: true,
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _seleccionarFoto,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: _fotoPath != null ? DecorationImage(image: FileImage(File(_fotoPath!)), fit: BoxFit.cover) : null,
                  ),
                  child: _fotoPath == null ? const Icon(Icons.add_a_photo_outlined, size: 30, color: Colors.grey) : null,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre *', prefixIcon: Icon(Icons.shopping_bag_outlined)),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: categorias.any((categoria) => categoria.id == _categoriaId)
                    ? _categoriaId
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Sin categoría'),
                  ),
                  ...categorias.map((categoria) => DropdownMenuItem<int?>(
                        value: categoria.id,
                        child: Text(categoria.nombre),
                      )),
                ],
                onChanged: (categoriaId) =>
                    setState(() => _categoriaId = categoriaId),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precioCompraCtrl,
                      decoration: const InputDecoration(labelText: 'Costo Compra'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _precioVentaCtrl,
                      decoration: const InputDecoration(labelText: 'P. Venta Base *'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cantidadCtrl,
                decoration: const InputDecoration(labelText: 'Stock Inicial', prefixIcon: Icon(Icons.inventory_2_outlined)),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _descripcionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _isLoading ? null : _guardar, child: const Text('Guardar Producto')),
      ],
    );
  }
}
