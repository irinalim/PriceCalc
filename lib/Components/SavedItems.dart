import 'package:PriceCalc/Models/item.dart';
import 'package:PriceCalc/Models/user.dart';
import 'package:PriceCalc/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SavedItems extends StatefulWidget {
  final User user;

  SavedItems({Key key, this.user}) : super(key: key);

  @override
  _SavedItemsState createState() => _SavedItemsState();
}

class _SavedItemsState extends State<SavedItems> {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;
  List<Item> savedItems = List();
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    databaseReference =
        database.reference().child("items").child(widget.user.userId);
    print(widget.user.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.primaryYellow,
        title: Text(
          "Saved Items",
          style: TextStyle(color: Styles.blueGrey),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return BackButton(
              color: Styles.blueGrey,
            );
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: FirebaseAnimatedList(
                query: databaseReference,
                itemBuilder: (_, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  if (snapshot == null) {
                    return Container(
                      height: 300,
                      child: ModalProgressHUD(
                        color: Colors.transparent,
                        progressIndicator: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Styles.primaryBlue),
                        ),
                        inAsyncCall: true,
                        child: Center(
                          child: Text(
                            "Загружается...",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }
                  var item = Item.fromSnapshot(snapshot);
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.shopping_cart,
                        color: Styles.primaryBlue,
                      ),
                      title: Text(item.name),
                      subtitle: Text(item.seller),
                      onTap: () => showItem(item, snapshot.key),
                      trailing: Text(item.pricePerKilo.toString(), style: Styles.header2TextStyle,)
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  void showItem(item, key) {
    Widget ItemCard = AlertDialog(
      title: Text("Saved Item"),
      content: Container(
        height: 180,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "Name: ${item.name}",
                style: Styles.header5TextStyle,
                textAlign: TextAlign.left,
              ),
              Text(
                "Seller: ${item.seller}",
                style: Styles.header5TextStyle,
                textAlign: TextAlign.left,
              ),
              Text(
                "Price: ${item.price}",
                style: Styles.header5TextStyle,
                textAlign: TextAlign.left,
              ),
              Text(
                "Weight: ${item.weight}",
                style: Styles.header5TextStyle,
                textAlign: TextAlign.left,
              ),
              Text(
                "Price per kilo: ${item.pricePerKilo}",
                style: Styles.header5TextStyle,
                textAlign: TextAlign.left,
              ),
              Text(
                "Added: ${item.dateAdded}",
                style: Styles.header5TextStyle,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            _deleteItem(key);
            Navigator.of(context).pop();
          },
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.red),
          ),
        ),
        FlatButton(
          onPressed: () {
            _updateItem(item, key);
            Navigator.of(context).pop();
          },
          child: Text(
            "Update", style: TextStyle(color: Colors.green),
          ),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Close"),
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return ItemCard;
        });
  }

  _deleteItem(key) {
    databaseReference.child(key).remove();
  }

  void _updateItem(item, key) {
    var alert = Center(
      child: AlertDialog(
        content: Container(
          height: 400,
          width: 250,
          child: ListView(
            children: <Widget>[
              Form(
                  key: formKey2,
                  child: Container(
                      height: 420,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter a name',
                              labelText: 'Name',
                            ),
                            initialValue: item.name,
                            onSaved: (val) {
                              item.name = val;
                            },
                            validator: (val) => val == "" ? val : null,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue: item.price.toString(),
                            decoration: const InputDecoration(
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
                              hintText: 'weight',
                              labelText: 'Weight',
                            ),
                            initialValue: item.weight.toString(),
                            onSaved: (val) {
                              item.weight = double.parse(val);
                            },
                            validator: (val) => val == "" ? val : null,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'price per kilo',
                              labelText: 'price per kilo',
                            ),
                            initialValue: item.pricePerKilo.toString(),
                            onSaved: (val) {
                              item.pricePerKilo = double.parse(val);
                            },
                            validator: (val) => val == "" ? val : null,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'seller',
                              labelText: 'Seller',
                            ),
                            initialValue: item.seller,
                            onSaved: (val) {
                              item.seller = val;
                            },
                            validator: (val) => val == "" ? val : null,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'date',
                              labelText: 'Date',
                            ),
                            initialValue: item.dateAdded,
                            onSaved: (val) {
                              item.dateAdded = val;
                            },
                            validator: (val) => val == "" ? val : null,
                          ),
                        ],
                      )))
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            color: Colors.white,
            onPressed: () {
              handleUpdate(item, key);
              Navigator.pop(context);
            },
            child: Text("Update"),
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
}
