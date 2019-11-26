import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:PriceCalc/utils/date_formatter.dart';
import 'package:PriceCalc/Models/item.dart';

class UpdateItemDialog extends StatefulWidget {
  final String userId;
  final String itemKey;
   Item item;

  UpdateItemDialog(
      {Key key,
        this.userId,
        this.itemKey,
        this.item,
      })
      : super(key: key);

  @override
  _UpdateItemDialogState createState() => _UpdateItemDialogState();
}

class _UpdateItemDialogState extends State<UpdateItemDialog> {
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();
  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;
  int radioValue;
  String currency;

  void handleRadioValueChanged(int value) {
    setState(() {
      radioValue = value;
    });
  }

  void handleUpdate(item, key) {
    final FormState form = formKey2.currentState;
    if (form.validate()) {
      form.save();
      form.reset();
      databaseReference.child(key).set(item.toJson());
    }
    debugPrint(key);
    debugPrint("$item");
  }

  @override
  void initState() {
    super.initState();
    databaseReference = database.reference().child("items").child(widget.userId);
    radioValue = widget.item.currency == "EUR" ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    String currency = radioValue == 0 ? "EUR" : "RUB";
    return Center(
      child: AlertDialog(
        content: Container(
          height: 400,
          width: 250,
          child: ListView(
            children: <Widget>[
              Form(
                key: formKey2,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Bread',
                          labelText: 'Name',
                        ),
                        initialValue: widget.item.name,
                        onSaved: (val) {
                          widget.item.name = val;
                          widget.item.currency = currency;
                        },
                        validator: (val) => val == "" ? val : null,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        initialValue: widget.item.price.toString(),
                        decoration: const InputDecoration(
                          hintText: 'Enter price',
                          labelText: 'Price',
                        ),
                        onSaved: (val) {
                          widget.item.price = double.parse(val);
                        },
                        validator: (val) => val == "" ? val : null,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Currency"),
                          Radio<int>(
                            value: 0,
                            groupValue: radioValue,
                            onChanged: handleRadioValueChanged,
                          ),
                          Text('EUR'),
                          Radio<int>(
                            value: 1,
                            groupValue: radioValue,
                            onChanged: handleRadioValueChanged,
                          ),
                          Text('RUB')
                        ],
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter weight',
                          labelText: 'Weight',
                          suffixText: "g",
                        ),
                        initialValue: widget.item.weight.toString(),
                        onSaved: (val) {
                          widget.item.weight = double.parse(val);
                        },
                        validator: (val) => val == "" ? val : null,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Price per kilo',
                          labelText: 'Price per kilo',
                        ),
                        initialValue: widget.item.pricePerKilo.toString(),
                        onSaved: (val) {
                          widget.item.pricePerKilo = double.parse(val);
                        },
                        validator: (val) => val == "" ? val : null,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Lidl',
                          labelText: 'Seller',
                        ),
                        initialValue: widget.item.seller,
                        onSaved: (val) {
                          widget.item.seller = val;
                        },
                        validator: (val) => val == "" ? val : null,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "10:20, Nov 21, 2019",
                          labelText: 'Date',
                        ),
                        initialValue: widget.item.dateAdded,
                        onSaved: (val) {
                          widget.item.dateAdded = val;
                        },
                        validator: (val) => val == "" ? val : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            color: Colors.white,
            onPressed: () {
              handleUpdate(widget.item, widget.itemKey);
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          )
        ],
      ),
    );
  }
}
