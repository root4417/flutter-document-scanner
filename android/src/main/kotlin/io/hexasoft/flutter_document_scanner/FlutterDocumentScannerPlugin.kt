package io.hexasoft.flutter_document_scanner

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import android.app.Activity
import android.app.ActivityOptions
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.os.StrictMode
import android.provider.MediaStore
import android.util.Log
import android.view.View
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList
import android.R.attr.data
import android.content.Context
import android.database.Cursor
import androidx.core.net.toFile
import com.scanlibrary.ScanActivity
import com.scanlibrary.ScanConstants
import kotlin.collections.HashMap
import android.content.pm.PackageManager
import android.content.pm.ProviderInfo
import android.content.pm.PackageManager.GET_META_DATA
import androidx.core.content.FileProvider


/** FlutterDocumentScannerPlugin */
class FlutterDocumentScannerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var call: MethodCall
    private lateinit var applicationContext: Context
    private var fileProviderAuthority: String? = null

    /// For activity binding
    private var activityPluginBinding: ActivityPluginBinding? = null
    private var result: Result? = null

    /// For scanner library
    companion object {
        val SCAN_REQUEST_CODE: Int = 101
    }


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

        applicationContext = flutterPluginBinding.applicationContext
        // Check if FileProvider authority is set
        val isAuthoritySet = isFileProviderAuthoritySet(applicationContext)
        println("isAuthoritySet: $isAuthoritySet")
        if (isAuthoritySet) {
            fileProviderAuthority = getFileProviderAuthority(applicationContext)
            println("fileProviderAuthority: $fileProviderAuthority")
            if(fileProviderAuthority != null){
                print("Channel Initialized for FlutterDocumentScanner")
                channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_document_scanner")
                channel.setMethodCallHandler(this)
            }else{
                throw RuntimeException("FileProvider authority is not set. Please configure the authority value in your AndroidManifest.xml.")
            }
        } else {
            throw RuntimeException("FileProvider authority is not set. Please configure the authority value in your AndroidManifest.xml.")
        }

    }
    private fun isFileProviderAuthoritySet(context: Context): Boolean {
        println("Context: $context")
        val packageInfo = context.packageManager.getPackageInfo(context.packageName, PackageManager.GET_PROVIDERS)
        println("PackageInfo: $packageInfo")
        val providers = packageInfo.providers
        println("providers: $providers")
        return providers?.any(::hasNonEmptyAuthority) == true
    }

    private fun hasNonEmptyAuthority(provider: ProviderInfo): Boolean {
        val isNonEmpty = provider.authority?.isNotEmpty() == true
        if (isNonEmpty) {
            println("Provider Authority: ${provider.authority}")
        }
        return isNonEmpty
    }


    private fun getFileProviderAuthority(context: Context): String? {
        val packageManager = context.packageManager
        println("packageManager: $packageManager")
        val packageInfo = packageManager.getPackageInfo(context.packageName, PackageManager.GET_PROVIDERS)
        println("packageInfo: $packageInfo")
        val providers = packageInfo.providers
        println("providers: $packageInfo")

        providers?.forEach { providerInfo: ProviderInfo ->
            val authority = providerInfo.authority
            if (authority?.isNotEmpty() == true) {
                return authority
            }
        }

        return null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        this.call = call
        this.result = result
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "camera") {
            camera();
        } else if (call.method == "gallery") {
            gallery();
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activityPluginBinding?.removeActivityResultListener(this)
        activityPluginBinding = null
    }

    private fun composeIntentArguments(intent:Intent) = mapOf(
        ScanConstants.SCAN_NEXT_TEXT to "ANDROID_NEXT_BUTTON_LABEL",
        ScanConstants.SCAN_SAVE_TEXT to "ANDROID_SAVE_BUTTON_LABEL",
        ScanConstants.SCAN_ROTATE_LEFT_TEXT to "ANDROID_ROTATE_LEFT_LABEL",
        ScanConstants.SCAN_ROTATE_RIGHT_TEXT to "ANDROID_ROTATE_RIGHT_LABEL",
        ScanConstants.SCAN_ORG_TEXT to "ANDROID_ORIGINAL_LABEL",
        ScanConstants.SCAN_BNW_TEXT to "ANDROID_BMW_LABEL",
        ScanConstants.SCAN_SCANNING_MESSAGE to "ANDROID_SCANNING_MESSAGE",
        ScanConstants.SCAN_LOADING_MESSAGE to "ANDROID_LOADING_MESSAGE",
        ScanConstants.SCAN_APPLYING_FILTER_MESSAGE to "ANDROID_APPLYING_FILTER_MESSAGE",
        ScanConstants.SCAN_CANT_CROP_ERROR_TITLE to "ANDROID_CANT_CROP_ERROR_TITLE",
        ScanConstants.SCAN_CANT_CROP_ERROR_MESSAGE to "ANDROID_CANT_CROP_ERROR_MESSAGE",
        ScanConstants.SCAN_OK_LABEL to "ANDROID_OK_LABEL",
    ).entries.filter { call.hasArgument(it.value) && call.argument<String>(it.value) != null }.forEach {
        intent.putExtra(it.key,  call.argument<String>(it.value))
    }

    private fun camera() {
        activityPluginBinding?.activity?.apply {
            val intent = Intent(this, ScanActivity::class.java)
            intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE,  ScanConstants.OPEN_CAMERA)
            intent.putExtra(ScanConstants.FILE_PROVIDER_AUTHORITY,  fileProviderAuthority)
            composeIntentArguments(intent)
            startActivityForResult(intent, SCAN_REQUEST_CODE)
        }
    }

    private fun gallery() {
        activityPluginBinding?.activity?.apply {
            val intent = Intent(this, ScanActivity::class.java)
            intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, ScanConstants.OPEN_MEDIA)
            intent.putExtra(ScanConstants.FILE_PROVIDER_AUTHORITY,  fileProviderAuthority)
            composeIntentArguments(intent)
            startActivityForResult(intent, SCAN_REQUEST_CODE)
        }
    }

    fun getRealPathFromUri(context: Context, contentUri: Uri?): String? {
        var cursor: Cursor? = null
        return try {
            val proj = arrayOf(MediaStore.Images.Media.DATA)
            cursor = context.getContentResolver().query(contentUri!!, proj, null, null, null)
            val column_index: Int = cursor!!.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
            cursor.moveToFirst()
            cursor.getString(column_index)
        } finally {
            if (cursor != null) {
                cursor.close()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        // React to activity result and if request code == ResultActivity.REQUEST_CODE
        return when (resultCode) {
            Activity.RESULT_OK -> {
                if (requestCode == SCAN_REQUEST_CODE) {
                    activityPluginBinding?.activity?.apply {
                        val uri = data!!.extras!!.getParcelable<Uri>(ScanConstants.SCANNED_RESULT)
                        println(uri)
                        result?.success(getRealPathFromUri(activityPluginBinding!!.activity,uri))
                    }
                }
                true
            }
            else -> false
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
}
