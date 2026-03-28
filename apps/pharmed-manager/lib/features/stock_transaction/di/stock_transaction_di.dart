import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../core/core.dart';
import '../data/datasource/stock_transaction_datasource.dart';
import '../data/datasource/stock_transaction_local_datasource.dart';
import '../data/datasource/stock_transaction_remote_datasource.dart';
import '../data/repository/stock_transaction_repository.dart';
import '../domain/repository/i_stock_transaction_repository.dart';
import '../domain/usecase/create_stock_transaction_usecase.dart';
import '../domain/usecase/delete_stock_transaction_usecase.dart';
import '../domain/usecase/get_cabin_stock_transactions_usecase.dart';
import '../domain/usecase/get_stock_transactions_usecase.dart';

class StockTransactionProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<StockTransactionDataSource>(
        create: (context) {
          if (isDev) {
            return StockTransactionLocalDataSource(assetPath: 'assets/mocks/stock_transaction.json');
          } else {
            return StockTransactionRemoteDataSource(apiManager: context.read<APIManager>());
          }
        },
      ),

      // 2. Repository
      Provider<IStockTransactionRepository>(
        create: (context) => StockTransactionRepository(context.read()),
      ),

      // 3. Use Cases
      Provider<CreateStockTransactionUseCase>(
        create: (context) => CreateStockTransactionUseCase(context.read()),
      ),

      Provider<DeleteStockTransactionUseCase>(
        create: (context) => DeleteStockTransactionUseCase(context.read()),
      ),

      Provider<GetStockTransactionsUseCase>(
        create: (context) => GetStockTransactionsUseCase(context.read()),
      ),

      Provider<GetCabinStockTransactionsUseCase>(
        create: (context) => GetCabinStockTransactionsUseCase(context.read()),
      ),
    ];
  }
}
