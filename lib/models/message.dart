class Message {
  Message({
    this.id,
    this.from,
    this.to,
    this.message,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String from;
  String to;
  String message;
  DateTime createdAt;
  DateTime updatedAt;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["_id"],
        from: json["from"],
        to: json["to"],
        message: json["message"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "from": from,
        "to": to,
        "message": message,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
