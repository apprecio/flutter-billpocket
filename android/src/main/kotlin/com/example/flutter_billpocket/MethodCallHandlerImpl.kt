package com.example.flutter_billpocket

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import android.content.Context
import android.location.Location
import android.util.Log
import com.billpocket.bil_lib.controllers.BillpocketSDK
import com.billpocket.bil_lib.controllers.BluetoothReaderConnection
import com.billpocket.bil_lib.controllers.BluetoothReaderList
import com.billpocket.bil_lib.controllers.BluetoothReaderTransaction
import com.billpocket.bil_lib.core.BluetoothDevicesResult
import com.billpocket.bil_lib.core.InitSDKResult
import com.billpocket.bil_lib.core.ReaderConnectionResult
import com.billpocket.bil_lib.core.interfaces.EventListenerConnection
import com.billpocket.bil_lib.core.interfaces.EventListenerInitSDK
import com.billpocket.bil_lib.core.interfaces.InitBillpocketSDK
import com.billpocket.bil_lib.models.entities.DataReader
import com.billpocket.bil_lib.models.transaction.Q6Descriptor
import com.google.gson.Gson
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler


class MethodCallHandlerImpl : MethodCallHandler {

    private val TAG = "MethodCallHandlerImpl"

    private val METHOD_CHANNEL_NAME = "billpocket/operation"

    private var channel: MethodChannel? = null

    private lateinit var applicationContext: Context

    private lateinit var listenerTransaction: ListenerTransaction


    fun setContext(context: Context) {
        applicationContext = context
    }

    fun setListenerTransaction(listener: ListenerTransaction) {
        listenerTransaction = listener
    }

    fun startListening(messenger: BinaryMessenger?) {
        if (channel != null) {
            Log.wtf(TAG, "Setting a method call handler before the last was disposed.")
            stopListening()
        }
        channel = MethodChannel(messenger!!, METHOD_CHANNEL_NAME)
        channel?.setMethodCallHandler(this)
    }

    fun stopListening() {
        if (channel == null) {
            Log.d(TAG, "Tried to stop listening when no MethodChannel had been initialized.")
            return
        }
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "config" -> this.config(call, result)
            "getStatusSDK" -> this.getStatusSDK(result)
            "getReaderList" -> this.getReaderList(result)
            "connectReader" -> this.connectReader(call, result)
            "doTransaction" -> this.doTransaction(call, result)
            "continueWithMsi" -> this.continueWithMsi(call, result)
            else -> result.notImplemented()
        }
    }

    private fun config(call: MethodCall, result: MethodChannel.Result) {
        try {
            val isProduction = call.argument<Boolean>("isProduction")
            val token = call.argument<String>("token")
            if (isProduction == null || token == null) {
                result.error("FlutterBillpocketException", "Parámetros nulos", null)
            } else {
                this.callConfig(isProduction, token, result)
            }
        } catch (e: Exception) {
            result.error("FlutterBillpocketException", e.localizedMessage, null)
        }
    }

    private fun callConfig(isProduction: Boolean, token: String, result: MethodChannel.Result) {
        BillpocketSDK.initSDK(context = this.applicationContext,
            mode = if (isProduction) InitBillpocketSDK.SdkMode.PRODUCTION else InitBillpocketSDK.SdkMode.TEST,
            userToken = token,
            listener = object : EventListenerInitSDK {
                override fun resultInitSdk(resultInitSdk: InitSDKResult<String>) {
                    when (resultInitSdk) {
                        is InitSDKResult.Success -> {
                            result.success(true)
                        }

                        is InitSDKResult.Error -> {
                            result.error(
                                "FlutterBillpocketException", resultInitSdk.exception.message, null
                            )
                        }
                    }
                }

                override fun resultIsReaderSunmi(isSunmi: Boolean) {

                }
            })
    }

    private fun getStatusSDK(result: MethodChannel.Result) {
        try {
            result.success(BillpocketSDK.sdkStatus())
        } catch (e: Exception) {
            result.error("FlutterBillpocketException", e.localizedMessage, null)
        }
    }

    private fun getReaderList(result: MethodChannel.Result) {
        try {
            BluetoothReaderList.getListBluetoothReaders(this.applicationContext,
                object : EventListenerConnection {
                    override fun onQposDisconnected(resultDisconnected: String) {
                        // Does not apply
                    }

                    @SuppressLint("MissingPermission")
                    override fun resultListReaders(readersList: BluetoothDevicesResult<List<BluetoothDevice>>) {
                        when (readersList) {
                            is BluetoothDevicesResult.Success -> {
                                val list: List<Reader> = readersList.data.map {
                                    Reader(name = it.name, macAddress = it.address, type = it.type)
                                }.toList()
                                val readers = Gson().toJson(list)
                                result.success(readers)
                            }

                            is BluetoothDevicesResult.Error -> result.error(
                                "FlutterBillpocketException", readersList.exception.message, null
                            )
                        }
                    }

                    override fun resultReaderConnect(resultConnection: ReaderConnectionResult<DataReader>) {
                        // Does not apply
                    }
                })
        } catch (e: Exception) {
            result.error("FlutterBillpocketException", e.localizedMessage, null)
        }
    }

    private fun connectReader(call: MethodCall, result: MethodChannel.Result) {
        try {
            val readerType = call.argument<Int>("readerType")
            val readerMacAddress = call.argument<String>("readerMacAddress")
            val name = call.argument<String>("name")

            if (readerType == null || readerMacAddress == null || name == null) {
                result.error("FlutterBillpocketException", "Parámetros nulos", null)
            } else {
                this.callConnectReader(readerType, readerMacAddress, name, result)
            }
        } catch (e: Exception) {
            result.error("FlutterBillpocketException", e.localizedMessage, null)
        }
    }

    private fun callConnectReader(
        readerType: Int, readerMacAddress: String, name: String, result: MethodChannel.Result
    ) {
        BluetoothReaderConnection.connectReader(applicationContext,
            readerType,
            readerMacAddress,
            name,
            listener = object : EventListenerConnection {
                override fun onQposDisconnected(resultDisconnected: String) {
                    // Does not apply
                }

                override fun resultListReaders(readersList: BluetoothDevicesResult<List<BluetoothDevice>>) {
                    // Does not apply
                }

                override fun resultReaderConnect(resultConnection: ReaderConnectionResult<DataReader>) {
                    when (resultConnection) {
                        is ReaderConnectionResult.Success -> {
                            result.success(true)
                        }

                        is ReaderConnectionResult.Error -> {
                            result.error(
                                "FlutterBillpocketException",
                                resultConnection.exception.message,
                                null
                            )
                        }
                    }
                }

            })
    }

    private fun doTransaction(call: MethodCall, result: MethodChannel.Result) {
        try {
            val amount = call.argument<String>("amount")
            val tip = call.argument<String>("tip")
            val latitude = call.argument<Double>("latitude")
            val longitude = call.argument<Double>("longitude")
            val description = call.argument<String>("description")

            if (amount == null || tip == null || latitude == null || longitude == null || description == null) {
                result.error("FlutterBillpocketException", "Parámetros nulos", null)
            } else {
                this.callDoTransaction(amount, tip, latitude, longitude, description)
            }
        } catch (e: Exception) {
            result.error("FlutterBillpocketException", e.localizedMessage, null)
        }
    }

    private fun callDoTransaction(
        amount: String,
        tip: String,
        lat: Double,
        long: Double,
        description: String,
    ) {
        BluetoothReaderTransaction.doTransaction(
            applicationContext, amount.toBigDecimal(), description, Location("SDK_EXAMPLE").apply {
                latitude = lat
                longitude = long
            }, tip.toBigDecimal(), listenerTransaction
        )
    }

    private fun continueWithMsi(call: MethodCall, result: MethodChannel.Result) {
        try {
            val commission = call.argument<Double>("commission")
            val installments = call.argument<Int>("installments")
            val minAmount = call.argument<Double>("minAmount")

            if (commission == null || installments == null || minAmount == null) {
                result.error("FlutterBillpocketException", "Parámetros nulos", null)
            } else {
                this.callContinueWithMsi(commission, installments, minAmount)
            }
        } catch (e: Exception) {
            result.error("FlutterBillpocketException", e.localizedMessage, null)
        }
    }

    private fun callContinueWithMsi(commission: Double, installments: Int, minAmount: Double) {
        BluetoothReaderTransaction.continueTransactionWithMSI(
            Q6Descriptor(
                commission = commission.toBigDecimal(),
                installments = installments,
                minAmount = minAmount.toBigDecimal()
            )
        )
    }
}