package com.example.flutter_billpocket

import Installment
import android.app.Activity
import android.content.Intent
import android.os.Handler
import android.os.Looper
import com.billpocket.bil_lib.controllers.BluetoothReaderTransaction
import com.billpocket.bil_lib.core.interfaces.EventListenerTransaction
import com.billpocket.bil_lib.core.interfaces.ReaderTransactionResult
import com.billpocket.bil_lib.models.entities.DataSuccessfulTransaction
import com.billpocket.bil_lib.models.transaction.Q6Descriptor
import com.google.gson.Gson
import io.flutter.plugin.common.PluginRegistry

class ListenerTransaction(
    private val streamHandler: StreamHandlerImpl,
    private val activity: Activity
) : EventListenerTransaction, PluginRegistry.ActivityResultListener {

    private val REQUEST_SIGNATURE = 0x1
    private val REQUEST_PIN = 0x1001

    private val uiThreadHandler = Handler(Looper.getMainLooper())
    var logs = "";

    override fun getSignature(intent: Intent) {
        streamHandler.getSignature("Obteniendo firma")
        activity.startActivityForResult(intent, REQUEST_SIGNATURE)
    }

    override fun onBeforeTransaction(message: String) {
        uiThreadHandler.post {
            streamHandler.onBeforeTransaction(message)
        }
    }

    override fun onCardRead(message: String) {
        uiThreadHandler.post {
            streamHandler.onCardRead(message)
        }
    }

    override fun onGetPin(intent: Intent, requestCodeMinerva: Int) {
        streamHandler.onGetPin("Solicitando PIN")
        activity.startActivityForResult(intent, REQUEST_PIN)
    }

    override fun onMagneticCardFound(readerType: Int) {
        uiThreadHandler.post {
            streamHandler.onMagneticCardFound("Tarjeta magnetica encontrada")
            BluetoothReaderTransaction.onContinueTransactionWithMagneticCard()
        }
    }

    override fun onMsiDefined(msiClient: MutableList<Q6Descriptor>) {
        val listInstallments: List<Installment> = msiClient.map {
            Installment(
                value = it.installments,
                commission = it.commission.toDouble(),
                minAmount = it.minAmount.toDouble()
            )
        }.toList()
        val list = Gson().toJson(listInstallments)
        uiThreadHandler.post {
            streamHandler.onMsiDefined("Activando meses sin intereses", list)
        }
    }

    override fun onReaderWaitingForCard(message: String) {
        streamHandler.onReaderWaitingForCard(message)
    }

    override fun onTransactionAborted(message: String) {
        uiThreadHandler.post {
            streamHandler.onTransactionAborted(message)
        }
    }

    override fun onTransactionFinished(message: String) {
        uiThreadHandler.post {
            streamHandler.onTransactionFinished(message)
        }
    }

    override fun onTransactionSuccessful(
        msj: String,
        transactionData: DataSuccessfulTransaction
    ) {
        uiThreadHandler.post {
            streamHandler.onTransactionSuccessful(msj)
        }
    }

    override fun resultStartTransaction(resultTransaction: ReaderTransactionResult<String>) {
        uiThreadHandler.post {
            streamHandler.resultStartTransaction("Obteniendo resultado de transacción")
            when (resultTransaction) {
                is ReaderTransactionResult.Success -> streamHandler.resultStartTransactionSuccess(
                    resultTransaction.data
                )

                is ReaderTransactionResult.Error -> streamHandler.resultStartTransactionError(
                    resultTransaction.exception.localizedMessage ?: ""
                )
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return when (requestCode) {
            REQUEST_PIN -> {
                if (resultCode == Activity.RESULT_OK) {
                    BluetoothReaderTransaction.continueTransactionWithPIn(
                        data!!, this
                    )
                }
                true
            }

            REQUEST_SIGNATURE -> {
                if (resultCode == Activity.RESULT_OK) {
                    BluetoothReaderTransaction.continueTransactionWithSignature(data!!)
                }
                true
            }

            else -> false
        }
    }

    override fun onLogEvenListener(log: String) {
        addMessageToLogger("onLogEvenListener: $log")
    }

    private fun addMessageToLogger(message: String) {
        var msg = logs
        msg = "$message\n------------\n$msg"
        logs = msg
    }
}