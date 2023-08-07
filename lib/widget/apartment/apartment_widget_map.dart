import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttermainproject/model/apartmentdata_firebase/apartment_fb.dart';
import 'package:fluttermainproject/model/obs/apartmentcontroller.dart';
import 'package:fluttermainproject/viewmodel/mapgps_vm.dart';
import 'package:fluttermainproject/widget/apartment/apartment_chart_appbar_widget.dart';
import 'package:fluttermainproject/widget/apartment/apartment_search.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class ApartmentWidgetMap extends StatelessWidget {
  // 맵 생성 callback
  KakaoMapController? mapController;

  final List<Marker> markers = []; // 마커 초기화
  MapGPS gps = Get.put(MapGPS());
  final apartmentController = Get.put(ApartmentControllerObs());


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Stack(
      children: [
        SizedBox(
          // 화면 크기에 맞게 조절
          height: MediaQuery.of(context).size.height / 1.08,
          width: MediaQuery.of(context).size.width,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('apartment')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              markers.clear();

              for (var doc in snapshot.data!.docs) {
                var apartmentData = ApartmentFB(
                    year: doc['건축년도'],
                    x: doc['경도'],
                    contract: doc['계약시점'],
                    rate: doc['계약시점기준금리'],
                    apartmentName: doc['단지명'],
                    rodeName: doc['도로명'],
                    streetAddress: doc['번지'],
                    deposit: doc['보증금'],
                    city: doc['시군구'],
                    y: doc['위도'],
                    extent: doc['임대면적'],
                    station: doc['정류장수'],
                    subway: doc['지하철역거리'],
                    floor: doc['층']);

                markers.add(
                  Marker(
                    latLng: LatLng(apartmentData.y, apartmentData.x),
                    width: 20,
                    height: 50,
                    infoWindowContent: apartmentData.apartmentName,
                    infoWindowFirstShow: true,
                    infoWindowRemovable: false,
                    markerId: UniqueKey().toString(),
                  ),
                );
              }
              return KakaoMap(
                mapTypeControl: true,
                mapTypeControlPosition: ControlPosition.bottomRight,
                onMapTap: (latLng) => FocusScope.of(context).unfocus(),
                // 마커를 클릭했을 때 호출
                onMarkerTap: (markerId, latLng, zoomLevel) {
                  // 선택된 마커의 infoWindowContent 값을 가져옴
                  String apartmentName = markers
                      .firstWhere((marker) => marker.markerId == markerId)
                      .infoWindowContent;

                  // Getx로 데이터를 보냅니다.
                  apartmentController.setApartmentName(apartmentName);

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return ApartmentChartWidget();
                    },
                  );
                },
                onMapCreated: ((controller) {
                  mapController = controller;
                  // 지도에 찍히는 마커 데이터
                }),
                markers: markers,
                // 지도의 중심좌표
                center: LatLng(37.497961, 127.027635),
              );
            }),
          ),
        // GPS
          Positioned(
            bottom: MediaQuery.of(context).size.height / 60,
            child: IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () async {
                // 사용자 위치를 얻어옴
                Position? position = await gps.getCurrentLocation();
                if (position != null) {
                  // 위치 정보를 이용하여 원하는 동작 수행
                  double latitude = position.latitude;
                  double longitude = position.longitude;
                  // 해당 위치로 맵 이동
                  mapController!.setCenter(LatLng(latitude, longitude));
                } else {
                  // 위치 권한이 거부된 경우
                }
              },
              icon: const Icon(Icons.gps_fixed),
            ),
          ),
          // 검색창, 최근검색어
          ApartmentSearch(),
        ],
      ));
  }
}
