# Architecture Documentation 🏗️

**By Laith Abo Assaf**

## Clean Architecture Overview

This project follows **Clean Architecture** principles, separating the codebase into three main layers:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, BLoC, Pages, Widgets)            │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│          Domain Layer                   │
│  (Entities, Use Cases, Repositories)   │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│           Data Layer                    │
│  (Models, Data Sources, API)           │
└─────────────────────────────────────────┘
```

## Layer Responsibilities

### 1. Presentation Layer
**Location:** `lib/features/*/presentation/`

**Responsibilities:**
- Display UI
- Handle user interactions
- Manage UI state with BLoC
- Show loading, error, and success states

**Components:**
- **Pages**: Full screen widgets
- **Widgets**: Reusable UI components
- **BLoC**: State management (Events, States, BLoC)

**Example Structure:**
```
presentation/
├── bloc/
│   ├── auth_bloc.dart
│   ├── auth_event.dart
│   └── auth_state.dart
├── pages/
│   ├── login_page.dart
│   └── register_page.dart
└── widgets/
    ├── login_form.dart
    └── social_login_buttons.dart
```

**Rules:**
- ❌ No direct API calls
- ❌ No business logic
- ✅ Only UI and state management
- ✅ Depends on Domain layer only

### 2. Domain Layer
**Location:** `lib/features/*/domain/`

**Responsibilities:**
- Define business entities
- Contain business logic (Use Cases)
- Define repository interfaces
- Independent of frameworks

**Components:**
- **Entities**: Pure business objects
- **Use Cases**: Single responsibility business logic
- **Repositories**: Abstract interfaces

**Example Structure:**
```
domain/
├── entities/
│   └── user.dart
├── repositories/
│   └── auth_repository.dart
└── usecases/
    ├── login_usecase.dart
    ├── register_usecase.dart
    └── logout_usecase.dart
```

**Rules:**
- ❌ No Flutter dependencies
- ❌ No external packages (except Dart)
- ✅ Pure Dart code
- ✅ Framework independent

### 3. Data Layer
**Location:** `lib/features/*/data/`

**Responsibilities:**
- Implement repository interfaces
- Handle data sources (API, Local DB)
- Convert models to entities
- Cache management

**Components:**
- **Models**: Data transfer objects (DTOs)
- **Data Sources**: Remote (API) and Local (DB)
- **Repositories**: Implementation of domain interfaces

**Example Structure:**
```
data/
├── datasources/
│   ├── auth_remote_datasource.dart
│   └── auth_local_datasource.dart
├── models/
│   └── user_model.dart
└── repositories/
    └── auth_repository_impl.dart
```

**Rules:**
- ✅ Implements domain repositories
- ✅ Handles data conversion
- ✅ Manages caching
- ✅ Throws exceptions, not failures

## Data Flow

### Request Flow (User Action → API)
```
User Action
    ↓
UI (Page/Widget)
    ↓
BLoC (Event)
    ↓
Use Case
    ↓
Repository Interface (Domain)
    ↓
Repository Implementation (Data)
    ↓
Data Source (Remote/Local)
    ↓
API/Database
```

### Response Flow (API → UI)
```
API Response
    ↓
Data Source
    ↓
Model (Data)
    ↓
Repository Implementation
    ↓
Entity (Domain)
    ↓
Use Case
    ↓
BLoC (State)
    ↓
UI Update
```

## BLoC Pattern

### Components

#### 1. Events
User actions or system events
```dart
abstract class AuthEvent extends Equatable {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  
  LoginEvent(this.email, this.password);
  
  @override
  List<Object> get props => [email, password];
}
```

#### 2. States
UI states
```dart
abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
```

#### 3. BLoC
Business logic and state management
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  
  AuthBloc({required this.loginUseCase}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
  }
  
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
```

## Dependency Injection

Using **GetIt** for dependency injection:

```dart
// Setup
final getIt = GetIt.instance;

void setupDependencies() {
  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  
  // Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  
  // BLoCs
  getIt.registerFactory(() => AuthBloc(loginUseCase: getIt()));
}

// Usage
final authBloc = getIt<AuthBloc>();
```

## Error Handling

### Exception → Failure Flow

```
API Error
    ↓
Exception (Data Layer)
    ↓
Repository catches exception
    ↓
Converts to Failure (Domain Layer)
    ↓
Returns Either<Failure, Success>
    ↓
BLoC handles Failure
    ↓
Emits Error State
    ↓
UI shows error message
```

### Example

```dart
// Data Layer - Throw Exception
Future<UserModel> login(String email, String password) async {
  try {
    final response = await apiClient.login(email, password);
    return UserModel.fromJson(response.data);
  } catch (e) {
    throw ServerException('Login failed');
  }
}

// Repository - Convert to Failure
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    final user = await remoteDataSource.login(email, password);
    return Right(user.toEntity());
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}

// BLoC - Handle Failure
result.fold(
  (failure) => emit(AuthFailure(failure.message)),
  (user) => emit(AuthSuccess(user)),
);
```

## Use Case Pattern

Each use case has a single responsibility:

```dart
class LoginUseCase {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  
  const LoginParams({required this.email, required this.password});
  
  @override
  List<Object> get props => [email, password];
}
```

## Repository Pattern

### Interface (Domain)
```dart
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(String email, String password);
  Future<Either<Failure, void>> logout();
}
```

### Implementation (Data)
```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);
  
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
```

## Best Practices

### 1. Separation of Concerns
- Each layer has a single responsibility
- No cross-layer dependencies (except downward)
- Domain layer is independent

### 2. Dependency Rule
```
Presentation → Domain ← Data
```
- Presentation depends on Domain
- Data depends on Domain
- Domain depends on nothing

### 3. Single Responsibility
- One use case = one action
- One BLoC = one feature
- One repository = one data source

### 4. Testability
- Each layer can be tested independently
- Mock dependencies easily
- Use interfaces for flexibility

### 5. Scalability
- Easy to add new features
- Easy to modify existing features
- Easy to replace implementations

## Testing Strategy

### Unit Tests
- Test use cases
- Test repositories
- Test BLoCs
- Test models

### Widget Tests
- Test UI components
- Test user interactions
- Test state changes

### Integration Tests
- Test complete flows
- Test API integration
- Test database operations

## Common Patterns

### 1. Either Pattern (dartz)
```dart
Future<Either<Failure, Success>> someMethod() async {
  try {
    final result = await apiCall();
    return Right(result);
  } catch (e) {
    return Left(SomeFailure(e.toString()));
  }
}
```

### 2. Equatable Pattern
```dart
class User extends Equatable {
  final String id;
  final String name;
  
  const User({required this.id, required this.name});
  
  @override
  List<Object> get props => [id, name];
}
```

### 3. Factory Pattern
```dart
factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id'],
    name: json['name'],
  );
}
```

## Folder Structure Example

```
lib/
├── core/                       # Shared across features
│   ├── constants/
│   ├── di/
│   ├── error/
│   ├── network/
│   ├── routes/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
└── features/                   # Feature modules
    └── auth/
        ├── data/
        │   ├── datasources/
        │   │   ├── auth_remote_datasource.dart
        │   │   └── auth_local_datasource.dart
        │   ├── models/
        │   │   └── user_model.dart
        │   └── repositories/
        │       └── auth_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── user.dart
        │   ├── repositories/
        │   │   └── auth_repository.dart
        │   └── usecases/
        │       ├── login_usecase.dart
        │       └── register_usecase.dart
        └── presentation/
            ├── bloc/
            │   ├── auth_bloc.dart
            │   ├── auth_event.dart
            │   └── auth_state.dart
            ├── pages/
            │   ├── login_page.dart
            │   └── register_page.dart
            └── widgets/
                └── login_form.dart
```

## Summary

This architecture provides:
- ✅ Clear separation of concerns
- ✅ Easy to test
- ✅ Easy to maintain
- ✅ Easy to scale
- ✅ Framework independent
- ✅ Flexible and adaptable

---

**Remember:** The goal is to write clean, maintainable, and testable code! 🎯
