# Billpocket Plugin

Introducing Billpocket: Simplifying Mobile Card Payments and Terminal Integration for Flutter

**Show some ❤️ and star the repo to support the project**

## Getting Started

Set your Billpocket token and development environment.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Billpocket.config(
      isProduction: true,
      token: '{YOUR_TOKEN}');
  runApp(const MyAppPage());
}
```

# Documentation

## SDK status 

You can check the status of the SDK initialization by calling the following line of code:

```dart
await Billpocket.getStatusSDK();
```

Which will return a `bool` value.

## Terminal list 

You can get the list of all the terminals that have been paired via bluetooth with the following method:

```dart
await Billpocket.getReaders();
```

Which will return a `List<Reader>` value.

## Connect terminal

Once you have chosen a terminal you must call the following method sending the parameters obtained in `Reader`:

```dart
await Billpocket.connectReader(
          readerType: readerType,
          readerMacAddress: readerMacAddress,
          name: name);
```

Which will return a `bool` value.

## Start a transaction

```dart
await Billpocket.doTransaction(
                              amount: "10",
                              tip: "0",
                              latitude: 19.42691938620286,
                              longitude: -99.16780320031096,
                              description: "description");
```

Running this method will trigger a stream of events.

```dart
Billpocket.transactionStream().listen((event) {
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
```

**Explanation of events**

- onGetPin and getSignature: 
  These methods will open native screens so there is no need to handle the response.

- onMsiDefined: 
  This method will return a string that must be parsed to get a `List<Installment>`. Please review the [example](https://github.com/apprecio/flutter-billpocket/tree/main/example).

- other methods: 
  These methods are transactional so it depends on the use case.

## Months without interest

If the amount you have entered in `doTransaction` exceeds the limit of months without interest, the onMsiDefined event explained above will be triggered. As a list will be obtained and an interest-free months option must be chosen to continue with the transaction, you must call the following method sending the chosen parameters in Installment:

```dart
Billpocket.continueWithMsi(
                            commission: installment[pos].commission!,
                            installments: installment[pos].value!,
                            minAmount: installment[pos].minAmount!,
                          );
```

Calling that method will continue the flow in the stream explained above.

## Issues
Please file any issues, bugs, or feature requests in the [GitHub repo](https://github.com/apprecio/flutter-billpocket/issues/new).

## Contributing
If you wish to contribute a change to this repo, please send a [pull request](https://github.com/apprecio/flutter-billpocket/pulls).

## Acknowledgments
This package was originally created by [Abel Tarazona](https://github.com/AbelTarazona).
