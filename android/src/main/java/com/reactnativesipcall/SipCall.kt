package com.reactnativesipcall

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter
import org.linphone.core.*
import org.linphone.mediastream.Version
import java.io.File
import java.io.IOException
import java.util.*

class SipCall constructor(reactContext: ReactApplicationContext) {
    private val TAG = "SipCall"
    private val START_LINPHONE_LOGS: String = " ==== Device information dump ===="
    private val CHANNEL_ID = "12345"
    private val NOTIFICATION_ID = 0

    private var mCore: Core? = null
    private var mCoreListener: CoreListenerStub? = null

    private var mTimer: Timer? = null
    private var mHandler: Handler? = null
    private var event: Event? = object : Event() {
        override fun sendAction(action: String) {
            val payload = Arguments.createMap()
            // Put data to map
            payload.putString("Action", action)
            reactContext
                    .getJSModule(RCTDeviceEventEmitter::class.java)
                    .emit("SipCall", payload)
        }
    }


    fun init(context: Context){
        mCore?.start()
        val lTask = object : TimerTask() {
            override fun run() {
                Handler(Looper.getMainLooper()).post {
                    if (mCore != null) mCore!!.iterate()
                }
            }
        }

        mTimer = Timer("Linphone scheduler")
        mTimer?.schedule(lTask, 0, 20)

        val basePath = context.filesDir.absolutePath
        Factory.instance().setLogCollectionPath(basePath)
        Factory.instance().enableLogCollection(LogCollectionState.Enabled)
        Factory.instance().setDebugMode(true, "sip-call")
        dumDeviceInformation()
        mHandler = Handler(Looper.getMainLooper())
        mCoreListener = object : CoreListenerStub() {
            override fun onCallStateChanged(lc: Core, call: Call, cstate: Call.State?, message: String) {
                super.onCallStateChanged(lc, call, cstate, message)
                when (cstate) {
                    Call.State.Idle -> {
                        event?.sendAction("Call.State.Idle")
                    }

                    Call.State.IncomingReceived -> {
                        event?.sendAction("Call.State.IncomingReceived")
                    }

                    Call.State.OutgoingInit -> {
                        event?.sendAction("Call.State.OutgoingInit")
                    }

                    Call.State.OutgoingProgress -> {
                        event?.sendAction("Call.State.OutgoingProgress")
                    }

                    Call.State.OutgoingRinging -> {
                        event?.sendAction("Call.State.OutgoingRinging")
                    }

                    Call.State.OutgoingEarlyMedia -> {
                        event?.sendAction("Call.State.OutgoingEarlyMedia")
                    }

                    Call.State.Connected -> {
                        event?.sendAction("Call.State.Connected")
                    }

                    Call.State.StreamsRunning -> {
                        event?.sendAction("Call.State.StreamsRunning")
                    }

                    Call.State.Pausing -> {
                        event?.sendAction("Call.State.Pausing")
                    }

                    Call.State.Paused -> {
                        event?.sendAction("Call.State.Paused")
                    }

                    Call.State.Resuming -> {
                        event?.sendAction("Call.State.Resuming")
                    }

                    Call.State.Referred -> {
                        event?.sendAction("Call.State.Referred")
                    }

                    Call.State.Error -> {
                        event?.sendAction("Call.State.Error")
                    }

                    Call.State.End -> {
                        event?.sendAction("Call.State.End")
                    }

                    Call.State.PausedByRemote -> {
                        event?.sendAction("Call.State.PausedByRemote")
                    }

                    Call.State.UpdatedByRemote -> {
                        event?.sendAction("Call.State.UpdatedByRemote")
                    }

                    Call.State.IncomingEarlyMedia -> {
                        event?.sendAction("Call.State.IncomingEarlyMedia")
                    }

                    Call.State.Updating -> {
                        event?.sendAction("Call.State.Updating")
                    }

                    Call.State.Released -> {
                        event?.sendAction("Call.State.Released")
                    }

                    Call.State.EarlyUpdatedByRemote -> {
                        event?.sendAction("Call.State.EarlyUpdatedByRemote")
                    }

                    Call.State.EarlyUpdating -> {
                        event?.sendAction("Call.State.EarlyUpdating")
                    }
                    else -> {}
                } }

            override fun onRegistrationStateChanged(lc: Core, cfg: ProxyConfig, cstate: RegistrationState?, message: String) {
                super.onRegistrationStateChanged(lc, cfg, cstate, message)
                Log.e("SipCall", cstate.toString())
                when (cstate) {
                    RegistrationState.None -> {
                        event?.sendAction("RegistrationState.None")
                    }

                    RegistrationState.Progress -> {
                        event?.sendAction("RegistrationState.Progress")
                    }

                    RegistrationState.Ok -> {
                        event?.sendAction("RegistrationState.Ok")
                    }

                    RegistrationState.Cleared -> {
                        event?.sendAction("RegistrationState.Cleared")
                    }

                    RegistrationState.Failed -> {
                        event?.sendAction("RegistrationState.Failed")
                    }
                } }

        }

        mCore = Factory.instance().createCore("", "", context)

        mCore?.addListener(mCoreListener)
        configureCore(context)
    }

    @Throws(IOException::class)
    private fun copyIfNotExist(context: Context, ressourceId: Int, target: String) {
        val lFileToCopy = File(target)
        if (!lFileToCopy.exists()) {
            copyFromPackage(context, ressourceId, lFileToCopy.name)
        }
    }

    @Throws(IOException::class)
    private fun copyFromPackage(context: Context, ressourceId: Int, target: String) {
        val lOutputStream = context.openFileOutput(target, 0)
        val lInputStream = context.resources.openRawResource(ressourceId)
        var readByte: Int
        val buff = ByteArray(8048)
        while (lInputStream.read(buff).also { readByte = it } != -1) {
            lOutputStream.write(buff, 0, readByte)
        }

        lOutputStream.flush()
        lOutputStream.close()
        lInputStream.close()
    }


    private fun configureCore(context: Context) {
        // We will create a directory for user signed certificates if needed
        val basePath = context.filesDir.absolutePath
        val userCerts = "$basePath/user-certs"
        val f = File(userCerts)
        if (!f.exists()) {
            if (!f.mkdir()) {
                Log.e(TAG, "$userCerts can't be created.")
            }
        }
        mCore?.userCertificatesPath = userCerts
    }





    fun login(username: String?, password: String, domain: String) {
        Log.e("username", username)
        Log.e("password", password)
        Log.e("domain", domain)

        val mAccountCreator = mCore?.createAccountCreator(null)
        mAccountCreator?.username = username
        mAccountCreator?.password = password
        mAccountCreator?.domain = domain
        mAccountCreator?.transport = TransportType.Tcp
        val cfg: ProxyConfig? = mAccountCreator?.createProxyConfig()
        mCore?.defaultProxyConfig = cfg
    }

    fun call(number: String, call_id: String, user_id: String) {
        val addressToCall: Address? = mCore?.interpretUrl(number)
        val params: CallParams? = mCore?.createCallParams(null)
        params?.enableAudio(true)
        if (addressToCall != null) {
            params?.addCustomHeader("X-Call-Id", call_id)
            params?.addCustomHeader("X-User-Id", user_id)
            mCore?.inviteAddressWithParams(addressToCall, params!!)
        }
    }

    fun accept() {
        val core = mCore
        if (core != null) {
            val call: Call? = core.currentCall
            call?.let {
                val params: CallParams? = core.createCallParams(call!!)
                params?.enableAudio(true)
                call.acceptWithParams(params)
            }
        }
    }

    fun decline() {
        val core = mCore
        if (core != null) {
            val call: Call? = core.currentCall
            call?.decline(Reason.Declined)
        }
    }

    fun endCall() {
        val core = mCore
        if (core != null) {
            if (core.callsNb > 0) {
                var call: Call? = core.currentCall
                if (call == null) call =
                    core.calls[0]
                call?.terminate()
            }
        }
    }

    fun logout() {
        try {
            val cfg = mCore?.defaultProxyConfig
            if (cfg != null) {
                mCore?.removeProxyConfig(cfg)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun dumDeviceInformation() {
        val sb = StringBuilder()
        sb.append("DEVICE=").append(Build.DEVICE).append("\n")
        sb.append("MODEL=").append(Build.MODEL).append("\n")
        sb.append("MANUFACTURER=").append(Build.MANUFACTURER).append("\n")
        sb.append("SDK=").append(Build.VERSION.SDK_INT).append("\n")
        sb.append("Supported ABIs=")

        for (abi in Version.getCpuAbis()) {
            sb.append(abi).append(", ")
        }
        sb.append("\n")
    }
}
