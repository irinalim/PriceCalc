import 'package:PriceCalc/Models/item.dart';
import 'package:PriceCalc/Models/user.dart';
import 'package:PriceCalc/utils/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:PriceCalc/Components/Home-Drawer.dart';
import 'package:PriceCalc/utils/styles.dart';
import 'package:firebase_database/firebase_database.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _priceController = new TextEditingController();
  final TextEditingController _weightController = new TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;
  Item item = Item("", 0, 0, 0, "", "");
  List<Item> savedItems = List();
  String priceForKilo = '';
  int radioValue = 0;
  String currency = 'EUR';
  User user = User("", "", "");

  void _clearTextFields() {
    FocusScope.of(context).unfocus();
    setState(() {
      _priceController.clear();
      _weightController.clear();
      priceForKilo = "";
    });
  }

  void calcPrice() {
    FocusScope.of(context).unfocus();
    setState(() {
      double price = double.parse(_priceController.text);
      double weight = double.parse(_weightController.text);
      if (_priceController.text.isNotEmpty &&
          _priceController.text.isNotEmpty) {
        double priceDouble = 1000 * price / weight;
        priceForKilo = priceDouble.toStringAsFixed(2);
      }
    });
  }

  void handleRadioValueChanged(int value) {
    setState(() {
      radioValue = value;
//      calcPrice();
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((currentUser) {
      if (currentUser != null) {
        setState(() {
          user = User.fromSnapshot(currentUser);
        });
        databaseReference = database.reference().child("items").child(user.userId);
        databaseReference.onChildAdded.listen(_onEntryAdded);
        databaseReference.onChildChanged.listen(_onEntryChanged);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String currency = radioValue == 0 ? "EUR" : "RUB";
    return Scaffold(
      drawer: homeDrawer(user, context),
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: Text('PriceCalc'),
        centerTitle: true,
        backgroundColor: Styles.primaryBlue,
      ),
      body: WillPopScope(
        onWillPop: () async {
          return Future.value(false);
        },
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 30),
                ),
                Text(
                  user.userEmail,
                  style: TextStyle(color: Colors.red),
                ),
                Image.asset(
                  'assets/images/pricecalc.png',
                  height: 130,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  width: 350,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Choose your currency"),
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
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  width: 350,
                  alignment: Alignment.center,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            suffixText: currency,
//                          suffixIcon: Icon(Icons.euro_symbol),
                            hintText: "Price",
                            icon: Icon(Icons.monetization_on),
                          ),
                        ),
                      ),
                      Container(
                        width: 30,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Weight",
                            suffixText: "g",
                            icon: Icon(Icons.local_grocery_store),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: MaterialButton(
                    minWidth: 130,
                    onPressed: calcPrice,
                    color: Styles.primaryYellow,
                    child: Text("Calculate", style: TextStyle(fontSize: 16.9)),
                    splashColor: Theme.of(context).splashColor,
                  ),
                ),
                Container(
                  child: MaterialButton(
                    minWidth: 130,
                    onPressed: _clearTextFields,
                    color: Styles.lightGrey,
                    child: new Text("Clear",
                        style: TextStyle(color: Colors.black, fontSize: 16.9)),
                  ),
                ),
                Padding(padding: EdgeInsets.all(20)),
                _weightController.text.isEmpty && _priceController.text.isEmpty
                    ? Text(
                        "Please enter price and weight",
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        "$priceForKilo $currency/kg",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            color: Styles.primaryBlue),
                      ),
                Container(
                  child: MaterialButton(
                    minWidth: 130,
                    onPressed: () {
                      _saveItem();
                    },
                    color: Styles.lightGrey,
                    child: new Text("Save item",
                        style: TextStyle(color: Colors.black, fontSize: 16.9)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _saveItem() {
    var alert = Center(
      child: AlertDialog(
        content: Row(
          children: <Widget>[
            Expanded(
              child: Form(
                  key: formKey,
                  child: Container(
//                      height: 400,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.email),
                              hintText: 'Enter a name',
                              labelText: 'Name',
                            ),
                            initialValue: '',
                            onSaved: (val) {
                              print(item);
                              debugPrint(val);
                              item.dateAdded = dateFormatted();
                              item.name = val;
                            },
                            validator: (val) => val == "" ? val : null,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue: (_weightController.text),
                            decoration: const InputDecoration(
                              icon: Icon(Icons.email),
                              hintText: 'Enter a price',
                              labelText: 'Price',
                            ),
                            onSaved: (val) {
                              item.price = double.parse(val);
                            },
                            validator: (val) => val == "" ? val : null,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.email),
                              hintText: 'weight',
                              labelText: 'Weight',
                            ),
                            initialValue: _weightController.text,
                            onSaved: (val) {
                              item.weight = double.parse(val);
                            },
                            validator: (val) => val == "" ? val : null,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.email),
                              hintText: 'price per kilo',
                              labelText: 'price per kilo',
                            ),
                            initialValue: priceForKilo,
                            onSaved: (val) {
                              item.pricePerKilo = double.parse(val);
                            },
                            validator: (val) => val == "" ? val : null,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.email),
                              hintText: 'seller',
                              labelText: 'Seller',
                            ),
                            initialValue: '',
                            onSaved: (val) {
                              item.seller = val;
                            },
                            validator: (val) => val == "" ? val : null,
                          ),
                        ],
                      )
                      )),
            ),
          ],
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
    showDialog(
        context: context,
        builder: (context) {
          return alert;
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

//    final FormState form = formKey.currentState;
//    if (form.validate()) {
//      form.save();
//      form.reset();
//      //save form data to the database
//      databaseReference.push().set(item.toJson());
//    }}

  void _onEntryAdded(Event event) {
    setState(() {
      savedItems.add(Item.fromSnapshot(event.snapshot));
    });
  }

  void _onEntryChanged(Event event) {
    var oldEntry = savedItems.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      savedItems[savedItems.indexOf(oldEntry)] =
          Item.fromSnapshot(event.snapshot);
    });
  }
}
