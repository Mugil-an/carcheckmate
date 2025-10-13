import 'package:equatable/equatable.dart';

class VehicleDetails extends Equatable {
  final String rc;
  final String vinMasked;
  final String engineNoMasked;
  final String makerModel;
  final String fuel;
  final String taxStatus;
  final String rcValidTill;
  final String blacklist;
  final LienStatus? lienStatus;
  final FitnessStatus fitnessStatus;

  const VehicleDetails({
    required this.rc,
    required this.vinMasked,
    required this.engineNoMasked,
    required this.makerModel,
    required this.fuel,
    required this.taxStatus,
    required this.rcValidTill,
    required this.blacklist,
    this.lienStatus,
    required this.fitnessStatus,
  });

  @override
  List<Object?> get props => [
        rc,
        vinMasked,
        engineNoMasked,
        makerModel,
        fuel,
        taxStatus,
        rcValidTill,
        blacklist,
        lienStatus,
        fitnessStatus,
      ];
}

class LienStatus extends Equatable {
  final String status;
  final String bank;
  final String activeFrom;
  final String activeTo;

  const LienStatus({
    required this.status,
    required this.bank,
    required this.activeFrom,
    required this.activeTo,
  });

  bool get isActive => status.toLowerCase() == 'active';

  @override
  List<Object> get props => [status, bank, activeFrom, activeTo];
}

class FitnessStatus extends Equatable {
  final String status;
  final String fitnessValidTill;
  final String rcValidTill;

  const FitnessStatus({
    required this.status,
    required this.fitnessValidTill,
    required this.rcValidTill,
  });

  bool get isValid => status.toLowerCase().contains('ok');

  @override
  List<Object> get props => [status, fitnessValidTill, rcValidTill];
}