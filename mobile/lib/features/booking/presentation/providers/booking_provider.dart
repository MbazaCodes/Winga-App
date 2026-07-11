import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/request_repository.dart';
import '../../domain/request_model.dart';

final requestRepositoryProvider = Provider((_) => RequestRepository());

// Booking form state
class BookingState {
  final String? category;
  final String? meetingPoint;
  final String? shoppingArea;
  final String serviceType;
  final String deliveryMethod;
  final int shopCount;
  final String? note;
  final int? budgetIndex;
  final Set<int> goals;
  final bool preferFemaleWinga;

  const BookingState({
    this.category,
    this.meetingPoint,
    this.shoppingArea,
    this.serviceType = 'hourly',
    this.deliveryMethod = 'with_client',
    this.shopCount = 3,
    this.note,
    this.budgetIndex,
    this.goals = const {},
    this.preferFemaleWinga = false,
  });

  BookingState copyWith({
    String? category,
    String? meetingPoint,
    String? shoppingArea,
    String? serviceType,
    String? deliveryMethod,
    int? shopCount,
    String? note,
    int? budgetIndex,
    Set<int>? goals,
    bool? preferFemaleWinga,
  }) =>
      BookingState(
        category: category ?? this.category,
        meetingPoint: meetingPoint ?? this.meetingPoint,
        shoppingArea: shoppingArea ?? this.shoppingArea,
        serviceType: serviceType ?? this.serviceType,
        deliveryMethod: deliveryMethod ?? this.deliveryMethod,
        shopCount: shopCount ?? this.shopCount,
        note: note ?? this.note,
        budgetIndex: budgetIndex ?? this.budgetIndex,
        goals: goals ?? this.goals,
        preferFemaleWinga: preferFemaleWinga ?? this.preferFemaleWinga,
      );

  int get estimatedPrice {
    switch (serviceType) {
      case 'half_day': return 25000;
      case 'full_day': return 40000;
      default: return 15000;
    }
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final RequestRepository _repo;

  BookingNotifier(this._repo) : super(const BookingState());

  void setCategory(String v)       => state = state.copyWith(category: v);
  void setMeetingPoint(String v)   => state = state.copyWith(meetingPoint: v);
  void setShoppingArea(String v)   => state = state.copyWith(shoppingArea: v);
  void setServiceType(String v)    => state = state.copyWith(serviceType: v);
  void setDeliveryMethod(String v) => state = state.copyWith(deliveryMethod: v);
  void setShopCount(int v)         => state = state.copyWith(shopCount: v);
  void setNote(String v)           => state = state.copyWith(note: v);
  void toggleGoal(int i) {
    final updated = Set<int>.from(state.goals);
    if (updated.contains(i)) { updated.remove(i); } else { updated.add(i); }
    state = state.copyWith(goals: updated);
  }
  void reset() => state = const BookingState();

  Future<RequestModel?> submitRequest() async {
    if (state.category == null || state.meetingPoint == null) return null;
    return await _repo.createRequest(
      category: state.category!,
      meetingPoint: state.meetingPoint!,
      shoppingArea: state.shoppingArea ?? 'Kariakoo Market',
      serviceType: state.serviceType,
      deliveryMethod: state.deliveryMethod,
      estimatedPrice: state.estimatedPrice,
      note: state.note,
    );
  }
}

final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier(ref.read(requestRepositoryProvider));
});

// Active request stream
final activeRequestProvider =
    StreamProvider.family<RequestModel, String>((ref, id) {
  return ref.read(requestRepositoryProvider).watchRequest(id);
});

// My requests list
final myRequestsProvider = FutureProvider<List<RequestModel>>((ref) {
  return ref.read(requestRepositoryProvider).getMyRequests();
});
