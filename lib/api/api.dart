import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:app_install_date/app_install_date.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/app_details/color.dart';
import 'package:flutter_application_2/class/class.dart';
import 'package:flutter_application_2/provider/provider.dart';
import 'package:flutter_application_2/uI/app_agreement/agreement.dart';
import 'package:flutter_application_2/uI/login_and_signup/otp.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import '../app_details/const.dart';
import '../uI/login_and_signup/login.dart';
import '../uI/main/navigation/navigation.dart';

class CustomApi {
//user location read

  userLocation(String userid, String lat, String long) async {
    Map<String, String> headers = {
      'userkey': '$userid',
    };
    var urll = '${ApiUrl}/Riderlocation/users';
    await https.post(
        headers: headers, Uri.parse(urll), body: {'lati': lat, 'longt': long});
  }

// splash screen api  this api checking user first time login and after login detail ,if user
  checkFirstSeen(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = await Permission.location.request();
    Provider.of<ProviderS>(context, listen: false).permission = status;
    bool _seen = (prefs.getBool('seen') ?? false);
    if (_seen) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        var urll = '${ApiUrl}/Version/users';
        var res = await https.post(Uri.parse(urll), body: {});
        var responce = jsonDecode(res.body);
        print(responce);
        if (responce == "3.0") {
          late String installDate;
          final DateTime date = await AppInstallDate().installDate;
          installDate = date.toString();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var rKey = await prefs.getString('rKey');
          String key = rKey.toString();
          var name = await prefs.getString('uName');
          String userName = name.toString();

          print(userName);
          print(key);
          if (key != 'null' && userName != 'null') {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            final String? userKey = await prefs.getString('userkey');
            print(userKey);
            late String installDate;
            final DateTime date = await AppInstallDate().installDate;
            installDate = date.toString();
            Map<String, String> headers = {
              'userkey': '$userKey',
            };
            var urll = '${ApiUrl}/Remember/users';
            var res = await https.post(
                headers: headers,
                Uri.parse(urll),
                body: {'imei': key, 'app_date': installDate});
            var responce = jsonDecode(res.body);

            print(
                '$responce dddddddddddddddddddddddaaaaaaaaaaaaaaaaaaaaaaaaa $key ddddddddddddddddd    $installDate');

            if (responce['userkey'] == userKey) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NavigationScreen(
                        staffId: userName,
                        userId: responce['userkey'],
                      )));
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Login()));
            }
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Login()));
          }
        } else {
          notification().info(context, 'Please Download The New Version');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              actions: [
                TextButton(
                    onPressed: () {
                      exit(0);
                    },
                    child: Text('IGNORE')),
                TextButton(onPressed: () {}, child: Text('UPDATE NOW'))
              ],
              content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Update App ?',
                      style: TextStyle(
                          fontSize: 22,
                          color: black1,
                          // fontFamily: 'KodeMono',
                          fontWeight: FontWeight.normal),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'A New version of upgrade available',
                      style: TextStyle(
                          fontSize: 17,
                          color: black1,
                          // fontFamily: 'KodeMono',
                          fontWeight: FontWeight.normal),
                    ),
                  ]),
            ),
          );
        }
      } else {
        notification().warning(context, 'No Internet');
      }
    } else {
      await prefs.setBool('seen', true);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Condition()));
    }
  }

  // user login

  login(String userNameController, BuildContext context) async {
    String username = userNameController;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      var urll = '${ApiUrl}Loginn/users';
      var response =
          await https.post(Uri.parse(urll), body: {'username': username});

      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['status'] == 200) {
        String userkey = map['userkey'].toString();

        print(userkey);

        print(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userkey', userkey);

        Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              child: OTP(userId: userkey, userName: username),
              inheritTheme: true,
              ctx: context),
        );
      } else if (map['status'] == 400) {
        notification().info(context, 'Bad Request: Error Occurred');
      } else if (map['status'] == 403) {
        notification().info(context, 'Forbidden: Deactivated Account');
      } else if (map['status'] == 404) {
        notification().info(context, 'Invalid Username');
      }
    } else {
      notification().warning(context, 'No Internet');
    }
  }

//  otp screen otp api call function
  setOtp(String otp, String userKey, BuildContext context) async {
    String otpnumber = otp;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      print(userKey);
      print(otpnumber);
      final apiUrl = '${ApiUrl}/Verifyotp/users';
      // Headers
      Map<String, String> headers = {
        'userkey': '$userKey',
      };
      // Make POST request
      var res = await https.post(headers: headers, Uri.parse(apiUrl), body: {
        'otp': '$otpnumber',
      });

      Map<String, dynamic> map = jsonDecode(res.body);

      Map<String, dynamic> userData = map['userdata'];
      print(userData['username']);

      if (map['status'] == 202) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String username = userData['username'].toString();
        String userId = userData['user_id'].toString();
        var res = await prefs.setString("user_id", userId);
        late String installDate;
        final DateTime date = await AppInstallDate().installDate;
        installDate = date.toString();
        const _chars =
            'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
        Random _rnd = Random();
        String getRandomString(int length) =>
            String.fromCharCodes(Iterable.generate(
                length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
        var randomKey = await getRandomString(50);
        var temp = await DateTime.now().toString();
        await prefs.setString('rKey', randomKey + temp);
        await prefs.setString('uName', username);
        final apiUrl = '${ApiUrl}/Saveid/users';
        var resp = await https.post(headers: headers, Uri.parse(apiUrl), body: {
          "imei": randomKey + temp,
          "app_date": "$installDate",
        });
        String staffName = userData['staff_name'];
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NavigationScreen(
                  staffId: staffName,
                  userId: userKey,
                )));
      } else {
        notification().info(context, 'Invalid OTP');
      }
    } else {
      notification().warning(context, 'No Internet');
    }
  }

// new notification count

  Future notificationCount(String userId) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final apiUrl = '${ApiUrl}NotifictionCount/users';
      // Headers

      Map<String, String> headers = {
        'userkey': '$userId',
      };
      print(userId);
      // Make POST request
      var res = await https.post(headers: headers, Uri.parse(apiUrl), body: {});
      List map = jsonDecode(res.body);
      print(map);
      print('111111111111111111111111111111111111111111');
      var noti_count = map[0]['noticount'].toString();
      if (noti_count == "null") {
        noti_count = "0";
      } else if (noti_count == '0.0') {
        noti_count = "0";
      }

      var ncount = noti_count;

      print(ncount);
      return ncount;
    }
  }

// notification screen data
  Future getMyNotification(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userkey');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      final apiUrl = '${ApiUrl}Notification/users';
      // Headers
      Map<String, String> headers = {
        'userkey': '$id',
      };
      // Make POST request
      var resp =
          await https.post(headers: headers, Uri.parse(apiUrl), body: {});
      print(resp.body);
      print('notification list');
      var data = jsonDecode(resp.body);
      return data;
    } else {
      notification().warning(context, 'No Internet');
    }
  }

  Future<void> notificationMarkAsRead(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userkey');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      final apiUrl = '${ApiUrl}Readnotifi/users';
      // Headers
      Map<String, String> headers = {
        'userkey': '$id',
      };
      // Make POST request
      var resp =
          await https.post(headers: headers, Uri.parse(apiUrl), body: {});
      print(resp.body);
      print('Readnotifi');
    } else {
      notification().warning(context, 'No Internet');
    }
  }

// dash board custom data

  Future dashboardData(String userId) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      final apiUrl = '${ApiUrl}Pickup_dashboard/users';
      // Headers
      Map<String, String> headers = {
        'userkey': '$userId',
      };
      // Make POST request
      var resp =
          await https.post(headers: headers, Uri.parse(apiUrl), body: {});

      var map = jsonDecode(resp.body);
      return map;
    }
  }

// oder screen data calling
  getmyorders(String sWaybill, String userID, BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? id = await prefs.getString('userkey');
      Map<String, String> headers = {
        'userkey': '$id',
      };
      if (sWaybill == '') {
        print(userID);
        final apiUrl = '${ApiUrl}/Pendings/users';
        // Headers

        // Make POST request
        var resp =
            await https.post(headers: headers, Uri.parse(apiUrl), body: {});

        print(resp.body);
        return List<Map>.from(jsonDecode(resp.body) as List);
      } else {
        final apiUrl = '${ApiUrl}/Singleorder/users';
        // Headers

        // Make POST request
        var resp = await https.post(
            headers: headers,
            Uri.parse(apiUrl),
            body: {'status': '5,7', 'search': sWaybill});

        print(resp.body);

        return List<Map>.from(jsonDecode(resp.body) as List);
      }
    } else {
      notification().warning(context, 'No Internet');
    }
  }

// my all orders screen data
  getAllOrders(String sWaybill, String userID, BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? id = await prefs.getString('userkey');
      if (sWaybill == '') {
        print('ddddddddddddddddddddd');
        print(userID);
        final apiUrl = '${ApiUrl}/Allorders/users';
        // Headers
        Map<String, String> headers = {
          'userkey': '$id',
        };
        // Make POST request
        var resp =
            await https.post(headers: headers, Uri.parse(apiUrl), body: {});
        print(resp.body);
        return List<Map>.from(jsonDecode(resp.body) as List);
      } else {
        print('ddssssssssssssssssssssssssssssssssssddddddddddddddddddd');
        final apiUrl = '${ApiUrl}/Singleorder/users';
        // Headers
        Map<String, String> headers = {
          'userkey': '$id',
        };
        // Make POST request
        var resp = await https.post(
            headers: headers,
            Uri.parse(apiUrl),
            body: {'status': '5,7', 'search': sWaybill});
        print(resp.body);

        return List<Map>.from(jsonDecode(resp.body) as List);
      }
    } else {
      notification().warning(context, 'No Internet');
    }
  }
//user account data

  Future getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userkey');
    final apiUrl = '${ApiUrl}/Profile/users';
    // Headers
    Map<String, String> headers = {
      'userkey': '$id',
    };
    // Make POST request
    var res = await https.post(headers: headers, Uri.parse(apiUrl), body: {});
    print(res.body);
    print('notification count');

    List map = jsonDecode(res.body);

    return map;
  }

  getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userkey');

    return id;
  }
// image upload  my delivery screen

  // uploadssImage(BuildContext context, XFile? image, String waybillId) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String? id = await prefs.getString('userkey');
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.mobile ||
  //       connectivityResult == ConnectivityResult.wifi) {
  //     if (image != null) {
  //       var headers = {'userkey': id};

  //       Dio dio = Dio();
  //       // progress = 0.0;
  //       final apiUrl = '${ApiUrl}/Image/users';
  //       // String uploadURL =
  //       //     "https://api.koombiyodelivery.lk/staffapi/v2/delivery/Image/users"; // Replace with your server's upload URL

  //       FormData formData = FormData.fromMap({
  //         "image": await MultipartFile.fromFile(image.path),
  //         "user_id": id,
  //         "waybill_id": waybillId,
  //       });
  //       try {
  //         await dio.post(
  //           options: Options(
  //             method: 'POST',
  //             headers: headers,
  //           ),
  //           apiUrl,
  //           data: formData,
  //           onSendProgress: (sent, total) {
  //             Provider.of<ProviderS>(context, listen: false).progress =
  //                 sent / total;
  //           },
  //         );

  //         //Fluttertoast.showToast(msg: 'Image uploaded successfully');
  //       } catch (error) {
  //         // Fluttertoast.showToast(msg: 'Error uploading image');
  //       }
  //     }
  //   } else {
  //     notification().warning(context, 'No Internet');
  //   }
  // }

// delivery  oder data this function use 3 api for same dialog   ,and use image upload
  oderData(
      int statusType,
      String wayBillId,
      BuildContext context,
      String dropdownValue,
      String dropdownValue2,
      String cod,
      String rescheduleDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userkey');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      Map<String, String> headers = {
        'userkey': '$id',
      };
      if (statusType == 1) {
        final apiUrl = '${ApiUrl}/Delivered/users';
        // Headers

        // Make POST request
        var res = await https.post(
            headers: headers,
            Uri.parse(apiUrl),
            body: {'owner': id, 'waybill_id': wayBillId, 'status': '17'});
        print('2222222222222222222222222222222222222222');
        print(res.body);
        var data = jsonDecode(res.body);
//         - 200 OK: Order Delivered Successfully
// - 400 Bad Request: Error Occurred
// - 406 Not Acceptable: Please Upload the POD
// - 403 Forbidden: Invalid User Key
        if (data['status'] == 200) {
          notification().info(context, 'Order Delivered Successfully');
          Navigator.pop(context);
        } else if (data['status'] == 400) {
          notification().info(context, 'Bad Request: Error Occurred');
        } else if (data['status'] == 406) {
          notification().info(context, 'Not Acceptable: Please Upload the POD');
        }

        // var url =
        //     'https://api.koombiyodelivery.lk/staffapi/v2/delivery/Delivered/users';
        // var responses = await https.post(Uri.parse(url),
        //     body: {'owner': id, 'waybill_id': wayBillId, 'status': '17'});
        // String rawJson = responses.body.toString();
        // final newString = rawJson.replaceAll('"', '');

        // notification().info(context, newString.toString());
        return data['status'];
      } else if (statusType == 2) {
        if (dropdownValue != '') {
          if (cod != '') {
            final apiUrl = '${ApiUrl}/Pdelivery/users';

            var responses =
                await https.post(headers: headers, Uri.parse(apiUrl), body: {
              'owner': id,
              'waybill_id': wayBillId,
              'status': '19',
              'reason': dropdownValue,
              'pcod': cod
            });
            var data = jsonDecode(responses.body);
            if (data['status'] == 200) {
              notification().info(context, 'Order Update Successfully');
              Navigator.pop(context);
            } else if (data['status'] == 400) {
              notification().info(context, 'Bad Request: Order Update Failed');
            } else if (data['status'] == 406) {
              notification()
                  .info(context, 'Not Acceptable: Please Upload the POD');
            }

            return data['status'];
          } else {
            notification().info(context, 'Collected COD ?');
          }
        } else {
          notification().info(context, 'Please Select a Reason');
        }
      } else if (statusType == 3) {
        if (dropdownValue2 != '') {
          final apiUrl = '${ApiUrl}/Reshedule/users';
          var responses =
              await https.post(headers: headers, Uri.parse(apiUrl), body: {
            'waybill_id': wayBillId,
            'status': '7',
            'reason': dropdownValue2.toString(),
            'rdate': rescheduleDate,
          });
          var data = jsonDecode(responses.body);
          if (data['status'] == 200) {
            notification().info(context, 'Order Delivered Successfully');
            Navigator.pop(context);
          } else if (data['status'] == 400) {
            notification().info(context, 'Bad Request: Order Update Failed');
          } else if (data['status'] == 406) {
            notification()
                .info(context, 'Not Acceptable: Please Try Again on Tomorrow');
          } else if (data['status'] == 409) {
            notification()
                .info(context, 'Conflict: Please Submit the Correct Date');
          } else if (data['status'] == 410) {
            notification().info(context, 'Gone: Error Occurred ');
          }

          return data['status'];
        } else {
          notification().info(context, 'Please Select the Update Type');
        }
      } else {
        notification().info(context, 'Please Select the Reason');
      }
    } else {
      notification().warning(context, 'No Internet');
    }
  }

  // map screen api

  // get map pickup location list   // map Screen
// this api use for get pickup list and it show in map
  Future getmypickups(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userkey');

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      final apiUrl = '${ApiUrl}/Pickupmap/users';
      // Headers
      Map<String, String> headers = {
        'userkey': '$id',
      };
      var resp =
          await https.post(headers: headers, Uri.parse(apiUrl), body: {});
      return jsonDecode(resp.body);
    } else {
      notification().warning(context, 'No Internet');
    }
  }

// after calling above api user to send msg  and above map marker hide
// send msg api for customer
  sendSms(String phone, String pickId, BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? id = await prefs.getString('userkey');
      final apiUrl = '${ApiUrl}/Smspickup/users';
      // Headers
      Map<String, String> headers = {
        'userkey': '$id',
      };
      var response = await https.post(
          headers: headers,
          Uri.parse(apiUrl),
          body: {'phone': phone, 'pick_id': pickId});

      if (response.body == '"SMS Sent To Client.."') {
        notification().info(context, 'SMS Sent To Client..');
      } else {}
      return response.body;
    } else {
      notification().warning(context, 'No Internet');
    }
  }

// map Screen
  // this api use  after pickup and rider accept it
  // this api use for  after accept pickup location show in map
  Future getMyPDeliveryMap(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userkey');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      final apiUrl = '${ApiUrl}/Deliverymap/users';
      // Headers
      Map<String, String> headers = {
        'userkey': '$id',
      };
      var response =
          await https.post(headers: headers, Uri.parse(apiUrl), body: {});
      print(response.body);
      print('xxxxxxxxxxxxxxxxxxxxxxxxxxxx');
      return jsonDecode(response.body);
    } else {
      notification().warning(context, 'No Internet');
    }
  }
  // if rider collect delivery   and update quantity  then after hide marker from map
  // oder complete api

  pickupComplete(BuildContext context, String pickId, String qty) async {
    if (qty.isNotEmpty) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? id = await prefs.getString('userkey');
        final apiUrl = '${ApiUrl}/Picked/users';
        // Headers
        Map<String, String> headers = {
          'userkey': '$id',
        };
        var resp = await https.post(
            headers: headers,
            Uri.parse(apiUrl),
            body: {'pick_id': pickId, 'qty': qty});

        // testingddddddddddddddddddddd   ddddddddddddddddddddddddddddddddddddd

        // notification().info(context, newString);
      } else {
        notification().warning(context, 'No Internet');
      }
    } else {
      notification().info(context, 'Invalid Quantity');
    }
  }

  Future pendingPickup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userkey');
    final apiUrl = '${ApiUrl}/Allpickups/users';
    // Headers
    Map<String, String> headers = {
      'userkey': '$id',
    };
    var resp = await https.post(headers: headers, Uri.parse(apiUrl), body: {});
    print(id);
    print(resp.body);
    print('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq');
    return List<Map<String, dynamic>>.from(jsonDecode(resp.body) as List);
  }

  Future pickup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userkey');
    final apiUrl = '${ApiUrl}/Allpicked/users';
    // Headers
    Map<String, String> headers = {
      'userkey': '$id',
    };
    var resp = await https.post(headers: headers, Uri.parse(apiUrl), body: {});

    print(resp.body);
    return List<Map<String, dynamic>>.from(jsonDecode(resp.body));
  }

  Future getMyDeposit(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userkey');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      final apiUrl = '${ApiUrl}/Deposit/users';
      // Headers
      Map<String, String> headers = {
        'userkey': '$id',
      };
      // Make POST request
      var res = await https.post(headers: headers, Uri.parse(apiUrl), body: {});
      print(res.body);
      print('deposit');
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    } else {
      notification().warning(context, 'No Internet');
    }
  }

  //re sheduled screen

  getReScheduleData(String sWaybill, BuildContext context, String date) async {
    print(date);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userkey');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      print('sssssssssssssssssssssssssss');
      final apiUrl = '${ApiUrl}/Myrechedued/users';
      // Headers
      Map<String, String> headers = {
        'userkey': '$id',
      };
      // Make POST request
      var res = await https.post(headers: headers, Uri.parse(apiUrl), body: {
        'nextdate': date,
      });

      return List<Map>.from(jsonDecode(res.body) as List);
    } else {
      notification().warning(context, 'No Internet');
    }
  }

  // image upload my delivery screen

  immageUpload(BuildContext context, XFile? image, String waybill) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userkey');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      final apiUrl = '${ApiUrl}/Image/users';
      // Headers
      Map<String, String> headers = {
        'userkey': '$id',
      };
      if (image != null) {
        Dio dio = Dio();
        // progress = 0.0;

        String uploadURL = apiUrl; // Replace with your server's upload URL

        var formData = FormData.fromMap({
          "image": await MultipartFile.fromFile(image.path),
          "user_id": id,
          "waybill_id": waybill,
        });

        try {
          var responce = await dio.post(
            options: Options(headers: headers),
            uploadURL,
            data: formData,
            onSendProgress: (sent, total) {
              Provider.of<ProviderS>(context, listen: false).progress =
                  sent / total;
            },
          );

          notification().info(context, 'Image uploaded successfully');
        } catch (error) {
          notification().info(context, 'Error uploading image');
        }
      }
    } else {
      notification().warning(context, 'No Internet');
    }
  }

  getYoutubeData() async {
    List _ids = [];
    var url = 'https://koombiyodelivery.net/hr2/appVideo';
    var res = await https.post(Uri.parse(url), body: {});

    var yId = jsonDecode(res.body);

    List.generate(yId.length, (index) {
      _ids.add(yId[index]['link']);
    });

    //   _ids;
    return _ids;
  }

  getYoutubeDetails(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      var url = 'https://koombiyodelivery.net/hr2/appVideo';
      var res = await https.post(Uri.parse(url), body: {});

      var yId = jsonDecode(res.body);

      //   _ids;
      return yId;
    } else {
      notification().warning(context, 'No Internet');
    }
  }

// assign pickup

  assignPickupList(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      var url = '${ApiUrl}/Userpickuprequests/users';
      var res = await https.post(Uri.parse(url), body: {});
      var list = jsonDecode(res.body);
      //   _ids;
      return list;
    } else {
      notification().warning(context, 'No Internet');
    }
  }

  assignRiderList(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      var url = '${ApiUrl}/Riderlist/users';
      var res = await https.post(Uri.parse(url), body: {});
      var list = jsonDecode(res.body);
      //   _ids;
      return list;
    } else {
      notification().warning(context, 'No Internet');
    }
  }

  assignToRider(
    BuildContext context,
    String id,
    String vehicleNo,
    String riderPhone,
    String pickId,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userkey');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      final apiUrl = '${ApiUrl}/Assignrider/users';
      // Headers
      Map<String, String> headers = {
        'userkey': '$id',
      };
      print(id);
      print(vehicleNo);
      print(riderPhone);
      print(pickId);
      print(id);
      // Make POST request
      var list = await https.post(headers: headers, Uri.parse(apiUrl), body: {
        "rider_id": id,
        "vehicle_no": vehicleNo,
        "rider_phone": riderPhone,
        "pick_id": pickId
      });

      print(list.body);
      var data = jsonDecode(list.body);

      print(data);
      print(data['status']);

      if (data['status'] == 200) {
        print(data);
        notification().info(context, 'Rider assigned successfully.');
        Navigator.pop(context);
      }
      if (data['status'] == 403) {
        notification().warning(context, 'Something went wrong');
      }
      return list;
      //   _ids;
    } else {
      notification().warning(context, 'No Internet');
    }
  }
  // add user screen data

  addUser(
    String name,
    String address,
    String personal_contact,
    String ofc_contact,
    String emp_emg_no,
    String emp_gender,
    String birthdate,
    String nic,
    String reg_date,
    String designation_id,
    String branch_id,
    String emp_type_id,
    String salary_type,
    String basic_salary,
    String bond_type,
    String vehicle_type,
    String vehicle_no,
    String vehicle_amount,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userId');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      var urll = 'https://koombiyodelivery.net/hr2/save_temp_emp';
      var responsee = await https.post(Uri.parse(urll), body: {
        'type': 'add',
        'full_name': name,
        'address': address,
        'personal_contact': personal_contact,
        'ofc_contact': ofc_contact,
        'emp_emg_no': emp_emg_no,
        'emp_gender': emp_gender,
        'birthdate': birthdate,
        'nic': nic,
        'reg_date': reg_date,
        'div_id': '2',
        'designation_id': designation_id,
        'branch_id': branch_id,
        'emp_type_id': emp_type_id,
        'salary_type': salary_type,
        'basic_salary': basic_salary,
        'bond_type': bond_type,
        'vehicle_type': vehicle_type,
        'vehicle_no': vehicle_no,
        'vehicle_amount': vehicle_amount,
        'added_user_id': id
      });

      return responsee.body;
    }
  }
// add user images upload

  addUserImages(
    String tempId,
    String bond_type,
    String idFrontIsEmpty,
    String idBackIsEmpty,
    String vBkIsEmpty,
    String vhCHIsEmpty,
    String vhLicenceIsEmpty,
    String vhFrontIsEmpty,
    String vhLeftIsEmpty,
    String vhRightIsEmpty,
    String vhBackIsEmpty,
    String id_front,
    String id_front_thumb,
    String id_back,
    String id_back_thumb,
    String vehicle_book,
    String vchassis,
    String vehicle_license,
    String vehicle_front,
    String vehicle_right,
    String vehicle_back,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = await prefs.getString('userId');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      var urll = 'https://koombiyodelivery.net/hr2/sveTempEmpImg';
      var responsee = await https.post(Uri.parse(urll), body: {
        'temp_id': tempId,
        'type': 'add',
        'bond_type': bond_type,
        'idFrontIsEmpty': idFrontIsEmpty,
        'idBackIsEmpty': idBackIsEmpty,
        'vBkIsEmpty': vBkIsEmpty,
        'vhCHIsEmpty': vhCHIsEmpty,
        'vhLicenceIsEmpty': vhLicenceIsEmpty,
        'vhFrontIsEmpty': vhFrontIsEmpty,
        'vhLeftIsEmpty': vhLeftIsEmpty,
        'vhRightIsEmpty': vhRightIsEmpty,
        'vhBackIsEmpty': vhBackIsEmpty,
        'id_front': id_front,
        'id_front_thumb': id_front_thumb,
        'id_back': id_back,
        'id_back_thumb': id_back_thumb,
        'vehicle_book': vehicle_book,
        'vchassis': vchassis,
        'vehicle_license': vehicle_license,
        'vehicle_front': vehicle_front,
        'vehicle_right': vehicle_right,
        'vehicle_back': vehicle_back
      });

      return responsee.body;
    }
  }

  nicValidate(String nic) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      var urll = 'https://koombiyodelivery.net/hr2/empIDValidation';
      var responsee = await https.post(Uri.parse(urll), body: {'NIC': nic});

      return responsee.body;
    }
  }
}