import 'package:flutter/material.dart';

import '../model/store_address.dart';

class StoreAddressListItem extends StatelessWidget {
  final StoreAddress storeAddress;
  const StoreAddressListItem({super.key, required this.storeAddress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: IntrinsicHeight(
        child: Row(children: [
          const Center(
            child: Icon(Icons.location_pin),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(storeAddress.name!),
                const SizedBox(
                  height: 5,
                ),
                Text(storeAddress.address!)
              ],
            ),
          )
        ]),
      ),
    );
  }
}
