import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/app_details/color.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../widget/home_screen_widget/home_button.dart';
import '../../../../widget/textField.dart';

class Exchange extends StatefulWidget {
  const Exchange(
      {super.key,
      required this.cod,
      required this.oId,
      required this.updateBTN,
      required this.waybill});
  final String waybill;
  final bool updateBTN;
  final String cod;
  final String oId;
  @override
  State<Exchange> createState() => _ExchangeState();
}

class _ExchangeState extends State<Exchange> {
  TextEditingController name = TextEditingController();
  String newImage = '';
  final ImagePicker _picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 220, 247, 255),
      appBar: AppBar(
        iconTheme: IconThemeData(color: white),
        backgroundColor: appliteBlue,
        title: Text(
          'exchange',
          style: TextStyle(color: white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 20,
            ),
            Text('Old waybill',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: black2,
                  fontSize: 15.dp,
                )),
            SizedBox(
              height: 8,
            ),
            CustomTextField(
              controller: name,
              icon: Icons.access_time_filled,
              text: 'type here',
            ),
            SizedBox(
              height: 20,
            ),
            Text('New waybill',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: black2,
                  fontSize: 15.dp,
                )),
            SizedBox(
              height: 8,
            ),
            CustomTextField(
              controller: name,
              icon: Icons.account_tree_sharp,
              text: 'type here',
            ),
            SizedBox(
              height: 20,
            ),
            Text('New Return Exchange',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: black2,
                  fontSize: 15.dp,
                )),
            SizedBox(
              height: 8,
            ),
            CustomTextField(
              controller: name,
              icon: Icons.add_home,
              text: 'type here',
            ),
            SizedBox(
              height: 20,
            ),
            Text('Image Upload',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: black2,
                  fontSize: 15.dp,
                )),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                newImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: Container(
                            height: h / 7,
                            width: w / 2.2,
                            child: Image.file(
                              File(newImage),
                              fit: BoxFit.cover,
                            )))
                    : DottedBorder(
                        color: Colors.black38,
                        borderType: BorderType.RRect,
                        radius: Radius.circular(12),
                        padding: EdgeInsets.all(6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          child: Container(
                            alignment: Alignment.center,
                            height: h / 7,
                            width: w / 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 40,
                                  color: const Color.fromARGB(96, 77, 76, 76),
                                ),
                                Text('Please upload \nyour image',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black38,
                                      fontSize: 12.dp,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(
                            imageQuality: 25, source: ImageSource.camera);

                        setState(() {
                          newImage = image!.path;
                        });
                      },
                      child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              color: Colors.black38,
                              Icons.camera_alt,
                            ),
                          )),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(
                            imageQuality: 25, source: ImageSource.gallery);

                        setState(() {
                          newImage = image!.path;
                        });

                        // source
                      },
                      child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              color: Colors.black38,
                              Icons.photo,
                            ),
                          )),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: HomeButton(
                onTap: () {},
                text: 'COLLECT',
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
