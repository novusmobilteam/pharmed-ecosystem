// class CabinStatusNotifier extends ChangeNotifier {
//   final ICabinOperationService _cabinOperationService;
//   final OpenDrawerUseCase _openDrawerUseCase;
//   final HandleSensorStatusUseCase _handleSensorStatusUseCase;

//   CabinStatusNotifier({
//     required ICabinOperationService cabinOperationService,
//     required OpenDrawerUseCase openDrawerUseCase,
//     required HandleSensorStatusUseCase handleSensorStatusUseCase,
//   }) : _cabinOperationService = cabinOperationService,
//        _openDrawerUseCase = openDrawerUseCase,
//        _handleSensorStatusUseCase = handleSensorStatusUseCase;

//   // Çekmece Durumu
//   DrawerStage _stage = DrawerStage.idle;
//   DrawerStage get stage => _stage;

//   DrawerPhysicalStatus _lastPhysicalStatus = DrawerPhysicalStatus.unknown;
//   DrawerPhysicalStatus get physicalStatus => _lastPhysicalStatus;

//   // Mesaj
//   String _message = "";
//   String get message => _message;

//   // İşlem yapılan Çekmece
//   CabinAssignment? _assignment;
//   CabinAssignment? get assignment => _assignment;

//   StreamSubscription<DrawerPhysicalStatus>? _sensorSubscription;

//   // Kübik çekmecede işlem yaparken çekmece açıldıktan sonra kapağı da açıyoruz fakat
//   // iade işlemi sırasında ilacın iade tipi 'Çekmeceye İade' ise sadece çekmece açılıyor kapak açılmıyor.
//   Future<void> startOperation(CabinAssignment item, {double requestedQuantity = 0.0, bool openCubicLid = true}) async {
//     reset();
//     _assignment = item;

//     try {
//       await _openDrawerUseCase.call(
//         item: item,
//         requestedQuantity: requestedQuantity,
//         onUpdate: (stage, message) => _updateStage(stage, message),
//         openCubicLid: openCubicLid,
//         onReadyToMonitor: (manager, address) {
//           _startSensorSubscription(item, manager, address, openCubicLid: openCubicLid);
//         },
//       );
//     } catch (e) {
//       _updateStage(DrawerStage.error, "Hata: ${e.toString()}");
//     }
//   }

//   void _startSensorSubscription(
//     CabinAssignment item,
//     ManagementCard manager,
//     DrawerAddress address, {
//     bool openCubicLid = true,
//   }) {
//     _sensorSubscription?.cancel();

//     final isSerum = item.drawerUnit?.drawerSlot?.drawerConfig?.isSerum ?? false;
//     final sensorStream = isSerum
//         ? _cabinOperationService.monitorSerumStatus(manager: manager, row: address.row)
//         : _cabinOperationService.monitorDrawerStatus(
//             manager: manager,
//             row: address.row,
//             port: address.port,
//             drawer: address.index,
//           );

//     _sensorSubscription = sensorStream.listen((status) {
//       _lastPhysicalStatus = status;

//       // 2. HER DURUM DEĞİŞİMİNDE UseCase'i tetikliyoruz
//       _handleSensorStatusUseCase.call(
//         status: status,
//         currentStage: _stage,
//         assignment: _assignment!,
//         manager: manager,
//         openCubicLid: openCubicLid,
//         onUpdate: (stage, message) => _updateStage(stage, message),
//       );
//     });
//   }

//   // Dolum bitti (UI TETİKLER)
//   void confirmFillingCompleted() {
//     if (_assignment == null) return;

//     _cabinOperationService.triggerManualClose();

//     if (_stage == DrawerStage.completed || _stage == DrawerStage.error) {
//       return;
//     }

//     _updateStage(DrawerStage.waitingForClose, "Lütfen çekmeceyi KAPATINIZ.");
//   }

//   void _updateStage(DrawerStage newStage, String msg) {
//     _stage = newStage;
//     _message = msg;
//     notifyListeners();
//   }

//   void reset() {
//     _sensorSubscription?.cancel();
//     _assignment = null;
//     _stage = DrawerStage.idle;
//     _message = "";
//     _lastPhysicalStatus = DrawerPhysicalStatus.unknown;
//   }

//   @override
//   void dispose() {
//     _sensorSubscription?.cancel();
//     super.dispose();
//   }
// }
