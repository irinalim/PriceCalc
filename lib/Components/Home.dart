import 'package:PriceCalc/Components/Login.dart';
import 'package:PriceCalc/Models/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:PriceCalc/Components/Home-Drawer.dart';
import 'package:PriceCalc/utils/styles.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _priceController = new TextEditingController();
  final TextEditingController _weightController = new TextEditingController();
  String priceForKilo = '';
  int radioValue = 0;
  String currency = 'EUR';
  User user;

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
                Text(user.userId + user.userEmail),
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
                RaisedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: Text('Sign in with Google'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
