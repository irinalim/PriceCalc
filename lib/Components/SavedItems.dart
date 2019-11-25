import 'package:PriceCalc/Models/item.dart';
import 'package:PriceCalc/Models/user.dart';
import 'package:PriceCalc/utils/date_formatter.dart';
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
        title: Text("Saved Items"),
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
                      title: Text(item.name),
                      subtitle: Text(item.pricePerKilo.toString()),
                      onTap: () {
                        showItem(item);
                      },
                      trailing: Listener(
                        key: Key(snapshot.key),
                        child: Icon(
                          Icons.create,
                          color: Colors.black54,
                        ),
                        onPointerDown: (pointerEvent) =>
                            _updateItem(item, snapshot.key),
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  void showItem(item) {
    Widget ItemCard = AlertDialog(
      title: Text("Saved Item"),
      content: Container(
        height: 120,
        child: Center(
          child: Column(
            children: <Widget>[
              Text("Name: ${item.name}"),
              Text("Seller: ${item.seller}"),
              Text("Price: ${item.price}"),
              Text("Weight: ${item.weight}"),
              Text("Price per kilo: ${item.pricePerKilo}"),
              Text("Added: ${item.dateAdded}"),
            ],
          ),
        ),
      ),
      actions: <Widget>[
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

  void _updateItem(item, key) {
    var alert = Center(
      child: AlertDialog(
        content: Row(
          children: <Widget>[
            Expanded(
              child: Form(
                  key: formKey2,
                  child: Container(
                      height: 400,
                      child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email),
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
                        initialValue: item.weight.toString(),
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
                        initialValue: item.pricePerKilo.toString(),
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
                        initialValue: item.seller,
                        onSaved: (val) {
                          item.seller = val;
                        },
                        validator: (val) => val == "" ? val : null,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email),
                          hintText: 'date',
                          labelText: 'Date',
                        ),
                        initialValue: item.dateAdded,
                        onSaved: (val) {
                          item.seller = val;
                        },
                        validator: (val) => val == "" ? val : null,
                      ),
                    ],
                  ))),
            ),
          ],
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
