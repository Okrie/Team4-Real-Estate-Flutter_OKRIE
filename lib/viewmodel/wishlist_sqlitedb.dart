import 'package:fluttermainproject/model/wishlist_sqlite/wishlist_sqllite.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class WishlistDatabaseHandler extends GetxController{
  Future<Database> initiallizeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'userwishlist.db'), // path로 경로를 찾아서 들어가서 불러온다.
      onCreate: (db, version) async {
        // 데이터베이스가 없으면 실행
        await db.execute(
            'create table wishlist(seq integer primary key autoincrement, aptname text)');
      },
      version: 1,
    );
  }

  // 타입 정의는 Future로 끝나 제너릭에서 생성자로 만든 Students를 넣어줌
  Future<List<WishlistSql>> queryWishList() async {
    final Database db = await initiallizeDB();
    final List<Map<String, Object?>> queryResults =
        await db.rawQuery('select * from wishlist');
    update();
    return queryResults.map((e) => WishlistSql.fromMap(e)).toList();
  }

 Future<List<WishlistSql>> queryWishListstar(String aptData) async {
  final Database db = await initiallizeDB();
  final List<Map<String, Object?>> queryResults =
      await db.rawQuery('select aptname from wishlist where aptname = ?', [aptData]);
  update();

  // queryResults가 비어있는지 여부에 따라 데이터가 있는지 확인할 수 있습니다.
  if (queryResults.isEmpty) {
    return []; // 데이터가 없는 경우 빈 리스트 반환
  } else {
    return queryResults.map((e) => WishlistSql.fromMap(e)).toList();
  }
}


  Future<int> insertWishList(String aptData) async {
    int result = 0;
    final Database db = await initiallizeDB();
    var dbcontent = await db.rawQuery(
        'select * from wishlist where aptname = ?', [aptData]);
    if(dbcontent.isEmpty){
      result = await db
          .rawInsert('insert into wishlist(aptname) values (?)', [aptData]);    
    }
    update();
    return result;
  }

  // 삭제
  Future<void> deleteWishList(String aptData) async {
    final Database db = await initiallizeDB();
    await db.rawDelete('delete from wishlist where aptname = ?', [aptData]);
    update();
  }


}