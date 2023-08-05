import 'package:flutter/material.dart';
import 'package:fluttermainproject/model/search/search_sqlitedb.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class ApartmentWidget extends StatefulWidget {
  const ApartmentWidget({super.key});

  @override
  State<ApartmentWidget> createState() => _ApartmentWidgetState();
}

class _ApartmentWidgetState extends State<ApartmentWidget> {
  Set<Marker> markers = {}; // 마커 변수
  // 맵 생성 callback
  late KakaoMapController mapController;
  late TextEditingController searchController;
  DatabaseHandler handler = DatabaseHandler();

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        // Stack으로 앱 바와 본문 이미지 겹치도록 설정
        children: [
          SizedBox(
            // 화면 크기에 맞게 조절
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: KakaoMap(
              mapTypeControl: true,
              onMapTap: (latLng) => FocusScope.of(context).unfocus(),
              // 마커를 클릭했을 때 호출
              onMarkerTap: (markerId, latLng, zoomLevel) {
                // print('Marker ID: $markerId');
                // print('Latitude: ${latLng.latitude}');  // y
                // print('Longitude: ${latLng.longitude}');// x
                // print('Zoom Level: $zoomLevel');
                Get.defaultDialog(
                    title: latLng.latitude.toString(), //  y
                    middleText: latLng.longitude.toString(), //  x
                    backgroundColor: const Color.fromARGB(255, 252, 252, 246),
                    barrierDismissible: false,
                    actions: [
                      TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: const Text('Exit'))
                    ]);
              },
              onMapCreated: ((controller) {
                mapController = controller;
                // 지도에 찍히는 마커 데이터
                markers.add(Marker(
                  markerId: UniqueKey().toString(),
                  // 여기다 마커 데이터(y,x)
                  latLng: LatLng(37.493997700000, 127.031227700000),
                ));

                setState(() {});
              }),
              markers: markers.toList(),
              // 지도의 중심좌표
              center: LatLng(37.516211, 127.018593),
            ),
          ),
          // 검색
          Positioned(
            // AppBar를 겹치도록 위치 조정
            top: MediaQuery.of(context).size.height / 14,
            left: MediaQuery.of(context).size.width / 15,
            right: MediaQuery.of(context).size.width / 15,
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 12.0), // 텍스트필드 내부/여백을 변경
                    // 검색버튼 눌렀을경우
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (searchController.text.trim().isEmpty) {
                          Get.snackbar(
                            '검색오류',
                            '검색어를 입력해주세요',
                            snackPosition: SnackPosition.BOTTOM, // 스낵바 위치
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          );
                        } else {
                          // 최근 검색어 저장
                          handler.insertSearch(searchController.text.trim());
                          // 사용자 검색을 통해 위치 변경 해야됨 ******************************
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.search),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(3.0),
                      child: Text(
                        '최근 검색어',
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                // 최근 검색어
                FutureBuilder(
                  future: handler.querySearch(),
                  builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 20,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (context, index) => const SizedBox(width: 0), // 구분자 설정
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0 , 5, 20),
                              child: TextButton(
                                onPressed: () {
                                  searchController.text = snapshot.data![index].content;
                                  setState(() {});
                                },
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size.zero),
                                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                                  alignment: Alignment.center,
                                  backgroundColor: MaterialStateProperty.all(Colors.white),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  child: Row(
                                    children: [
                                      Text(
                                        snapshot.data![index].content.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 30,
                                        child: IconButton(
                                          onPressed: () {
                                            handler.deleteSearch(snapshot.data![index].seq!);
                                            setState(() {});
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            size: 12,
                                          ),
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return const Text("");
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
