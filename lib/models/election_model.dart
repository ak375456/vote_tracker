class Election {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, List<Map<String, dynamic>>> candidatesByDistrict;

  Election({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.candidatesByDistrict,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'candidatesByDistrict': candidatesByDistrict,
    };
  }

  static Election fromMap(Map<String, dynamic> map) {
    return Election(
      id: map['id'],
      startTime: map['startTime'].toDate(),
      endTime: map['endTime'].toDate(),
      candidatesByDistrict: Map<String, List<Map<String, dynamic>>>.from(
          map['candidatesByDistrict']),
    );
  }
}
