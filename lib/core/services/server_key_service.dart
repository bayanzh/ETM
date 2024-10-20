import 'package:googleapis_auth/auth_io.dart';

class ServerKeyService {
  static Future<String?> getServerKeyToken() async {
    try {
      List<String> scopes = [
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/firebase.database',
        'https://www.googleapis.com/auth/firebase.messaging'
      ];

      final serviceAccountJson = {
        "type": "service_account",
        "project_id": "e-trainig-mate",
        "private_key_id": "bce95fef1e6cd6dd7a97302ab77278e8c3795b64",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDosq+NCoon8B8o\nQnYOTX/Ug605kWM3SlsfWkiX6IouIalUQhOiSn6GsaMFL57Ke17mYeeQHNmiX3g7\nnt8W1fVr6AP4avAgDgLtUPegKwrNmQjI96dZmOzCIESitkh3Sysxjz0EzISkYQtC\nmhtQkQpXFBRlOdIb1ZKPFYSSCMDX9W0Rtc4+FNZhs9Z9DmlQyxYrLxo1YjnO8xU/\nmEHi1ai6LqdD32r6JZ2v55IN5hRdpOE7o89fWiX39bXbWN2cNnixlJl7UL5CJj+1\niN1NxIPujwsnUfTNkd+T46tozUMC6O1X/AP0qJ8mWwn/czAqyyHlm3Y2eamvV7Kn\nVc2D0Hs1AgMBAAECggEAErVTAd7oDp/ykVUOksXOUjKn+anjtS1IODQVBAmRGnZg\nW8LYO0ML+x5LAf67IIJctd8HNAHtyW0tiHWUcAyRp7RGpXFLjvgxag0Ja5oqSy9T\nkny+uqhd2Jmpiv9mwhiMB3cBq+IZg/G9awRiz85pa2jU3vKQHubD2rcbKnaDspkE\ne81GbrrpmezvN6ouijMOUmhkTnw2OpRB/nw4TLhHp7u+6W4LpnQVqMv/SvpWnxsm\n5eUaeXLeIBQjtC5QIsUqKJRuP7zPpRDN670HiKSfJnW/1kg+auuJt+VcLwPI+nV6\nubK5Da66/QZxo5FilkE0Ol+Mfge1rJzZe3w4BLp2PQKBgQD/Qc4zthEDk/HXpqxR\nycuowbPdC3cM8+NXz/PTZ6oA/pv/RFPkNuvPBpZNlgkg4f8WkakWGzd3oPliTRRv\ngw+2OAKiTDtAOLE6y9dqyc0Ww7aOr0VdIe9pJk8iaC7I6GeaRbH1tQ2RDyDQqi3q\nnnpiFQv385UpSrNIinKDtRZGxwKBgQDpYBJANaUQhBNF48YGBJBVlRO3RDokN7EE\nlB67r/SWxoiqLRJ+n943kIG0ElYMC8PRUWgrj/YyZjqTYdvbgpGOKPxgm4ZvtcUj\nZgb+ggP4wE0gfnVoPhM/mhTMa/J7jJyShCc7RJ7cWbiD9fGM49Q/kWjTQkBLhA1O\npTwgtM7CIwKBgB4SeaGb/IsoXeCjMT/9fzHliDQtipwLC6inxjkMyHmPhX9gZGXJ\nlqRwSTrgxziJh4z4IiyJjlJYs6jCHfs5PJuiI6VNR9m8FB0yMLHTDod1DUfoHErp\nmZQQwFf0YDapMrN5LIsfBnclih8rPXebrh1qD1vp5ZPUyiRssysTJYm3AoGBAK+F\nK/TS4+R6ESy9VI/uGsfjKULqs3fN0vsIk9zBR4mmo96pq4FEp5LOwl42dDT3HD1v\nppMs4ROiw2dZcEu19dcfiED4d7HI2g33jEcabfZGWzuXIKJYHY32SrI8ddDqPlAL\nyJ3QzFIZwKau8Q7vwxBUQqyw5T5mgMOnjoNiuSZVAoGAaGiU4qFNwEMiPGLRQEtH\nJxIAo4EsL7bxN72nQYdkZESSKi46wzTTLvVbsnGX+rVgigGXCszSpjApIecRgOV/\ns7fmiH9ruYAYYduYRV7+krCX8SB3BDqgWfoO57NFax7rorSjumWKQD94IxymK6DP\n57iDvIygzyQuCzzgsZXM948=\n-----END PRIVATE KEY-----\n",
        "client_email": "firebase-adminsdk-7p6u1@e-trainig-mate.iam.gserviceaccount.com",
        "client_id": "101264173121007500884",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-7p6u1%40e-trainig-mate.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      };

      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );

     

      // get access token using this client
      AccessCredentials credentials = await obtainAccessCredentialsViaServiceAccount(
        ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client,
      );
      
      // close the client
      client.close();
      return credentials.accessToken.data;
    } catch (e) {
      return null;
    }
  }
}
