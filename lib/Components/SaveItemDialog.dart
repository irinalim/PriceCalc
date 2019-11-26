import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:PriceCalc/utils/date_formatter.dart';
import 'package:PriceCalc/Models/item.dart';

class SaveItemDialog extends StatefulWidget {
  String userId;
  String price;
  String weight;
  String pricePerKilo;

  SaveItemDialog(
      {Key key,
      this.userId,
      this.price,
      this.weight,
      this.pricePerKilo})
      : super(key: key);

  @override
  _SaveItemDialogState createState() => _SaveItemDialogState();
}

class _SaveItemDialogState extends State<SaveItemDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;
  Item item = Item("", 0, 0, 0, "", "", "");
  int radioValue;
  String currency;

  void handleRadioValueChanged(int value) {
    setState(() {
      radioValue = value;
    });
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      form.reset();
      databaseReference.push().set(item.toJson());
    }
  }

  @override
  void initState() {
    super.initState();
    databaseReference = database.reference().child("items").child(widget.userId);
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
                key: formKey,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Bread',
                          labelText: 'Name',
                        ),
                        initialValue: '',
                        onSaved: (val) {
                          print(item);
                          item.dateAdded = dateFormatted();
                          item.name = val;
                          item.currency = currency;
                        },
                        validator: (val) => val == "" ? val : null,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        initialValue: widget.price,
                        decoration: const InputDecoration(
                          hintText: 'Enter price',
                          labelText: 'Price',
                        ),
                        onSaved: (val) {
                          item.price = double.parse(val);
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
                        initialValue: widget.weight,
                        onSaved: (val) {
                          item.weight = double.parse(val);
                        },
                        validator: (val) => val == "" ? val : null,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Price per kilo',
                          labelText: 'Price per kilo',
                        ),
                        initialValue: widget.pricePerKilo,
                        onSaved: (val) {
                          item.pricePerKilo = double.parse(val);
                        },
                        validator: (val) => val == "" ? val : null,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Lidl',
                          labelText: 'Seller',
                        ),
                        initialValue: '',
                        onSaved: (val) {
                          item.seller = val;
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
              handleSubmit();
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
