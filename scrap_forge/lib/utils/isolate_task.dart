import 'dart:isolate';

Future isolateTask(
    void Function(List<dynamic> tArgs) task, List<dynamic> args) async {
  final ReceivePort receivePort = ReceivePort();
  try {
    await Isolate.spawn(task, [receivePort.sendPort, ...args]);
  } on Object {
    receivePort.close();
  }

  final response = await receivePort.first;

  return response;
}
