import 'dart:io' show Platform;

class Secret {
  static const ANDROID_CLIENT_ID =
      "753457259745-c2tuof4neqovn7d652ug0ftv13kut15o.apps.googleusercontent.com";
  static const IOS_CLIENT_ID =
      "753457259745-sh4lf9pufvoq3070oq7vg6j95h33mamt.apps.googleusercontent.com";
  static String getId() =>
      Platform.isAndroid ? Secret.ANDROID_CLIENT_ID : Secret.IOS_CLIENT_ID;
}
