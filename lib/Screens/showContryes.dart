import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:workwithapi/Screens/showcountryinformation.dart';
import 'package:workwithapi/countryPersianName.dart';

class ShowContries extends StatefulWidget {
  const ShowContries({Key key}) : super(key: key);

  @override
  _ShowContriesState createState() => _ShowContriesState();
}

class _ShowContriesState extends State<ShowContries> {
  List contries = new List();
  List items = new List();

  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              new SliverAppBar(
                title: new Text("اطلاعات کشور های مختلف برای کرونا"),
              )
            ];
          },
          body: Directionality(
              textDirection: TextDirection.rtl, child: _buildbody())),
    );
  }

  Widget _buildbody() {
    print(convertCountryISO2ToPersianName);
    if (loading) {
      return SpinKitRotatingCircle(
        color: Colors.indigo,
        size: 50,
        duration: Duration(seconds: 2),
      );
    }
    return new Container(
      child: new Column(
        children: [
          new Container(
            padding: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
            child: new TextField(
              onChanged: (String value) {
                items.clear();
                if (value.isEmpty) {
                  items.addAll(contries);
                } else {
                  contries.forEach((element) {
                    if (element['Country']
                            .toString()
                            .toLowerCase()
                            .contains(value.toLowerCase()) ||
                        element['persinName']
                            .toString()
                            .toLowerCase()
                            .contains(value.toLowerCase())) {
                      items.add(element);
                    }
                  });
                }

                setState(() {});
              },
              decoration: new InputDecoration(
                  labelText: "جستجو",
                  hintText: "جستجو",
                  prefixIcon: new Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25))),
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var country = items[index];
                  return new Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: new Material(
                      elevation: 3,
                      child: new ListTile(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Showcountryinformation(country: country);
                          }));
                        },
                        title: new Text("${country['persinName']}"),
                        subtitle: new Text("${country['Slug']}"),
                        trailing: new Container(
                          child: new Image.asset(
                              "assets/flags/${country['ISO2'].toString().toLowerCase()}.png"),
                          width: 64,
                          height: 64,
                        ),
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  void _setdata() async {
    var url = "https://api.covid19api.com/countries";

    var response = await http.get(url);
    if (response.statusCode == 200) {
      List jsonresponse = convert.jsonDecode(response.body);
      jsonresponse.forEach((element) {
        element['persinName'] =
            convertCountryISO2ToPersianName[element['ISO2']];
        print(element);
      });
      contries = jsonresponse;
      items.addAll(jsonresponse);
      setState(() {
        loading = false;
      });
    } else {}
  }
}
