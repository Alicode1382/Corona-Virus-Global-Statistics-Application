import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linear_datepicker/flutter_datepicker.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:persian_date/persian_date.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

class Showcountryinformation extends StatefulWidget {
  final country;
  Showcountryinformation({@required this.country});

  @override
  _ShowContriesinformationState createState() =>
      _ShowContriesinformationState();
}

class _ShowContriesinformationState extends State<Showcountryinformation> {
  List items = new List();

  bool loading = true;

  PersianDate persianDate = PersianDate();

  var toDate;
  var fromDate;
  var date = DateTime.now();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    toDate = date.toString().split(" ")[0];
    fromDate = DateTime(date.year, date.month - 1, date.day - 2)
        .toString()
        .split(" ")[0];
    _setdata();
  }

  @override
  Widget build(BuildContext context) {
    print(date.toString().split(" ")[0]);
    return Scaffold(
      body: _buildbody(),
      appBar: new AppBar(
        title: new Text("${widget.country['persinName']}"),
        actions: [
          new Container(
            padding: EdgeInsets.only(right: 10),
            child: new Image.asset(
                "assets/flags/${widget.country['ISO2'].toString().toLowerCase()}.png"),
            width: 64,
            height: 64,
          )
        ],
      ),
    );
  }

  Widget _buildbody() {
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
            color: Color(0xff483F97),
            child: new Column(
              children: [
                new Container(
                  height: 35,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 7),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      new GestureDetector(
                        onTap: () {},
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(padding: EdgeInsets.only(left: 10)),
                            new Text(
                              "${persianDate.gregorianToJalali("${fromDate}T00:19:54.000Z", "yyyy-m-d")}",
                              style: new TextStyle(color: Colors.white),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                      new GestureDetector(
                        onTap: () {},
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(padding: EdgeInsets.only(left: 10)),
                            new Text(
                              "${persianDate.gregorianToJalali("${toDate}T00:19:54.000Z", "yyyy-m-d")}",
                              style: new TextStyle(color: Colors.white),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  height: 80,
                  child: new Row(
                    children: [
                      showdetailcard(
                        title: "بیماران فعال",
                        number: items.last['Active'],
                        color: Color(0xffFFB259),
                      ),
                      showdetailcard(
                        title: "جانباختگان",
                        number: items.last['Deaths'],
                        color: Color(0xffce1212),
                      ),
                    ],
                  ),
                ),
                new Container(
                  height: 80,
                  child: new Row(
                    children: [
                      showdetailcard(
                        title: "بهبود یافتگان",
                        number: items.last['Recovered'],
                        color: Color(0xff1eae98),
                      ),
                      showdetailcard(
                        title: "مبتلایان جدید",
                        number: items.last['Confirmed'],
                        color: Color(0xffFF5958),
                      ),
                      showdetailcard(
                        title: "طول جغرافیایی",
                        number: items.last['Lat'],
                        color: Color(0xff00ead3),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = items[index];
                  if (index == 0) {
                    return new Container();
                  }
                  return new Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: new Material(
                      elevation: 3,
                      shadowColor: Colors.indigo,
                      child: new ListTile(
                        subtitle: new Text(
                          "${persianDate.gregorianToJalali(item['Date'], "yyyy-m-d")}",
                          style: new TextStyle(height: 1.9),
                        ),
                        title: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            new Text(
                              "مبتلایان جدید:${items[index]['Confirmed'] - items[index - 1]['Confirmed']}",
                              style: new TextStyle(fontSize: 13),
                            ),
                            new Text(
                              "بهبود یافتگان:${items[index]['Recovered'] - items[index - 1]['Recovered']}",
                              style: new TextStyle(fontSize: 13),
                            ),
                            new Text(
                              "جان باختگان:${items[index]['Deaths'] - items[index - 1]['Deaths']}",
                              style: new TextStyle(fontSize: 13),
                            )
                          ],
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
    var url =
        "https://api.covid19api.com/country/${widget.country['Slug']}?from=${fromDate}T00:00:00Z&to=${toDate}T00:00:00Z";
    print(url);

    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonresponse = convert.jsonDecode(response.body);
      items.addAll(jsonresponse);
      setState(() {
        loading = false;
      });
    } else {}
  }
}

class showdetailcard extends StatelessWidget {
  final Color color;
  String title;
  Padding padding;
  var number;
  showdetailcard({@required this.number, this.title, this.color, this.padding});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Expanded(
        child: new Container(
      padding: EdgeInsets.only(left: 10.5),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      decoration: new BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new Text(
            title,
            style: new TextStyle(color: Colors.white),
          ),
          new Text(
            "${FlutterMoneyFormatter(amount: double.parse("$number")).output.nonSymbol}",
            style: new TextStyle(color: Colors.white),
          )
        ],
      ),
    ));
  }
}
