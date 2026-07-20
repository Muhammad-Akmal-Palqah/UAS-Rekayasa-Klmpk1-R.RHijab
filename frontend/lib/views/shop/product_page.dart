import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../service/cart_service.dart';
import '../keranjang/cart_constants.dart';

import '../../models/comment.dart';
import '../../models/product.dart';
import '../../service/api_service.dart';
import '../../shared/rating_stars.dart';
import '../keranjang/cart_page.dart';

const Color kDominant = Color(0xFFFFCCCC); // ffcccc
const Color kAccentGreen = Color(0xFFCCFFCC); // ccffcc
const Color kAccentBlue = Color(0xFFCCCCFF); // ccccff

class ProductPage extends StatefulWidget {
  final Product? product;

  const ProductPage({Key? key, this.product}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ImagePicker _picker = ImagePicker();
  late PageController _pageController;
  int _currentImageIndex = 0;
  late String _selectedSize;
  late String _selectedColor;

  final TextEditingController _reviewController = TextEditingController();
  final List<Comment> _comments = [];
  bool _isLoadingComments = false;
  bool _isCheckingReviewStatus = false;
  bool _hasSubmittedReview = false;
  int _selectedRating = 0;

  List<Comment> get _filteredComments {
    if (_selectedRating == 0) return _comments;
    return _comments
        .where((comment) => comment.rating == _selectedRating)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    final sizeOptions =
        widget.product?.availableSizes.where((s) => s.isNotEmpty).toList() ??
        [];
    _selectedSize = '';

    final colorOptions =
        widget.product?.availableColors.where((s) => s.isNotEmpty).toList() ??
        [];
    _selectedColor = '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchComments();
      _checkCommentStatus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  int _sizeStock(String size) {
    final stocks = widget.product?.availableSizeStocks ?? {};
    if (stocks.isEmpty) return 1;
    return stocks[size] ?? 0;
  }

  int _colorStock(String color) {
    final stocks = widget.product?.availableColorStocks ?? {};
    if (stocks.isEmpty) return 1;
    return stocks[color] ?? 0;
  }

  Future<void> _openSizeSelector() async {
    final sizeOptions =
        widget.product?.availableSizes.where((s) => s.isNotEmpty).toList() ??
        [];
    final sizes = sizeOptions.isNotEmpty
        ? sizeOptions
        : ['XS', 'S', 'M', 'L', 'XL'];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: sizes.map((s) {
                    final available = _sizeStock(s) > 0;
                    final selected = s == _selectedSize;
                    return ListTile(
                      title: Text(s),
                      subtitle: Text(
                        available ? 'Stok ${_sizeStock(s)}' : 'Habis',
                      ),
                      trailing: selected ? const Icon(Icons.check) : null,
                      onTap: available
                          ? () {
                              setState(() => _selectedSize = s);
                              Navigator.of(context).pop();
                            }
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openColorSelector() async {
    final colorOptions =
        widget.product?.availableColors.where((c) => c.isNotEmpty).toList() ??
        [];
    final colors = colorOptions.isNotEmpty
        ? colorOptions
        : ['Black', 'Grey', 'White', 'Navy'];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: colors.map((c) {
                    final available = _colorStock(c) > 0;
                    final selected = c == _selectedColor;
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: _colorFromName(c)),
                      title: Text(c),
                      subtitle: Text(
                        available ? 'Stok ${_colorStock(c)}' : 'Habis',
                      ),
                      trailing: selected ? const Icon(Icons.check) : null,
                      onTap: available
                          ? () {
                              setState(() => _selectedColor = c);
                              Navigator.of(context).pop();
                            }
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _colorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'red':
        return Colors.red;
      case 'pink':
        return Colors.pink;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'brown':
        return Colors.brown;
      case 'navy':
        return const Color(0xFF001F54);
      case 'cream':
        return const Color(0xFFFFF4E6);
      case 'maroon':
        return const Color(0xFF800000);
      default:
        return Colors.black12;
    }
  }

  Future<void> _fetchComments() async {
    if (widget.product == null || widget.product!.id.isEmpty) return;
    if (_isLoadingComments) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoadingComments = true);
    try {
      final comments = await ApiService.fetchComments(widget.product!.id);
      if (!mounted) return;
      setState(() {
        _comments.clear();
        _comments.addAll(comments);
      });
    } catch (error) {
      if (mounted)
        messenger.showSnackBar(
          SnackBar(content: Text('Gagal memuat komentar: $error')),
        );
    } finally {
      if (mounted) setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _checkCommentStatus() async {
    if (widget.product == null || widget.product!.id.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    if (savedToken == null || savedToken.isEmpty) {
      if (mounted) {
        setState(() => _hasSubmittedReview = false);
      }
      return;
    }

    ApiService.authToken = savedToken;
    if (!mounted) return;
    setState(() => _isCheckingReviewStatus = true);

    try {
      final hasCommented = await ApiService.checkCommentStatus(
        widget.product!.id,
      );
      if (mounted) {
        setState(() => _hasSubmittedReview = hasCommented);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _hasSubmittedReview = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingReviewStatus = false);
      }
    }
  }

  Future<void> _refreshProductData() async {
    await _fetchComments();
    await _checkCommentStatus();
  }

  void _openImagePreview(int initialIndex, List<String> images) {
    final previewController = PageController(initialPage: initialIndex);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            body: PageView.builder(
              controller: previewController,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final url = images[index];
                return Center(
                  child: InteractiveViewer(
                    maxScale: 4.0,
                    minScale: 0.8,
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 56,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showReviewDialog() async {
    if (_hasSubmittedReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Anda sudah pernah memberikan ulasan untuk produk ini.',
          ),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    if (savedToken == null || savedToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan login terlebih dahulu untuk memberikan ulasan.',
          ),
        ),
      );
      return;
    }

    ApiService.authToken = savedToken;

    int draftRating = 5;
    XFile? draftImage;
    Uint8List? draftImageBytes;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Beri ulasan'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Penilaian Anda'),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        final selected = index < draftRating;
                        return IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              setDialogState(() => draftRating = index + 1),
                          icon: Icon(
                            Icons.star,
                            color: selected ? Colors.amber : Colors.grey[300],
                            size: 28,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reviewController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Tuliskan pendapat Anda tentang produk ini',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kDominant),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.image_outlined),
                      label: Text(
                        draftImage == null ? 'Tambah foto' : 'Ganti foto',
                      ),
                      onPressed: () async {
                        final image = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image == null) return;
                        final bytes = await image.readAsBytes();
                        setDialogState(() {
                          draftImage = image;
                          draftImageBytes = bytes;
                        });
                      },
                    ),
                    if (draftImage != null && draftImageBytes != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 140,
                          child: Image.memory(
                            draftImageBytes!,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            StatefulBuilder(
              builder: (actionContext, setActionState) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kDominant),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(dialogContext);
                          final dialogNavigator = Navigator.of(dialogContext);
                          final comment = _reviewController.text.trim();
                          if (comment.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Tolong Tulis Komen terlebih dahulu.',
                                ),
                              ),
                            );
                            return;
                          }
                          if (widget.product == null ||
                              widget.product!.id.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Produk tidak valid.'),
                              ),
                            );
                            return;
                          }
                          setActionState(() => isSubmitting = true);
                          try {
                            final createdComment = await ApiService.postComment(
                              productId: widget.product!.id,
                              komentar: comment,
                              rating: draftRating,
                              imageBytes: draftImageBytes,
                              imageFileName: draftImage?.name,
                            );
                            if (!mounted) return;
                            setState(() {
                              _comments.insert(0, createdComment);
                              _hasSubmittedReview = true;
                            });
                            _reviewController.clear();
                            dialogNavigator.pop();
                          } catch (error) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal mengirim komentar: $error',
                                ),
                              ),
                            );
                            if (actionContext.mounted) {
                              setActionState(() => isSubmitting = false);
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Kirim'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRatingReviewSection() {
    final averageRating = _comments.isNotEmpty
        ? _comments.map((c) => c.rating).reduce((a, b) => a + b) /
              _comments.length
        : widget.product?.averageRating ?? 0.0;
    final reviewCount = _comments.isNotEmpty
        ? _comments.length
        : widget.product?.reviewCount ?? 0;
    final displayRating = averageRating;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFD),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF2DADA), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Rating & Reviews',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kDominant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${averageRating.toStringAsFixed(1)}/5',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              RatingStars(
                rating: displayRating,
                iconSize: 18,
                filledColor: Colors.amber,
                emptyColor: Colors.grey[300]!,
              ),
              const SizedBox(width: 8),
              Text(
                reviewCount == 0 ? 'Belum ada review' : '$reviewCount review',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Semua'),
                selected: _selectedRating == 0,
                onSelected: (_) => setState(() => _selectedRating = 0),
              ),
              ...List.generate(5, (index) {
                final rating = index + 1;
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$rating'),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                    ],
                  ),
                  selected: _selectedRating == rating,
                  selectedColor: Colors.amber.shade100,
                  onSelected: (_) {
                    setState(() {
                      _selectedRating = _selectedRating == rating ? 0 : rating;
                    });
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent comments',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: _hasSubmittedReview || _isCheckingReviewStatus
                    ? null
                    : _showReviewDialog,
                icon: const Icon(Icons.edit_note_outlined, size: 18),
                label: Text(
                  _isCheckingReviewStatus
                      ? 'Memeriksa...'
                      : _hasSubmittedReview
                      ? 'Sudah memberi ulasan'
                      : 'Beri ulasan',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isLoadingComments)
            const Center(child: CircularProgressIndicator())
          else if (_comments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Belum ada komentar. Jadilah yang pertama memberi ulasan.',
                style: TextStyle(color: Colors.black54),
              ),
            )
          else if (_filteredComments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Tidak ada komentar dengan rating $_selectedRating.',
                style: const TextStyle(color: Colors.black54),
              ),
            )
          else
            Column(
              children: [
                for (final review in _filteredComments)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage:
                                  review.fullProfileImageUrl.isNotEmpty
                                  ? NetworkImage(review.fullProfileImageUrl)
                                  : null,
                              onBackgroundImageError:
                                  review.fullProfileImageUrl.isNotEmpty
                                  ? (_, __) {
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    }
                                  : null,
                              child: review.fullProfileImageUrl.isNotEmpty
                                  ? null
                                  : Text(
                                      review.author.isNotEmpty
                                          ? review.author
                                                .substring(0, 1)
                                                .toUpperCase()
                                          : 'P',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.author,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    review.createdAt,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Verified',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              color: index < review.rating
                                  ? Colors.amber
                                  : Colors.grey[300],
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          review.message,
                          style: const TextStyle(height: 1.4),
                        ),
                        if (review.imageUrl != null &&
                            review.imageUrl!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: double.infinity,
                              height: 120,
                              child: Image.network(
                                review.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 120,
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: Icon(Icons.broken_image),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = (widget.product?.imageUrls.isNotEmpty == true)
        ? widget.product!.imageUrls
        : (widget.product?.imageUrl != null &&
              widget.product!.imageUrl.isNotEmpty)
        ? [widget.product!.imageUrl]
        : <String>[];

    if (_currentImageIndex >= images.length && images.isNotEmpty) {
      _currentImageIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pageController.jumpToPage(0);
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'R.R Hijab Shop',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProductData,
              color: kDominant,
              child: ListView(
                children: [
                  SizedBox(
                    height: 360,
                    child: images.isEmpty
                        ? Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 56,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            onPageChanged: (idx) =>
                                setState(() => _currentImageIndex = idx),
                            itemBuilder: (context, index) {
                              final url = images[index];
                              return GestureDetector(
                                onTap: () => _openImagePreview(index, images),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 56,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (images.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (i) {
                          final active = i == _currentImageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: active ? 10 : 8,
                            height: active ? 10 : 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.black87
                                  : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Size and Color selectors
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _openSizeSelector,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Size'),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _selectedSize.isEmpty
                                              ? 'Pilih size'
                                              : _selectedSize,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.expand_more),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _openColorSelector,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _selectedColor.isEmpty
                                          ? 'Pilih warna'
                                          : _selectedColor,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.expand_more),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product?.title ?? 'Produk R.R Hijab',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          flex: 0,
                          child: Text(
                            widget.product?.price ?? 'Rp0',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.product?.description ??
                          'Deskripsi tidak tersedia.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDominant,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        elevation: 8,
                      ),
                      onPressed: () async {
                        if (_selectedSize.isEmpty || _selectedColor.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Pilih ukuran dan warna sebelum menambahkan ke keranjang.',
                              ),
                            ),
                          );
                          return;
                        }

                        if (widget.product != null) {
                          final priceVal = widget.product!.priceValue;
                          final promoPrice = widget.product!.promoPrice;
                          final unit = (promoPrice ?? priceVal).round();
                          final original = priceVal.round();
                          final item = CartItemData(
                            productId: widget.product!.id,
                            name: widget.product!.title,
                            subtitle: widget.product!.description,
                            emoji: '🧕',
                            imageUrl: widget.product!.imageUrl,
                            unitPrice: unit,
                            originalPrice: original,
                            quantity: 1,
                            color: widget.product!.color,
                            size: _selectedSize,
                            colorName: _selectedColor,
                            promoPercent: widget.product!.promoPercent,
                          );
                          await CartService.addItem(item);
                          if (!mounted) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CartPage()),
                          );
                        }
                      },
                      child: const Text(
                        'ADD TO CART',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildRatingReviewSection(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
