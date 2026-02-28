# Project Structure 📂

## Complete File Tree

```
lib/
├── core/                                    # Core functionality (shared across features)
│   ├── constants/                          # App-wide constants
│   │   ├── api_constants.dart             # API endpoints and timeouts
│   │   ├── app_constants.dart             # General app constants
│   │   └── storage_constants.dart         # Storage keys for SharedPreferences
│   │
│   ├── di/                                 # Dependency Injection
│   │   └── injection.dart                 # GetIt configuration
│   │
│   ├── error/                              # Error handling
│   │   ├── exceptions.dart                # Custom exception classes
│   │   └── failures.dart                  # Failure classes for domain layer
│   │
│   ├── network/                            # Network layer
│   │   ├── api_client.dart                # API endpoints implementation
│   │   ├── dio_client.dart                # Dio configuration and HTTP methods
│   │   └── interceptors/                  # HTTP interceptors
│   │       ├── auth_interceptor.dart      # Add auth token to requests
│   │       └── error_interceptor.dart     # Handle HTTP errors
│   │
│   ├── routes/                             # Navigation
│   │   ├── app_router.dart                # GoRouter configuration
│   │   └── app_routes.dart                # Route constants
│   │
│   ├── theme/                              # App theming
│   │   ├── app_theme.dart                 # Light & Dark theme data
│   │   └── app_colors.dart                # Color palette
│   │
│   ├── utils/                              # Utility functions
│   │   ├── bloc_observer.dart             # BLoC observer for logging
│   │   ├── error_handler.dart             # Global error handler
│   │   └── logger.dart                    # Logging utility
│   │
│   └── widgets/                            # Reusable widgets
│       └── (add your common widgets here)
│
├── features/                                # Feature modules (Clean Architecture)
│   │
│   ├── splash/                             # Splash Screen Feature
│   │   └── presentation/
│   │       └── pages/
│   │           └── splash_page.dart
│   │
│   ├── auth/                               # Authentication Feature
│   │   ├── data/                          # Data layer
│   │   │   ├── datasources/              # Data sources (API, Local DB)
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/                   # Data models (DTOs)
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/             # Repository implementations
│   │   │       └── auth_repository_impl.dart
│   │   │
│   │   ├── domain/                        # Domain layer (Business logic)
│   │   │   ├── entities/                 # Business entities
│   │   │   │   └── user.dart
│   │   │   ├── repositories/             # Repository interfaces
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/                 # Use cases (single responsibility)
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   │
│   │   └── presentation/                  # Presentation layer (UI)
│   │       ├── bloc/                     # BLoC state management
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/                    # Full screen pages
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       └── widgets/                  # Feature-specific widgets
│   │           ├── login_form.dart
│   │           └── social_login_buttons.dart
│   │
│   ├── home/                               # Home Feature
│   │   └── presentation/
│   │       └── pages/
│   │           └── home_page.dart
│   │
│   ├── settings/                           # Settings Feature (Theme & Language)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── settings_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── settings_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── settings_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_theme_usecase.dart
│   │   │       ├── save_theme_usecase.dart
│   │   │       ├── get_language_usecase.dart
│   │   │       └── save_language_usecase.dart
│   │   │
│   │   └── presentation/
│   │       └── bloc/
│   │           ├── theme_bloc.dart
│   │           └── language_bloc.dart
│   │
│   └── (add more features here following the same structure)
│
├── firebase_options.dart                    # Firebase configuration
└── main.dart                                # App entry point
```

## How to Add a New Feature

### Step 1: Create Feature Structure

```bash
features/
└── your_feature/
    ├── data/
    │   ├── datasources/
    │   ├── models/
    │   └── repositories/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    └── presentation/
        ├── bloc/
        ├── pages/
        └── widgets/
```

### Step 2: Implement Domain Layer (Business Logic)

1. **Create Entity** (`domain/entities/`)
```dart
class Product {
  final String id;
  final String name;
  final double price;
  
  const Product({
    required this.id,
    required this.name,
    required this.price,
  });
}
```

2. **Create Repository Interface** (`domain/repositories/`)
```dart
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProductById(String id);
}
```

3. **Create Use Case** (`domain/usecases/`)
```dart
class GetProductsUseCase {
  final ProductRepository repository;
  
  GetProductsUseCase(this.repository);
  
  Future<Either<Failure, List<Product>>> call() async {
    return await repository.getProducts();
  }
}
```

### Step 3: Implement Data Layer

1. **Create Model** (`data/models/`)
```dart
class ProductModel extends Product {
  const ProductModel({
    required String id,
    required String name,
    required double price,
  }) : super(id: id, name: name, price: price);
  
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}
```

2. **Create Data Source** (`data/datasources/`)
```dart
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;
  
  ProductRemoteDataSourceImpl(this.apiClient);
  
  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await apiClient.getProducts();
      return (response.data as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch products');
    }
  }
}
```

3. **Implement Repository** (`data/repositories/`)
```dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  
  ProductRepositoryImpl(this.remoteDataSource);
  
  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

### Step 4: Implement Presentation Layer

1. **Create Events** (`presentation/bloc/`)
```dart
abstract class ProductEvent extends Equatable {}

class LoadProductsEvent extends ProductEvent {
  @override
  List<Object> get props => [];
}
```

2. **Create States** (`presentation/bloc/`)
```dart
abstract class ProductState extends Equatable {}

class ProductInitial extends ProductState {
  @override
  List<Object> get props => [];
}

class ProductLoading extends ProductState {
  @override
  List<Object> get props => [];
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  
  ProductLoaded(this.products);
  
  @override
  List<Object> get props => [products];
}

class ProductError extends ProductState {
  final String message;
  
  ProductError(this.message);
  
  @override
  List<Object> get props => [message];
}
```

3. **Create BLoC** (`presentation/bloc/`)
```dart
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  
  ProductBloc({required this.getProductsUseCase}) : super(ProductInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
  }
  
  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    
    final result = await getProductsUseCase();
    
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductLoaded(products)),
    );
  }
}
```

4. **Create Page** (`presentation/pages/`)
```dart
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProductBloc>()..add(LoadProductsEvent()),
      child: Scaffold(
        appBar: AppBar(title: Text('Products')),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ProductLoaded) {
              return ListView.builder(
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('\$${product.price}'),
                  );
                },
              );
            } else if (state is ProductError) {
              return Center(child: Text(state.message));
            }
            return Container();
          },
        ),
      ),
    );
  }
}
```

### Step 5: Register Dependencies

In `lib/core/di/injection.dart`:

```dart
// Data Sources
getIt.registerLazySingleton<ProductRemoteDataSource>(
  () => ProductRemoteDataSourceImpl(getIt()),
);

// Repositories
getIt.registerLazySingleton<ProductRepository>(
  () => ProductRepositoryImpl(getIt()),
);

// Use Cases
getIt.registerLazySingleton(() => GetProductsUseCase(getIt()));

// BLoCs
getIt.registerFactory(() => ProductBloc(
  getProductsUseCase: getIt(),
));
```

### Step 6: Add Route

In `lib/core/routes/app_routes.dart`:
```dart
static const String products = '/products';
```

In `lib/core/routes/app_router.dart`:
```dart
GoRoute(
  path: AppRoutes.products,
  name: 'products',
  pageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: const ProductsPage(),
  ),
),
```

## Best Practices

### 1. Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE`

### 2. Folder Organization
- Keep related files together
- Follow Clean Architecture layers
- One feature = one folder

### 3. Dependency Flow
```
Presentation → Domain ← Data
```
- Presentation depends on Domain
- Data depends on Domain
- Domain is independent

### 4. Error Handling
- Data layer throws Exceptions
- Repository converts to Failures
- BLoC handles Failures
- UI shows error messages

### 5. State Management
- Use BLoC for complex state
- Use StatefulWidget for simple local state
- Keep state immutable

## Summary

This structure provides:
- ✅ Clear separation of concerns
- ✅ Easy to test each layer
- ✅ Easy to add new features
- ✅ Scalable architecture
- ✅ Maintainable codebase

---

Follow this structure for all new features! 🎯
