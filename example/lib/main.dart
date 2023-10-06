import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_billpocket/billpocket.dart';
import 'package:flutter_billpocket/installment.dart';
import 'package:flutter_billpocket/reader.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Billpocket.config(
      isProduction: true,
      token: '{YOUR_TOKEN}');
  runApp(const MyAppPage());
}

class MyAppPage extends StatelessWidget {
  const MyAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _statusSDK = false;
  bool _statusBluetooth = false;
  bool _statusConnection = false;
  List<Reader> _readers = [];
  StreamSubscription<Map<dynamic, dynamic>>? _subscription;
  TextEditingController amountController = TextEditingController();

  List<String> log = [];

  @override
  void initState() {
    super.initState();
    getStatusSDK();
    getStatusBluetoothPermission();
    listenTransactionStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billpocket'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estados',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Status(
                    title: 'SDK',
                    isActive: _statusSDK,
                  ),
                  Status(
                    title: 'Bluetooth',
                    isActive: _statusBluetooth,
                  ),
                  Status(
                    title: 'Terminal \nConnection',
                    isActive: _statusConnection,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Opciones',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () async {
                          await [
                            Permission.bluetoothScan,
                            Permission.bluetoothAdvertise,
                            Permission.bluetoothConnect
                          ].request();

                          if (await Permission.bluetoothConnect
                              .request()
                              .isGranted) {
                            setState(() {
                              _statusBluetooth = true;
                            });
                          }
                        },
                        child: const Text('Activar Bluetooth')),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.brown)),
                        onPressed: () async {
                          getListReaders();
                        },
                        child: const Text('Obtener terminales')),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Realizar cobro',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[0-9.]"))
                ],
                decoration: const InputDecoration.collapsed(
                  hintText: 'Monto',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green)),
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            log.clear();
                          });
                          await Billpocket.doTransaction(
                              amount: amountController.text,
                              tip: "0",
                              latitude: 19.42691938620286,
                              longitude: -99.16780320031096,
                              description: "description");
                        },
                        child: const Text('Cobrar')),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text('Log de Transacción',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 10,
              ),
              ListView.separated(
                itemBuilder: (context, pos) {
                  if (pos == 0) {
                    return Row(children: [
                      const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Colors.lightGreen,),
                      const SizedBox(width: 10,),
                      Expanded(child: Text(log[pos], style: const TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.bold),))
                    ],);
                  }
                  return Text(log[pos], style: const TextStyle(color: Colors.grey),);
                },
                itemCount: log.length,
                shrinkWrap: true, separatorBuilder: (BuildContext context, int index) {
                  return Divider();
              },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getStatusSDK() async {
    bool statusSDK;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      statusSDK = await Billpocket.getStatusSDK();
    } on PlatformException {
      statusSDK = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _statusSDK = statusSDK;
    });
  }

  getListReaders() async {
    List<Reader> readers;

    try {
      readers = await Billpocket.getReaders();
    } on PlatformException {
      readers = [];
    }

    if (!mounted) return;

    setState(() {
      _readers = readers;
      showTerminals();
    });
  }

  connectReader(
      {required int readerType,
      required String readerMacAddress,
      required String name}) async {
    bool statusConnection;

    try {
      statusConnection = await Billpocket.connectReader(
          readerType: readerType,
          readerMacAddress: readerMacAddress,
          name: name);
    } on PlatformException {
      statusConnection = false;
    }

    if (!mounted) return;

    setState(() {
      _statusConnection = statusConnection;
    });
  }

  getStatusBluetoothPermission() async {
    var status = await Permission.bluetoothScan.status;
    if (status.isGranted) {
      setState(() {
        _statusBluetooth = true;
      });
    } else {
      setState(() {
        _statusBluetooth = false;
      });
    }
  }

  void listenTransactionStream() {
    _subscription = Billpocket.transactionStream().listen((event) {
      final eventName = event['event'];
      final message = event['message'];

      switch (eventName) {
        case 'onTransactionAborted':
          // Handle the onTransactionAborted event
          print('Transaction aborted: $message');
          break;
        case 'onBeforeTransaction':
          // Handle the onBeforeTransaction event
          print('Transaction before: $message');
          break;
        case 'onCardRead':
          // Handle the onCardRead event
          print('Transaction card read: $message');
          break;
        case 'getSignature':
          // Handle the getSignature event
          print('Transaction get signature: $message');
          break;
        case 'onReaderWaitingForCard':
          // Handle the onReaderWaitingForCard event
          print('Transaction reader waiting for card: $message');
          break;
        case 'onMsiDefined':
          // Handle the onMsiDefined event
          final list = event['list'];
          print('Transaction msi defined: $message');
          print('MSI list: $list');
          showMSI(list);
          break;
        case 'onGetPin':
          // Handle the onGetPin event
          print('Transaction get pin: $message');
          break;
        case 'onMagneticCardFound':
          // Handle the onMagneticCardFound event
          print('Transaction magnetic card found: $message');
          break;
        case 'onTransactionFinished':
          // Handle the onTransactionFinished event
          print('Transaction finished: $message');
          break;
        case 'onTransactionSuccessful':
          // Handle the onTransactionSuccessful event
          print('Transaction successful: $message');
          break;
        case 'resultStartTransaction':
          // Handle the resultStartTransaction event
          print('Transaction result start: $message');
          break;
        case 'resultStartTransactionSuccess':
          // Handle the resultStartTransactionSuccess event
          print('Transaction result start success: $message');
          break;
        case 'resultStartTransactionError':
          // Handle the resultStartTransactionError event
          print('Transaction result start error: $message');
          break;
        // Handle other events similarly
        default:
          print('Unknown event received: $eventName');
          break;
      }

      setState(() {
        log.insert(0, message);
      });
    }, onError: (error) {
      print("Error received: $error");
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void showTerminals() {
    showModalBottomSheet<void>(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: ListView.separated(
                itemBuilder: (context, pos) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _readers[pos].name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.orange)),
                        onPressed: () {
                          Navigator.pop(context);
                          connectReader(
                              readerType: _readers[pos].type,
                              readerMacAddress: _readers[pos].macAddress,
                              name: _readers[pos].name);
                        },
                        child: const Text('Conectar'))
                  ],
                ),
                itemCount: _readers.length,
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
              ),
            ),
          );
        });
  }

  void showMSI(list) {
    List<Installment> installment = List<Installment>.from(
        json.decode(list).map((x) => Installment.fromJson(x)));

    showModalBottomSheet<void>(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: ListView.separated(
                itemBuilder: (context, pos) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${installment[pos].value.toString()} meses sin intereses',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.orange)),
                        onPressed: () {
                          Billpocket.continueWithMsi(
                            commission: installment[pos].commission!,
                            installments: installment[pos].value!,
                            minAmount: installment[pos].minAmount!,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Elegir'))
                  ],
                ),
                itemCount: installment.length,
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
              ),
            ),
          );
        });
  }
}

class Status extends StatelessWidget {
  const Status({
    super.key,
    required this.isActive,
    required this.title,
  });

  final bool isActive;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : Colors.red),
          width: 10,
          height: 10,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
