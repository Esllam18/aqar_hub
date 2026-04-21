// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';

class OwnerLoadingView extends StatelessWidget {
  const OwnerLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: context.rAll(16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: context.rOnly(bottom: 14),
        padding: context.rAll(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: context.r(18),
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: context.r(160),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(context.r(16)),
              ),
            ),
            SizedBox(height: context.r(14)),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: context.r(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(context.r(8)),
                    ),
                  ),
                ),
                SizedBox(width: context.r(10)),
                Container(
                  width: context.r(70),
                  height: context.r(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(context.r(8)),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.r(10)),
            Container(
              height: context.r(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(context.r(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
