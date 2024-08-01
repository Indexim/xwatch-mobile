class Tools {
  String intToTimeLeft(int value) {
    int h, m;

    h = value ~/ 60;

    m = ((value - h * 60));

    String hourLeft = h.toString().length < 2 ? "0$h" : h.toString();

    String minuteLeft = m.toString().length < 2 ? "0$m" : m.toString();

    String result = "$hourLeft:$minuteLeft";

    return result;
  }

  String intToTimeLeftWithMinute(int value) {
    int h, m, s;

    h = value ~/ 3600;

    m = ((value - h * 3600)) ~/ 60;

    s = value - (h * 3600) - (m * 60);

    String hourLeft = h.toString().length < 2 ? "0$h" : h.toString();

    String minuteLeft =
        m.toString().length < 2 ? "0$m" : m.toString();

    String secondsLeft =
        s.toString().length < 2 ? "0$s" : s.toString();

    String result = "$hourLeft:$minuteLeft:$secondsLeft";

    return result;
  }

  Map<String, dynamic> parseStringToMap(String inputString) {
    // Implementasi logika untuk memproses string dan menghasilkan Map dari data yang relevan
    // Di sini Anda bisa menggunakan ekspresi reguler atau pendekatan parsing kustom sesuai kebutuhan.
    // Contoh sederhana, hanya untuk ilustrasi:
    // Misalnya, memisahkan berdasarkan ',' dan '=' untuk mendapatkan key dan value.

    inputString = inputString.replaceAll('[HomeDataRepository] HR - ', '');
    inputString = inputString.substring(1, inputString.length - 1);
    inputString = inputString.replaceAll('DailyHrReport', '');
    // debugPrint("dataString: $dataString");

    String cleanedString = inputString.substring(1, inputString.length - 1);
    // Pengolahan string dilakukan di sini, contoh sederhana:
    Map<String, dynamic> parsedData = {};

    // Proses pemisahan berdasarkan ',' dan '='
    List<String> parts = cleanedString.split(',');

    for (String part in parts) {
      List<String> keyValue = part.split('=');
      if (keyValue.length == 2) {
        String key = keyValue[0].trim();
        String value = keyValue[1].trim();

        // Cek apakah value merupakan objek yang perlu di-parse lebih dalam (seperti hrRecords)
        // Misalnya, untuk hrRecords, Anda mungkin perlu proses array valueArray.

        // Tambahkan ke dalam parsedData
        parsedData[key] = value;
      }
    }

    return parsedData;
  }
}