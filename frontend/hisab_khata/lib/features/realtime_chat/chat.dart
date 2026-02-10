// Chat Feature Exports
// This file exports all necessary components for the chat feature

// BLoC
export 'presentation/bloc/chat_bloc.dart';
export 'presentation/bloc/chat_event.dart';
export 'presentation/bloc/chat_state.dart';

// Screens
export 'presentation/screens/chat_rooms_screen.dart';
export 'presentation/screens/chat_detail_screen.dart';

// Widgets
export 'presentation/widgets/message_bubble.dart';
export 'presentation/widgets/message_list.dart';
export 'presentation/widgets/chat_input.dart';
export 'presentation/widgets/chat_room_list_item.dart';
export 'presentation/widgets/typing_indicator.dart';

// Entities
export 'domain/entities/chat_room_entity.dart';
export 'domain/entities/message_entity.dart';
export 'domain/entities/chat_user_entity.dart';

// Provider
export 'chat_provider.dart';

// WebSocket Service
export 'data/datasources/chat_websocket_service.dart';
