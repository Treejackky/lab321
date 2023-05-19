import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/route_names.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/categories.dart';

class Detail extends StatefulWidget {
  final String itemId;

  const Detail({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  final Future<CategoriesAll> _categoriesFuture = getCategories();
  final _storage = const FlutterSecureStorage();
  static Future<CategoriesAll> getCategories() async {
    var url = Uri.parse("http://13.250.14.61:8765/v1/get");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return categoriesAllFromJson(response.body);
    } else {
      throw Exception("Failed to get categories from API");
    }
  }

  Future<void> writeSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _categoriesFuture,
        builder: (BuildContext context, AsyncSnapshot<CategoriesAll> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            } else {
              var result = snapshot.data!;
              return ListView.builder(
                itemCount: result.items!.length,
                itemBuilder: (context, index) {
                  var item = result.items![index];

                  if (item.itemId == widget.itemId) {
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                // Text(
                                //   "itemId : ${item.itemId}",
                                //   style: const TextStyle(
                                //     fontSize: 20,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 210,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: item.img!.length,
                                          itemBuilder: (context, index) {
                                            final imageUrl = item.img![index];
                                            return Container(
                                              height: double.infinity,
                                              width: 320,
                                              decoration: const BoxDecoration(
                                                color: Colors.black,
                                              ),
                                              child: Image.network(
                                                'https://wealthi-re.s3.ap-southeast-1.amazonaws.com/image/$imageUrl',
                                                fit: BoxFit.contain,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Number Photo : ${item.img!.length}",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  "฿ ${NumberFormat('#,##0', 'en_US').format(item.price)} ",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Type : ${item.features?.type ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  "bedroom :${item.features?.bedroom ?? 'N/A'} ",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  "bathroom :${item.features?.bathroom ?? 'N/A'} ",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'living : ${item.features?.living ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'kitchen :${item.features?.kitchen ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'dining :${item.features?.dining ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'parking :${item.features?.parking ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Email: ${item.email}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                          Container(
                            height: 200,
                            width: 350,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(item.lat!, item.lng!),
                                zoom: 15,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId(item.itemId!),
                                  position: LatLng(item.lat!, item.lng!),
                                ),
                              },
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              );
            }
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _submit();
        },
        child: SvgPicture.asset(
          'assets/messenger_logo.svg',
          width: 24,
          height: 24,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    await writeSecureData('itemId', widget.itemId);
    context.goNamed(RouteNames.loading,
        queryParameters: {'fn': 'contact', 'route': 'detail'});
  }
}
