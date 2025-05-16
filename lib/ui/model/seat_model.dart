enum SeatType { empty, booked, ladies }


class BusSeatItem {
  final String? seatNo;
  final String? seatStatus;
  final bool? isLadies;
  final bool? isFemale;

  BusSeatItem({
    this.seatNo,
    this.seatStatus,
    this.isLadies,
    this.isFemale,
  });

  factory BusSeatItem.fromJson(Map<String, dynamic> json) {
    return BusSeatItem(
      seatNo: json['seat_no'],
      seatStatus: (json['seat_status'] as String?)?.toUpperCase(),
      isLadies: json['is_ladies'] == true,
      isFemale: json['is_female'] == true || json['is_female'] == "true",
    );
  }
}

class SeatModel {
  final SeatType type;
  SeatModel(this.type);
}

class EdgeItem {
  final String? seatNo;
  final bool? isFemale;
  EdgeItem(this.seatNo, this.isFemale);
}

class EdgeItemNew {
  final bool? isFemale;
  EdgeItemNew(this.isFemale);
}