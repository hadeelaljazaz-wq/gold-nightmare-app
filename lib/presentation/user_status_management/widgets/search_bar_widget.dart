import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'البحث بالإيميل أو الاسم...',
              hintStyle: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF9CA3AF),
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF6B7280)),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.sp),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.sp,
                vertical: 14.sp,
              ),
            ),
            onChanged: widget.onSearchChanged,
          ),
        ),

        SizedBox(height: 16.sp),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('الكل', 'all'),
              SizedBox(width: 8.sp),
              _buildFilterChip('المفعلين', 'unlocked'),
              SizedBox(width: 8.sp),
              _buildFilterChip('المقفلين', 'locked'),
              SizedBox(width: 8.sp),
              _buildFilterChip('المسؤولين', 'admin'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = widget.selectedFilter == value;

    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
      selected: isSelected,
      onSelected: (_) => widget.onFilterChanged(value),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF3B82F6),
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.sp),
        side: BorderSide(
          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
    );
  }
}
