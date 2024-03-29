import 'package:my_project/configurations/studentsConfiguration.dart';
import 'package:my_project/routes/route_students.dart';

import 'my_project.dart';

class MyProjectChannel extends ApplicationChannel {
  ManagedContext _context;

  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
    final StudentsConfig config = StudentsConfig(options.configurationFilePath);
    final ManagedDataModel dataModel =
        ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        config.database.username,
        config.database.password,
        config.database.host,
        config.database.port,
        config.database.databaseName);
    _context = ManagedContext(dataModel, persistentStore);
    //await createDatabaseSchema(_context);
  }

  @override
  Controller get entryPoint {
    return Router()
      ..route("/students/[:id]").link(() => RouteStudents(_context));
  }

  Future createDatabaseSchema(ManagedContext context) async {
    final builder = SchemaBuilder.toSchema(
        context.persistentStore, Schema.fromDataModel(context.dataModel),
        isTemporary: false);
    for (var cmd in builder.commands) {
      await context.persistentStore.execute(cmd);
    }
  }
}
