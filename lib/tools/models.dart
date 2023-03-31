// Parsed with: https://app.quicktype.io/

import 'dart:convert';

// To parse this JSON data, do
//
//     final schooldays = schooldaysFromJson(jsonString);

List<Schooldays> schooldaysFromJson(String str) =>
    List<Schooldays>.from(json.decode(str).map((x) => Schooldays.fromJson(x)));

String schooldaysToJson(List<Schooldays> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Schooldays {
  Schooldays({
    required this.admonitions,
    required this.id,
    required this.missedclasses,
    required this.schoolday,
  });

  List<Admonition> admonitions;
  int? id;
  List<Missedclass> missedclasses;
  DateTime schoolday;

  factory Schooldays.fromJson(Map<String, dynamic> json) => Schooldays(
        admonitions: List<Admonition>.from(
            json["admonitions"].map((x) => Admonition.fromJson(x))),
        id: json["id"],
        missedclasses: List<Missedclass>.from(
            json["missedclasses"].map((x) => Missedclass.fromJson(x))),
        schoolday: DateTime.parse(json["schoolday"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "admonitions": List<dynamic>.from(admonitions.map((x) => x.toJson())),
        "id": id,
        "missedclasses":
            List<dynamic>.from(missedclasses.map((x) => x.toJson())),
        "schoolday":
            "${schoolday.year.toString().padLeft(4, '0')}-${schoolday.month.toString().padLeft(2, '0')}-${schoolday.day.toString().padLeft(2, '0')}",
      };
}

class Admonition {
  Admonition({
    required this.admonishedpupilId,
    required this.admonitionreason,
    required this.admonitiontype,
  });

  int admonishedpupilId;
  String admonitionreason;
  String admonitiontype;

  factory Admonition.fromJson(Map<String, dynamic> json) => Admonition(
        admonishedpupilId: json["admonishedpupil_id"],
        admonitionreason: json["admonitionreason"],
        admonitiontype: json["admonitiontype"],
      );

  Map<String, dynamic> toJson() => {
        "admonishedpupil_id": admonishedpupilId,
        "admonitionreason": admonitionreason,
        "admonitiontype": admonitiontype,
      };
}

class Missedclass {
  Missedclass(
      {required this.excused,
      required this.contacted,
      required this.returned,
      required this.missedpupilId,
      required this.missedtype,
      required this.createdBy,
      required this.modifiedBy,
      required this.lateAt,
      required this.returnedAt});

  bool excused;
  bool contacted;
  bool? returned;
  int missedpupilId;
  String missedtype;
  String createdBy;
  String? modifiedBy;
  String? lateAt;
  String? returnedAt;

  factory Missedclass.fromJson(Map<String, dynamic> json) => Missedclass(
      excused: json["excused"],
      contacted: json["contacted"],
      returned: json["returned"],
      missedpupilId: json["missedpupil_id"],
      missedtype: json["missedtype"],
      createdBy: json["created_by"],
      modifiedBy: json["modified_by"],
      lateAt: json["late_at"],
      returnedAt: json["returned_at"]);

  Map<String, dynamic> toJson() => {
        "excused": excused,
        "contacted": contacted,
        "missedpupil_id": missedpupilId,
        "missedtype": missedtype,
        "returned": returned,
        "created_by": createdBy,
        "modified_by": modifiedBy,
        "late_at": lateAt,
        "returned_at": returnedAt,
      };
}

// To parse this JSON data, do
//
//     final hermannpupil = hermannpupilFromJson(jsonString);

List<Hermannpupil> hermannpupilFromJson(String str) => List<Hermannpupil>.from(
    json.decode(str).map((x) => Hermannpupil.fromJson(x)));

String hermannpupilToJson(List<Hermannpupil> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Hermannpupil {
  Hermannpupil({
    required this.credit,
    required this.group,
    required this.id,
    required this.name,
    required this.pupiladmonitions,
    required this.pupilmissedclasses,
    required this.schoolyear,
    required this.ogs,
  });

  int credit;
  String group;
  int id;
  String name;
  List<Pupiladmonition> pupiladmonitions;
  List<Pupilmissedclass> pupilmissedclasses;
  String schoolyear;
  bool ogs;

  factory Hermannpupil.fromJson(Map<String, dynamic> json) => Hermannpupil(
        credit: json["credit"],
        group: json["group"],
        id: json["id"],
        name: json["name"],
        pupiladmonitions: List<Pupiladmonition>.from(
            json["pupiladmonitions"].map((x) => Pupiladmonition.fromJson(x))),
        pupilmissedclasses: List<Pupilmissedclass>.from(
            json["pupilmissedclasses"]
                .map((x) => Pupilmissedclass.fromJson(x))),
        schoolyear: json["schoolyear"],
        ogs: json["ogs"],
      );

  Map<String, dynamic> toJson() => {
        "credit": credit,
        "group": group,
        "id": id,
        "name": name,
        "pupiladmonitions":
            List<dynamic>.from(pupiladmonitions.map((x) => x.toJson())),
        "pupilmissedclasses":
            List<dynamic>.from(pupilmissedclasses.map((x) => x.toJson())),
        "schoolyear": schoolyear,
        "ogs": ogs,
      };
}

enum Group { A1, A2, A3, B1, B2, B3, B4, C1, C2, C3 }

// final groupValues = EnumValues({
//     "A1": Group.A1,
//     "A2": Group.A2,
//     "A3": Group.A3,
//     "B1": Group.B1,
//     "B2": Group.B2,
//     "B3": Group.B3,
//     "B4": Group.B4,
//     "C1": Group.C1,
//     "C2": Group.C2,
//     "C3": Group.C3

// });

class Pupiladmonition {
  Pupiladmonition({
    required this.admonishedSchoolday,
    required this.admonitionreason,
    required this.admonitiontype,
  });

  DateTime admonishedSchoolday;
  String admonitionreason;
  String admonitiontype;

  factory Pupiladmonition.fromJson(Map<String, dynamic> json) =>
      Pupiladmonition(
        admonishedSchoolday:
            DateTime.parse(json["admonished_schoolday"].toString()),
        admonitionreason: json["admonitionreason"],
        admonitiontype: json["admonitiontype"],
      );

  Map<String, dynamic> toJson() => {
        "admonished_schoolday":
            "${admonishedSchoolday.year.toString().padLeft(4, '0')}-${admonishedSchoolday.month.toString().padLeft(2, '0')}-${admonishedSchoolday.day.toString().padLeft(2, '0')}",
        "admonitionreason": admonitionreason,
        "admonitiontype": admonitiontype,
      };
}

class Pupilmissedclass {
  Pupilmissedclass(
      {required this.excused,
      required this.contacted,
      required this.returned,
      required this.missedSchoolday,
      required this.missedtype,
      required this.createdBy,
      required this.modifiedBy,
      required this.lateAt,
      required this.returnedAt});

  bool excused;
  bool contacted;
  bool? returned;
  DateTime missedSchoolday;
  String missedtype;
  String createdBy;
  String? modifiedBy;
  String? lateAt;
  String? returnedAt;

  factory Pupilmissedclass.fromJson(Map<String, dynamic> json) =>
      Pupilmissedclass(
          excused: json["excused"],
          contacted: json["contacted"],
          returned: json["returned"],
          missedSchoolday: DateTime.parse(json["missed_schoolday"]),
          missedtype: json["missedtype"],
          createdBy: json["created_by"],
          modifiedBy: json["modified_by"],
          lateAt: json["late_at"],
          returnedAt: json["returned_at"]);

  Map<String, dynamic> toJson() => {
        "excused": excused,
        "contacted": contacted,
        "missed_schoolday":
            "${missedSchoolday.year.toString().padLeft(4, '0')}-${missedSchoolday.month.toString().padLeft(2, '0')}-${missedSchoolday.day.toString().padLeft(2, '0')}",
        "missedtype": missedtype,
        "created_by": createdBy,
        "modified_by": modifiedBy,
        "late_at": lateAt,
        "returned_at": returnedAt,
      };
}

enum Schoolyear { E2, E1, E3, S3, S4 }

// final schoolyearValues = EnumValues({
//     "E1": Schoolyear.E1,
//     "E2": Schoolyear.E2,
//     "E3": Schoolyear.E3,
//     "S3": Schoolyear.S3,
//     "S4": Schoolyear.S4,

// });

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(
    this.map,
    this.reverseMap,
  );

  Map<T, String> get reverse {
    // ignore: unnecessary_null_comparison
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}

// To parse this JSON data, do
//
//     final coronastatus = coronastatusFromJson(jsonString);

List<Coronastatus> coronastatusFromJson(String str) => List<Coronastatus>.from(
    json.decode(str).map((x) => Coronastatus.fromJson(x)));

String coronastatusToJson(List<Coronastatus> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Coronastatus {
  Coronastatus({
    required this.coronaStatus,
    required this.coronapupilId,
    required this.untildate,
  });

  String coronaStatus;
  int coronapupilId;
  DateTime untildate;

  factory Coronastatus.fromJson(Map<String, dynamic> json) => Coronastatus(
        coronaStatus: json["corona_status"],
        coronapupilId: json["coronapupil_id"],
        untildate: DateTime.parse(json["untildate"]),
      );

  Map<String, dynamic> toJson() => {
        "corona_status": coronaStatus,
        "coronapupil_id": coronapupilId,
        "untildate":
            "${untildate.year.toString().padLeft(4, '0')}-${untildate.month.toString().padLeft(2, '0')}-${untildate.day.toString().padLeft(2, '0')}",
      };
}

// To parse this JSON data, do
//
//     final codedNames = codedNamesFromJson(jsonString);

List<CodedNames> codedNamesFromJson(String str) =>
    List<CodedNames>.from(json.decode(str).map((x) => CodedNames.fromJson(x)));

String codedNamesToJson(List<CodedNames> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CodedNames {
  CodedNames({
    required this.name,
    required this.code,
  });

  String name;
  String code;

  factory CodedNames.fromJson(Map<String, dynamic> json) => CodedNames(
        name: json["name"],
        code: json["c"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "c": code,
      };
}
