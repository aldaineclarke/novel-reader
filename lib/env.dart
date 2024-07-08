import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SERVER_URL')
  static String serverUrl = _Env.serverUrl;

  @EnviedField(varName: 'NOVEL_DB_NAME')
  static String novel_db_name = _Env.novel_db_name;

  @EnviedField(varName: 'SHELF_DB_NAME')
  static String shelf_db_name = _Env.shelf_db_name;
}
