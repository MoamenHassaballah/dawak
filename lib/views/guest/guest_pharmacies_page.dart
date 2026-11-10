import 'package:dawak/views/constants/app_colors.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:dawak/views/widgets/pharmacy_widget.dart';
import 'package:flutter/material.dart';

class GuestPharmaciesPage extends StatefulWidget {
  const GuestPharmaciesPage({super.key});

  @override
  State<StatefulWidget> createState() => _GuestPharmaciesPageState();
}

class _GuestPharmaciesPageState extends State<GuestPharmaciesPage> {
  final _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: .end,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              label: AppText(text: "searchPlaceholder"),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.stroke),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primary),
              ),

              prefixIcon: Icon(Icons.search_outlined, color: AppColors.grey),
            ),

            onTapOutside: (event) => FocusScope.of(context).unfocus(),
          ),
          const SizedBox(height: 8),
          IconButton(onPressed: () {}, icon: Icon(Icons.tune_outlined)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              shrinkWrap: true,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: const PharmacyWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
