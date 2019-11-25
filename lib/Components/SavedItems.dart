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

  @override
  void initState() {
    super.initState();
    databaseReference =
        database.reference().child("items").child(widget.user.userId);
    print(widget.user.userId);
    databaseReference.onChildAdded.listen(_onEntryAdded);
    databaseReference.onChildChanged.listen(_onEntryChanged);
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
                        key: Key(item),
                        child: Icon(
                          Icons.border_color,
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

  void _updateItem (item, key) {

  }

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
