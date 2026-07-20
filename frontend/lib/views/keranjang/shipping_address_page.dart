import 'package:flutter/material.dart';
import '../../models/address.dart';
import '../../service/address_service.dart';
import 'cart_constants.dart';

class ShippingAddressPage extends StatefulWidget {
  final Address? selectedAddress;
  final List<Address>? existingAddresses;

  const ShippingAddressPage({
    super.key,
    this.selectedAddress,
    this.existingAddresses,
  });

  @override
  State<ShippingAddressPage> createState() => _ShippingAddressPageState();
}

class _ShippingAddressPageState extends State<ShippingAddressPage> {
  late List<Address> addresses;
  Address? selectedAddress;
  bool isAddingNew = false;
  bool isEditing = false;
  Address? editingAddress;

  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    addresses = widget.existingAddresses ?? [];
    selectedAddress = widget.selectedAddress;
    if (widget.existingAddresses == null) {
      _loadSavedAddresses();
    } else {
      if (selectedAddress == null && addresses.isNotEmpty) {
        selectedAddress = addresses.first;
      }
    }
  }

  Future<void> _loadSavedAddresses() async {
    final saved = await AddressService.loadAddresses();
    if (!mounted) return;

    setState(() {
      addresses = saved;
      if (selectedAddress == null && addresses.isNotEmpty) {
        selectedAddress = addresses.first;
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _clearFormFields() {
    _fullNameController.clear();
    _addressController.clear();
    _cityController.clear();
    _stateController.clear();
    _zipCodeController.clear();
    _countryController.clear();
    _phoneController.clear();
  }

  void _resetFormMode() {
    _clearFormFields();
    isAddingNew = false;
    isEditing = false;
    editingAddress = null;
  }

  Future<void> _saveAddress() async {
    if (_fullNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _zipCodeController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan isi semua kolom')));
      return;
    }

    final savedAddress = (isEditing && editingAddress != null)
        ? editingAddress!.copyWith(
            fullName: _fullNameController.text,
            address: _addressController.text,
            city: _cityController.text,
            state: _stateController.text,
            zipCode: _zipCodeController.text,
            country: _countryController.text.trim().isEmpty
                ? 'Indonesia'
                : _countryController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
          )
        : Address(
            id: DateTime.now().toString(),
            fullName: _fullNameController.text,
            address: _addressController.text,
            city: _cityController.text,
            state: _stateController.text,
            zipCode: _zipCodeController.text,
            country: _countryController.text.trim().isEmpty
                ? 'Indonesia'
                : _countryController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            isDefault: addresses.isEmpty,
          );

    setState(() {
      if (isEditing && editingAddress != null) {
        final index = addresses.indexWhere((a) => a.id == editingAddress!.id);
        if (index != -1) {
          addresses[index] = savedAddress;
        }
      } else {
        addresses.add(savedAddress);
      }
      selectedAddress = savedAddress;
      _resetFormMode();
    });

    await AddressService.saveAddresses(addresses);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Perubahan alamat berhasil disimpan'
              : 'Alamat berhasil disimpan',
        ),
      ),
    );
  }

  void _deleteAddress(Address address) {
    if (addresses.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal harus ada satu alamat')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus alamat'),
        content: const Text('Apakah Anda yakin ingin menghapus alamat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                addresses.remove(address);
                if (selectedAddress?.id == address.id) {
                  selectedAddress = addresses.isNotEmpty
                      ? addresses.first
                      : null;
                }
              });
              await AddressService.saveAddresses(addresses);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: kCartPink,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop(selectedAddress);
          },
        ),
        title: const Text(
          'Alamat Pengiriman',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            if (!isAddingNew) ...[
              const Text(
                'Pilih Alamat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              if (addresses.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Belum ada alamat tersimpan. Tambahkan alamat baru untuk menyimpan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ),
              ] else
                ...addresses.asMap().entries.map((entry) {
                  final address = entry.value;
                  final isSelected = selectedAddress?.id == address.id;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAddress = address;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.red : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        address.fullName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (address.isDefault)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Utama',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.red,
                                        size: 24,
                                      ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _editAddress(address),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _deleteAddress(address),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              address.address,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            if (address.phone != null &&
                                address.phone!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'HP: ${address.phone}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              '${address.city}, ${address.state} ${address.zipCode}, ${address.country}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isAddingNew = true;
                      _clearFormFields();
                    });
                  },
                  child: const Text(
                    'TAMBAH ALAMAT BARU',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              Text(
                isEditing ? 'Edit Alamat' : 'Tambah Alamat Baru',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              _buildFormField(
                controller: _fullNameController,
                label: 'Nama lengkap',
                hint: 'Masukkan nama lengkap Anda',
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nomor HP',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nomor HP',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _addressController,
                label: 'Alamat',
                hint: 'Masukkan alamat lengkap',
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _cityController,
                label: 'Kota',
                hint: 'Masukkan kota',
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _stateController,
                label: 'Provinsi / Kabupaten',
                hint: 'Masukkan provinsi atau kabupaten',
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _zipCodeController,
                label: 'Kode Pos',
                hint: 'Masukkan kode pos',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _countryController,
                label: 'Negara',
                hint: 'Masukkan negara',
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _saveAddress,
                  child: const Text(
                    'SIMPAN ALAMAT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _resetFormMode();
                    });
                  },
                  child: const Text(
                    'BATAL',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _prefillForm(Address address) {
    _fullNameController.text = address.fullName;
    _addressController.text = address.address;
    _cityController.text = address.city;
    _stateController.text = address.state;
    _zipCodeController.text = address.zipCode;
    _countryController.text = address.country;
    _phoneController.text = address.phone ?? '';
  }

  void _editAddress(Address address) {
    setState(() {
      isAddingNew = true;
      isEditing = true;
      editingAddress = address;
      selectedAddress = address;
      _prefillForm(address);
    });
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Negara',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _countryController,
          decoration: InputDecoration(
            hintText: 'Masukkan negara',
            hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
