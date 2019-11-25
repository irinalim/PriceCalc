import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';

class Item {
  String key;
  String name;
  double price;
  double pricePerKilo;
  double weight;
  String seller;
  String dateAdded;

  Item(this.name, this.price, this.pricePerKilo, this.weight, this.seller, this.dateAdded);

  Item.fromSnapshot(DataSnapshot snapshot)
      :
        key = snapshot.key,
        name = snapshot.value["name"],
        price = double.parse(snapshot.value["price"].toString()),
        pricePerKilo = double.parse(snapshot.value["pricePerKilo"].toString()),
        weight = double.parse(snapshot.value["weight"].toString()),
        seller = snapshot.value["seller"],
        dateAdded = snapshot.value["dateAdded"];

  toJson() {
    return {
      "name": name,
      "price" : price,
      "pricePerKilo": pricePerKilo,
      "weight": weight,
      "seller": seller,
      "dateAdded": dateAdded,
    };
  }
}

