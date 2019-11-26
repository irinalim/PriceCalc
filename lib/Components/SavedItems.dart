import 'package:PriceCalc/Components/SaveItemDialog.dart';
import 'package:PriceCalc/Models/item.dart';
import 'package:PriceCalc/Models/user.dart';
import 'package:PriceCalc/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'UpdateItemDialog.dart';

class SavedItems extends StatefulWidget {
  final User user;

  SavedItems({Key key, this.user}) : super(key: key);

  @override
  _SavedItemsState createState() => _SavedItemsState();
}

class _SavedItemsState extends State<SavedItems> {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    databaseReference =
        database.reference().child("items").child(widget.user.userId);
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_to_photos),
            onPressed: (){
              showDialog(
                  context: context,
                  builder: (context) {
                    return SaveItemDialog(
                      userId: widget.user.userId,
                    );
                  });
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: FirebaseAnimatedList(
                sort: (DataSnapshot a, DataSnapshot b) =>
                    a.value["name"].compareTo(b.value["name"]),
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
                        trailing: Text(
                          item.pricePerKilo.toString(),
                          style: Styles.header2TextStyle,
                        )),
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
                "Price: ${item.price} ${item.currency}",
                style: Styles.header5TextStyle,
                textAlign: TextAlign.left,
              ),
              Text(
                "Weight: ${item.weight} g",
                style: Styles.header5TextStyle,
                textAlign: TextAlign.left,
              ),
              Text(
                "Price per kilo: ${item.pricePerKilo} ${item.currency}",
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
            Navigator.of(context).pop();
            debugPrint("UPDATE");
            {
              showDialog(
                  context: context,
                  builder: (context) {
                    return UpdateItemDialog(
                      userId: widget.user.userId,
                      item: item,
                      itemKey: key,
                    );
                  });
            }
          },
          child: Text(
            "Update",
            style: TextStyle(color: Colors.green),
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
}
