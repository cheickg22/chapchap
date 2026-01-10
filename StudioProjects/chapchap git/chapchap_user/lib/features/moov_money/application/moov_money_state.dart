import 'package:equatable/equatable.dart';
import '../data/models/moov_money_agent_model.dart';
import '../data/models/moov_money_transaction_model.dart';

abstract class MoovMoneyState extends Equatable {
  const MoovMoneyState();

  @override
  List<Object?> get props => [];
}

class MoovMoneyInitial extends MoovMoneyState {}

class MoovMoneyLoading extends MoovMoneyState {}

/// Agents states
class AgentsLoadedState extends MoovMoneyState {
  final List<MoovMoneyAgentModel> agents;

  const AgentsLoadedState(this.agents);

  @override
  List<Object?> get props => [agents];
}

/// Deposit states
class DepositSuccessState extends MoovMoneyState {
  final MoovMoneyTransactionModel transaction;

  const DepositSuccessState(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Withdrawal states
class WithdrawalVoucherGeneratedState extends MoovMoneyState {
  final MoovMoneyTransactionModel transaction;

  const WithdrawalVoucherGeneratedState(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Transaction history states
class TransactionHistoryLoadedState extends MoovMoneyState {
  final List<MoovMoneyTransactionModel> transactions;

  const TransactionHistoryLoadedState(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

/// Transaction details states
class TransactionDetailsLoadedState extends MoovMoneyState {
  final MoovMoneyTransactionModel transaction;

  const TransactionDetailsLoadedState(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Transaction cancelled state
class TransactionCancelledState extends MoovMoneyState {
  final MoovMoneyTransactionModel transaction;

  const TransactionCancelledState(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Error state
class MoovMoneyErrorState extends MoovMoneyState {
  final String message;

  const MoovMoneyErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
