import 'package:PriceCalc/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:PriceCalc/utils/date_formatter.dart';
import 'package:PriceCalc/Models/item.dart';

class SaveItemDialog extends StatefulWidget {
  final String userId;
  final String price;
  final String weight;
  final String pricePerKilo;
  final String currency;

  SaveItemDialog(
      {Key key,
      this.userId,
      this.price,
      this.weight,
      this.pricePerKilo,
      this.currency})
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

  void handleRadioValueChanged(int value) {
    setState(() {
      radioValue = value;
    });
  }

  void calcPrice(price, weight) {
//    debugPrint("Calvulated PPK" + item.pricePerKilo.toString());
    setState(() {
      item.pricePerKilo = double.parse((1000 * price / weight).toStringAsFixed(2));
    });
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      form.reset();
      if (widget.pricePerKilo == null || widget.pricePerKilo == '') {
        calcPrice(item.price, item.weight);
      } else {
        item.pricePerKilo = double.parse(widget.pricePerKilo);
      }

//      debugPrint("PPK is ${(item.pricePerKilo).toString()}");
      databaseReference.push().set(item.toJson());
    }
  }

  @override
  void initState() {
    super.initState();
    databaseReference = database.reference().child("items").child(widget.userId);
    radioValue = widget.currency == 'EUR' ? 0 : 1;
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
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).translate('hint_item'),
                          labelText: AppLocalizations.of(context).translate('name'),
                        ),
                        initialValue: '',
                        onSaved: (val) {
                          print(item);
                          item.dateAdded = dateFormatted();
                          item.name = val;
                          item.currency = currency;
//                          item.pricePerKilo = ;
                        },
                        validator: (val) => val == "" ? val : null,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        initialValue: widget.price,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).translate('enter_price'),
                          labelText: AppLocalizations.of(context).translate('price'),
                        ),
                        onSaved: (val) {
                          item.price = double.parse(val);
                        },
                        validator: (val) => val == "" ? val : null,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(AppLocalizations.of(context).translate('currency')),
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
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).translate('enter_weight'),
                          labelText: AppLocalizations.of(context).translate('weight'),
                          suffixText: AppLocalizations.of(context).translate('gram'),
                        ),
                        initialValue: widget.weight,
                        onSaved: (val) {
                          item.weight = double.parse(val);
                        },
                        validator: (val) => val == "" ? val : null,
                      ),
//                      TextFormField(
//                        enabled: false,
//                        enableInteractiveSelection: false,
//                        focusNode: FocusNode(),
//                        keyboardType: TextInputType.number,
//                        decoration: const InputDecoration(
//                          hintText: 'Price per kilo',
//                          labelText: 'Price per kilo',
//                        ),
//                        initialValue: widget.pricePerKilo,
//                        onSaved: (val) {
//                          item.pricePerKilo = double.parse(val);
//                        },
//                        validator: (val) => val == "" ? val : null,
//                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).translate('hint_seller'),
                          labelText: AppLocalizations.of(context).translate('seller'),
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
            child: Text(AppLocalizations.of(context).translate('save')),
          ),
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          )
        ],
      ),
    );
  }
}
